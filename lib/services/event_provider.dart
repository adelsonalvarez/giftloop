// ============================================================
// GiftLoop - Amigo Oculto
// Autor: Adelson Alvarez
// Arquivo: lib/services/event_provider.dart
// ============================================================

import 'dart:math';
import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/participant.dart';
import '../models/gift.dart';
import '../repositories/i_event_repository.dart';
import '../repositories/i_draw_service.dart';

/// Gerenciador de estado dos eventos.
///
/// Depende apenas das interfaces [IEventRepository] e [IDrawService]
/// — nunca das implementações concretas. Isso permite:
///   - Trocar SharedPreferences por Firestore sem alterar este arquivo
///   - Injetar mocks nos testes unitários
///
/// Registro no main.dart:
/// ```dart
/// ChangeNotifierProvider(
///   create: (_) => EventProvider(
///     repository: LocalEventRepository(),
///     drawService: DrawService(),
///   ),
/// )
/// ```
class EventProvider extends ChangeNotifier {
  final IEventRepository _repository;
  final IDrawService _drawService;

  List<Event> _events = [];
  bool _isLoading = false;

  List<Event> get events => List.unmodifiable(_events);
  bool get isLoading => _isLoading;

  EventProvider({
    required IEventRepository repository,
    required IDrawService drawService,
  })  : _repository = repository,
        _drawService = drawService {
    _loadAll();
  }

  Future<void> _loadAll() async {
    _isLoading = true;
    notifyListeners();

    final loaded = await _repository.loadAll();

    // Merge: mantém eventos que estão em memória mas ainda não chegaram
    // no repositório remoto (ex: recém-criados antes do Firestore confirmar).
    // Eventos já existentes no repositório são atualizados.
    final mergedIds = loaded.map((e) => e.id).toSet();
    final pendingLocal = _events.where((e) => !mergedIds.contains(e.id)).toList();
    _events = [...loaded, ...pendingLocal];

    _isLoading = false;
    notifyListeners();
  }

  // ── CRUD Eventos ──────────────────────────────────────────────────────

  Future<Event> createEvent({
    required String name,
    required DateTime date,
    required String location,
    String? message,
    required String adminPhone,
  }) async {
    final event = Event(
      id: _generateCode(),
      name: name,
      date: date,
      location: location,
      message: message,
      adminPhone: adminPhone,
    );
    _events.add(event);
    await _repository.save(event);
    notifyListeners();
    return event;
  }

  /// Adiciona um evento ao cache em memória sem persistir.
  /// Usado quando um participante acessa um evento pelo código —
  /// o evento vem do Firestore via findById mas precisa estar
  /// disponível em provider.events para as telas subsequentes.
  void cacheEvent(Event event) {
    final exists = _events.any((e) => e.id == event.id);
    if (!exists) {
      _events.add(event);
      notifyListeners();
    }
  }

  Future<Event?> getEventByCode(String code) async {
    final codeUpper = code.trim().toUpperCase();
    // Primeiro verifica em memória (eventos do admin logado)
    final inMemory = _events.firstWhere(
      (e) => e.id.toUpperCase() == codeUpper,
      orElse: () => Event(
        id: '',
        name: '',
        date: DateTime.now(),
        location: '',
        adminPhone: '',
      ),
    );
    if (inMemory.id.isNotEmpty) return inMemory;
    // Não encontrou em memória — busca no Firestore (participante de outro evento)
    return await _repository.findById(codeUpper);
  }

  Future<void> deleteEvent(String id) async {
    _events.removeWhere((e) => e.id == id);
    await _repository.delete(id);
    notifyListeners();
  }

  // ── Participantes ─────────────────────────────────────────────────────

  Future<void> addParticipant(String eventId, Participant participant) async {
    final event = _findEvent(eventId);
    if (event == null) return;
    event.participants.add(participant);
    await _repository.save(event);
    notifyListeners();
  }

  Future<void> removeParticipant(String eventId, String participantId) async {
    final event = _findEvent(eventId);
    if (event == null) return;
    event.participants.removeWhere((p) => p.id == participantId);
    await _repository.save(event);
    notifyListeners();
  }

  // ── Sorteio ───────────────────────────────────────────────────────────

  Future<bool> performDraw(String eventId) async {
    final event = _findEvent(eventId);
    if (event == null) return false;
    if (event.participants.length < 2) return false;

    final result = _drawService.draw(event.participants);
    final isValid = _drawService.validateCycle(result, event.participants);
    if (!isValid) return false;

    event.drawResult = result;
    event.isDrawn = true;
    await _repository.save(event);
    notifyListeners();
    return true;
  }

  // ── Presentes ─────────────────────────────────────────────────────────

  Future<void> addGift(
    String eventId,
    String participantPhone,
    Gift gift,
  ) async {
    final event = _findEvent(eventId);
    if (event == null) return;
    final participant = _findParticipant(event, participantPhone);
    if (participant == null) return;
    participant.wishlist.add(gift);
    await _repository.save(event);
    notifyListeners();
  }

  Future<void> removeGift(
    String eventId,
    String participantPhone,
    String giftId,
  ) async {
    final event = _findEvent(eventId);
    if (event == null) return;
    final participant = _findParticipant(event, participantPhone);
    if (participant == null) return;
    participant.wishlist.removeWhere((g) => g.id == giftId);
    await _repository.save(event);
    notifyListeners();
  }

  /// Atualiza apenas os metadados do evento (nome, data, local, observações).
  /// Participantes e resultado do sorteio não são afetados.
  Future<void> updateEventMeta({
    required String eventId,
    required String name,
    required DateTime date,
    required String location,
    String? message,
  }) async {
    final event = _findEvent(eventId);
    if (event == null) return;
    event.name = name;
    event.date = date;
    event.location = location;
    event.message = message;
    await _repository.save(event);
    notifyListeners();
  }

  /// Salva o hash do PIN criado pelo participante.
  /// Chamado apenas uma vez — na criação do PIN pelo próprio participante.
  Future<void> setParticipantPin(
    String eventId,
    String phone,
    String pinHash,
  ) async {
    final event = _findEvent(eventId);
    if (event == null) return;
    final participant = _findParticipant(event, phone);
    if (participant == null) return;
    participant.pinHash = pinHash;
    await _repository.save(event);
    notifyListeners();
  }

  Future<void> setOptedOut(
    String eventId,
    String participantPhone,
    bool value,
  ) async {
    final event = _findEvent(eventId);
    if (event == null) return;
    final participant = _findParticipant(event, participantPhone);
    if (participant == null) return;
    participant.optedOutOfGifts = value;
    await _repository.save(event);
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────────────────

  Event? _findEvent(String id) {
    try {
      return _events.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Participant? _findParticipant(Event event, String phone) {
    try {
      return event.participants.firstWhere((p) => p.phone == phone);
    } catch (_) {
      return null;
    }
  }

  /// Gera código alfanumérico de 6 caracteres legível (sem O, 0, I, 1).
  /// Responsabilidade do provider enquanto não há servidor para gerar IDs.
  /// Na Fase 2 (Firestore) o ID será gerado pelo próprio banco.
  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random();
    return List.generate(6, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  /// Recarrega todos os eventos do repositório.
  Future<void> reload() async => _loadAll();
}