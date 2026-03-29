// ============================================================
// GiftLoop - Amigo Oculto
// Autor: Adelson Alvarez
// Arquivo: lib/repositories/firestore_event_repository.dart
// ============================================================

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/event.dart';
import '../repositories/i_event_repository.dart';

/// Implementação de [IEventRepository] usando Cloud Firestore.
///
/// Todos os dados — participantes, wishlist, drawResult e pinHash —
/// ficam num único documento do evento. Simples, sem subcoleções.
///
/// Estrutura no Firestore:
/// ```
/// events/{eventId}
///   id, name, date, location, message, adminPhone,
///   adminUid, code, isDrawn, createdAt,
///   participants: [ { id, name, phone, pinHash, wishlist, ... } ],
///   drawResult: { phone: phone, ... }
/// ```
class FirestoreEventRepository implements IEventRepository {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  FirestoreEventRepository({
    FirebaseFirestore? db,
    FirebaseAuth? auth,
  })  : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _events =>
      _db.collection('events');

  String? get _uid => _auth.currentUser?.uid;

  // ── Carrega todos os eventos do admin logado ───────────────────────────

  @override
  Future<List<Event>> loadAll() async {
    // Aguarda até 3s para o Firebase Auth restaurar a sessão
    // antes de considerar que o usuário não está logado.
    User? user = _auth.currentUser;
    if (user == null) {
      try {
        user = await _auth.authStateChanges().firstWhere((u) => u != null)
            .timeout(const Duration(seconds: 3));
      } catch (_) {
        return [];
      }
    }
    final uid = user?.uid;
    if (uid == null) return [];
    try {
      final snap = await _events.where('adminUid', isEqualTo: uid).get();
      return snap.docs.map((d) => Event.fromJson(d.data())).toList();
    } catch (e) {
      debugPrint('[Firestore] loadAll error: $e');
      return [];
    }
  }

  // ── Busca evento pelo código (público — sem auth) ─────────────────────

  @override
  Future<Event?> findById(String id) async {
    try {
      final doc = await _events.doc(id.toUpperCase()).get();
      if (doc.exists && doc.data() != null) {
        return Event.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('[Firestore] findById error: $e');
      return null;
    }
  }

  // ── Salva ou atualiza evento (merge) ──────────────────────────────────
  // Tudo num único documento: participantes, drawResult, pinHash incluídos.

  @override
  Future<void> save(Event event) async {
    try {
      final data = event.toJson();
      data['adminUid'] = _uid;
      data['code'] = event.id;
      // set() sem merge garante que o documento é sempre sobrescrito por completo.
      // Isso é essencial para que listas (participants, wishlist) sejam
      // atualizadas corretamente — merge não substitui arrays.
      await _events.doc(event.id).set(data);
    } catch (e) {
      debugPrint('[Firestore] save error: $e');
      rethrow;
    }
  }

  // ── Deleta evento ─────────────────────────────────────────────────────

  @override
  Future<void> delete(String id) async {
    try {
      await _events.doc(id).delete();
    } catch (e) {
      debugPrint('[Firestore] delete error: $e');
    }
  }

  // ── Limpa todos os eventos do admin ───────────────────────────────────

  @override
  Future<void> clearAll() async {
    final uid = _uid;
    if (uid == null) return;
    try {
      final snap = await _events.where('adminUid', isEqualTo: uid).get();
      final batch = _db.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      debugPrint('[Firestore] clearAll error: $e');
    }
  }

  // ── Stream em tempo real dos eventos do admin ─────────────────────────

  Stream<List<Event>> watchAdminEvents() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _events
        .where('adminUid', isEqualTo: uid)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Event.fromJson(d.data()))
            .toList());
  }
}