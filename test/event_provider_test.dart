import 'package:flutter_test/flutter_test.dart';
import 'package:giftloop/models/event.dart';
import 'package:giftloop/models/gift.dart';
import 'package:giftloop/models/participant.dart';
import 'package:giftloop/services/draw_service.dart';
import 'package:giftloop/services/event_provider.dart';
import 'mock_event_repository.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

Participant _p(String id, String name, String phone) =>
    Participant(id: id, name: name, phone: phone);

List<Participant> _group(int n) => List.generate(
      n,
      (i) => _p(
        'id$i',
        'Pessoa ${i + 1}',
        '119000000${i.toString().padLeft(2, '0')}',
      ),
    );

/// Cria provider com MockRepository e DrawService reais.
/// Aguarda o _loadAll() inicial completar antes de retornar.
Future<(EventProvider, MockEventRepository)> _makeProvider({
  List<Event> seed = const [],
}) async {
  final repo = MockEventRepository();
  for (final e in seed) {
    await repo.save(e);
  }
  final provider = EventProvider(
    repository: repo,
    drawService: DrawService(),
  );
  await Future.delayed(Duration.zero); // aguarda _loadAll()
  return (provider, repo);
}

/// Cria um evento mínimo válido para uso nos testes.
Event _event({
  String id = 'EVT001',
  String name = 'Natal',
  String adminPhone = '11900000001',
  List<Participant>? participants,
  bool isDrawn = false,
  Map<String, String>? drawResult,
}) =>
    Event(
      id: id,
      name: name,
      date: DateTime(2025, 12, 25),
      location: 'Casa da Vovó',
      adminPhone: adminPhone,
      participants: participants ?? [],
      isDrawn: isDrawn,
      drawResult: drawResult,
    );

// ── Testes ────────────────────────────────────────────────────────────────────

void main() {
  // ═══════════════════════════════════════════════════════════════════════════
  // CRUD de Eventos
  // ═══════════════════════════════════════════════════════════════════════════

  group('EventProvider - CRUD de eventos', () {
    // ── Teste 21 ──────────────────────────────────────────────────────────────
    test('21. Inicia com lista vazia quando repositório está vazio', () async {
      final (provider, _) = await _makeProvider();
      expect(provider.events, isEmpty);
    });

    // ── Teste 22 ──────────────────────────────────────────────────────────────
    test('22. Carrega eventos pré-existentes no repositório', () async {
      final (provider, _) = await _makeProvider(seed: [
        _event(id: 'EVT001', name: 'Natal'),
        _event(id: 'EVT002', name: 'Trabalho'),
      ]);
      expect(provider.events.length, equals(2));
    });

    // ── Teste 23 ──────────────────────────────────────────────────────────────
    test('23. createEvent expõe evento e persiste no repositório', () async {
      final (provider, repo) = await _makeProvider();
      await provider.createEvent(
        name: 'Natal da Família',
        date: DateTime(2025, 12, 25),
        location: 'Casa da Vovó',
        adminPhone: '11900000001',
      );
      expect(provider.events.length, equals(1));
      expect(provider.events.first.name, equals('Natal da Família'));
      expect(repo.store.length, equals(1));
    });

    // ── Teste 24 ──────────────────────────────────────────────────────────────
    test('24. createEvent gera ids únicos em chamadas consecutivas', () async {
      final (provider, _) = await _makeProvider();
      await provider.createEvent(
        name: 'Evento A',
        date: DateTime(2025, 12, 25),
        location: 'Local',
        adminPhone: '11900000001',
      );
      await provider.createEvent(
        name: 'Evento B',
        date: DateTime(2025, 12, 26),
        location: 'Local',
        adminPhone: '11900000002',
      );
      final ids = provider.events.map((e) => e.id).toSet();
      expect(ids.length, equals(2));
    });

    // ── Teste 25 ──────────────────────────────────────────────────────────────
    test('25. deleteEvent remove do provider e do repositório', () async {
      final (provider, repo) = await _makeProvider();
      final event = await provider.createEvent(
        name: 'Para deletar',
        date: DateTime(2025, 12, 25),
        location: 'Local',
        adminPhone: '11900000001',
      );
      await provider.deleteEvent(event.id);
      expect(provider.events, isEmpty);
      expect(repo.store, isEmpty);
    });

    // ── Teste 26 ──────────────────────────────────────────────────────────────
    test('26. getEventByCode encontra evento em memória', () async {
      final (provider, _) = await _makeProvider();
      final created = await provider.createEvent(
        name: 'Encontrável',
        date: DateTime(2025, 12, 25),
        location: 'Local',
        adminPhone: '11900000001',
      );
      final found = await provider.getEventByCode(created.id);
      expect(found, isNotNull);
      expect(found!.name, equals('Encontrável'));
    });

    // ── Teste 27 ──────────────────────────────────────────────────────────────
    test('27. getEventByCode é case-insensitive', () async {
      final (provider, _) = await _makeProvider();
      final created = await provider.createEvent(
        name: 'Case Test',
        date: DateTime(2025, 12, 25),
        location: 'Local',
        adminPhone: '11900000001',
      );
      final lower = await provider.getEventByCode(created.id.toLowerCase());
      expect(lower, isNotNull);
    });

    // ── Teste 28 ──────────────────────────────────────────────────────────────
    test('28. getEventByCode retorna null para código inexistente', () async {
      final (provider, _) = await _makeProvider();
      final found = await provider.getEventByCode('XXXXXX');
      expect(found, isNull);
    });

    // ── Teste 29 ──────────────────────────────────────────────────────────────
    test('29. reload sincroniza eventos inseridos diretamente no repositório',
        () async {
      final repo = MockEventRepository();
      final provider = EventProvider(
        repository: repo,
        drawService: DrawService(),
      );
      await Future.delayed(Duration.zero);
      expect(provider.events, isEmpty);

      // Simula evento salvo externamente (outro dispositivo / DevToolsScreen)
      await repo.save(_event(name: 'Externo'));
      await provider.reload();
      await Future.delayed(Duration.zero);

      expect(provider.events.length, equals(1));
      expect(provider.events.first.name, equals('Externo'));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Participantes
  // ═══════════════════════════════════════════════════════════════════════════

  group('EventProvider - participantes', () {
    late EventProvider provider;
    late String eventId;

    setUp(() async {
      final result = await _makeProvider();
      provider = result.$1;
      final event = await provider.createEvent(
        name: 'Natal',
        date: DateTime(2025, 12, 25),
        location: 'Local',
        adminPhone: '11900000001',
      );
      eventId = event.id;
    });

    // ── Teste 30 ──────────────────────────────────────────────────────────────
    test('30. addParticipant adiciona ao evento correto', () async {
      await provider.addParticipant(eventId, _p('p1', 'Ana', '11900000001'));
      expect(provider.events.first.participants.length, equals(1));
      expect(provider.events.first.participants.first.name, equals('Ana'));
    });

    // ── Teste 31 ──────────────────────────────────────────────────────────────
    test('31. addParticipant em evento inexistente não lança exceção', () async {
      await expectLater(
        provider.addParticipant('INVALIDO', _p('p1', 'Ana', '11900000001')),
        completes,
      );
    });

    // ── Teste 32 ──────────────────────────────────────────────────────────────
    test('32. removeParticipant remove pelo id correto', () async {
      await provider.addParticipant(eventId, _p('p1', 'Ana', '11900000001'));
      await provider.addParticipant(eventId, _p('p2', 'Bia', '11900000002'));
      await provider.removeParticipant(eventId, 'p1');
      final participants = provider.events.first.participants;
      expect(participants.length, equals(1));
      expect(participants.first.name, equals('Bia'));
    });

    // ── Teste 33 ──────────────────────────────────────────────────────────────
    test('33. setOptedOut atualiza flag do participante', () async {
      await provider.addParticipant(eventId, _p('p1', 'Ana', '11900000001'));
      expect(
          provider.events.first.participants.first.optedOutOfGifts, isFalse);
      await provider.setOptedOut(eventId, '11900000001', true);
      expect(
          provider.events.first.participants.first.optedOutOfGifts, isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Presentes
  // ═══════════════════════════════════════════════════════════════════════════

  group('EventProvider - presentes', () {
    late EventProvider provider;
    late String eventId;

    setUp(() async {
      final result = await _makeProvider();
      provider = result.$1;
      final event = await provider.createEvent(
        name: 'Natal',
        date: DateTime(2025, 12, 25),
        location: 'Local',
        adminPhone: '11900000001',
      );
      eventId = event.id;
      await provider.addParticipant(eventId, _p('p1', 'Ana', '11900000001'));
    });

    // ── Teste 34 ──────────────────────────────────────────────────────────────
    test('34. addGift adiciona presente ao participante correto', () async {
      await provider.addGift(
        eventId,
        '11900000001',
        Gift(id: 'g1', name: 'Livro', notes: 'Clean Code'),
      );
      final wishlist = provider.events.first.participants.first.wishlist;
      expect(wishlist.length, equals(1));
      expect(wishlist.first.name, equals('Livro'));
      expect(wishlist.first.notes, equals('Clean Code'));
    });

    // ── Teste 35 ──────────────────────────────────────────────────────────────
    test('35. removeGift remove apenas o presente pelo id', () async {
      await provider.addGift(eventId, '11900000001',
          Gift(id: 'g1', name: 'Livro'));
      await provider.addGift(eventId, '11900000001',
          Gift(id: 'g2', name: 'Fone'));
      await provider.removeGift(eventId, '11900000001', 'g1');
      final wishlist = provider.events.first.participants.first.wishlist;
      expect(wishlist.length, equals(1));
      expect(wishlist.first.id, equals('g2'));
    });

    // ── Teste 36 ──────────────────────────────────────────────────────────────
    test('36. addGift em participante inexistente não lança exceção', () async {
      await expectLater(
        provider.addGift(
          eventId,
          '99999999999', // phone não cadastrado
          Gift(id: 'g1', name: 'Livro'),
        ),
        completes,
      );
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Sorteio
  // ═══════════════════════════════════════════════════════════════════════════

  group('EventProvider - sorteio', () {
    late EventProvider provider;
    late String eventId;

    setUp(() async {
      final result = await _makeProvider();
      provider = result.$1;
      final event = await provider.createEvent(
        name: 'Natal',
        date: DateTime(2025, 12, 25),
        location: 'Local',
        adminPhone: '11900000001',
      );
      eventId = event.id;
    });

    // ── Teste 37 ──────────────────────────────────────────────────────────────
    test('37. performDraw retorna false para evento inexistente', () async {
      final success = await provider.performDraw('INEXISTENTE');
      expect(success, isFalse);
    });

    // ── Teste 38 ──────────────────────────────────────────────────────────────
    test('38. performDraw retorna false com 1 participante', () async {
      await provider.addParticipant(eventId, _p('p1', 'Ana', '11900000001'));
      final success = await provider.performDraw(eventId);
      expect(success, isFalse);
    });

    // ── Teste 39 ──────────────────────────────────────────────────────────────
    test('39. performDraw retorna true e marca isDrawn com 3+ participantes',
        () async {
      for (final p in _group(3)) {
        await provider.addParticipant(eventId, p);
      }
      final success = await provider.performDraw(eventId);
      expect(success, isTrue);
      expect(provider.events.first.isDrawn, isTrue);
      expect(provider.events.first.drawResult, isNotNull);
    });

    // ── Teste 40 ──────────────────────────────────────────────────────────────
    test('40. resultado do sorteio é persistido no repositório', () async {
      final repo = MockEventRepository();
      final prov = EventProvider(
        repository: repo,
        drawService: DrawService(),
      );
      await Future.delayed(Duration.zero);
      final event = await prov.createEvent(
        name: 'Natal',
        date: DateTime(2025, 12, 25),
        location: 'Local',
        adminPhone: '11900000001',
      );
      for (final p in _group(3)) {
        await prov.addParticipant(event.id, p);
      }
      await prov.performDraw(event.id);

      final persisted = await repo.findById(event.id);
      expect(persisted!.isDrawn, isTrue);
      expect(persisted.drawResult, isNotNull);
    });

    // ── Teste 41 ──────────────────────────────────────────────────────────────
    test('41. resultado do sorteio forma ciclo hamiltoniano válido', () async {
      final participants = _group(5);
      for (final p in participants) {
        await provider.addParticipant(eventId, p);
      }
      await provider.performDraw(eventId);

      final result = provider.events.first.drawResult!;
      final allParticipants = provider.events.first.participants;
      final drawService = DrawService();
      expect(drawService.validateCycle(result, allParticipants), isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // MockEventRepository — contrato da interface
  // ═══════════════════════════════════════════════════════════════════════════

  group('MockEventRepository - contrato IEventRepository', () {
    late MockEventRepository repo;

    setUp(() => repo = MockEventRepository());

    // ── Teste 42 ──────────────────────────────────────────────────────────────
    test('42. loadAll retorna lista vazia inicialmente', () async {
      expect(await repo.loadAll(), isEmpty);
    });

    // ── Teste 43 ──────────────────────────────────────────────────────────────
    test('43. save persiste e loadAll retorna o evento', () async {
      await repo.save(_event());
      final events = await repo.loadAll();
      expect(events.length, equals(1));
      expect(events.first.id, equals('EVT001'));
    });

    // ── Teste 44 ──────────────────────────────────────────────────────────────
    test('44. save sobrescreve evento com mesmo id', () async {
      await repo.save(_event(name: 'Versão 1'));
      await repo.save(_event(name: 'Versão 2'));
      final events = await repo.loadAll();
      expect(events.length, equals(1));
      expect(events.first.name, equals('Versão 2'));
    });

    // ── Teste 45 ──────────────────────────────────────────────────────────────
    test('45. delete remove o evento correto', () async {
      await repo.save(_event(id: 'EVT001'));
      await repo.save(_event(id: 'EVT002'));
      await repo.delete('EVT001');
      final events = await repo.loadAll();
      expect(events.length, equals(1));
      expect(events.first.id, equals('EVT002'));
    });

    // ── Teste 46 ──────────────────────────────────────────────────────────────
    test('46. findById retorna null para id inexistente', () async {
      expect(await repo.findById('INEXISTENTE'), isNull);
    });

    // ── Teste 47 ──────────────────────────────────────────────────────────────
    test('47. findById é case-insensitive', () async {
      await repo.save(_event(id: 'NATAL1'));
      expect(await repo.findById('natal1'), isNotNull);
      expect(await repo.findById('Natal1'), isNotNull);
      expect(await repo.findById('NATAL1'), isNotNull);
    });

    // ── Teste 48 ──────────────────────────────────────────────────────────────
    test('48. clearAll remove todos os eventos', () async {
      await repo.save(_event(id: 'EVT001'));
      await repo.save(_event(id: 'EVT002'));
      await repo.clearAll();
      expect(await repo.loadAll(), isEmpty);
    });
  });
}
