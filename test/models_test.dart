import 'package:flutter_test/flutter_test.dart';
import 'package:giftloop/models/event.dart';
import 'package:giftloop/models/gift.dart';
import 'package:giftloop/models/participant.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

Participant _p(String id, String name, String phone) =>
    Participant(id: id, name: name, phone: phone);

// ── Testes ────────────────────────────────────────────────────────────────────

void main() {
  // ═══════════════════════════════════════════════════════════════════════════
  // Gift
  // ═══════════════════════════════════════════════════════════════════════════

  group('Gift - serialização JSON', () {
    // ── Teste 9 ───────────────────────────────────────────────────────────────
    test('9. Serializa e desserializa todos os campos', () {
      final gift = Gift(id: 'g1', name: 'Livro de Flutter', notes: 'Capa dura');
      final restored = Gift.fromJson(gift.toJson());
      expect(restored.id, equals(gift.id));
      expect(restored.name, equals(gift.name));
      expect(restored.notes, equals(gift.notes));
    });

    // ── Teste 10 ──────────────────────────────────────────────────────────────
    test('10. notes nulo é preservado como nulo', () {
      final gift = Gift(id: 'g2', name: 'Fone');
      final restored = Gift.fromJson(gift.toJson());
      expect(restored.notes, isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Participant
  // ═══════════════════════════════════════════════════════════════════════════

  group('Participant - serialização JSON', () {
    // ── Teste 11 ──────────────────────────────────────────────────────────────
    test('11. Serializa preservando wishlist completa', () {
      final participant = Participant(
        id: 'p1',
        name: 'Carlos',
        phone: '11999990001',
        wishlist: [
          Gift(id: 'g1', name: 'Fone de ouvido', notes: 'Cor preta'),
          Gift(id: 'g2', name: 'Caneca térmica'),
        ],
      );
      final restored = Participant.fromJson(participant.toJson());
      expect(restored.id, equals('p1'));
      expect(restored.name, equals('Carlos'));
      expect(restored.phone, equals('11999990001'));
      expect(restored.wishlist.length, equals(2));
      expect(restored.wishlist[0].name, equals('Fone de ouvido'));
      expect(restored.wishlist[0].notes, equals('Cor preta'));
      expect(restored.wishlist[1].notes, isNull);
    });

    // ── Teste 12 ──────────────────────────────────────────────────────────────
    test('12. optedOutOfGifts padrão é false', () {
      final p = Participant(id: 'p1', name: 'Ana', phone: '11900000001');
      final restored = Participant.fromJson(p.toJson());
      expect(restored.optedOutOfGifts, isFalse);
    });

    // ── Teste 13 ──────────────────────────────────────────────────────────────
    test('13. optedOutOfGifts true é preservado', () {
      final p = Participant(
        id: 'p1',
        name: 'Ana',
        phone: '11900000001',
        optedOutOfGifts: true,
      );
      final restored = Participant.fromJson(p.toJson());
      expect(restored.optedOutOfGifts, isTrue);
    });

    // ── Teste 14 ──────────────────────────────────────────────────────────────
    test('14. wishlist vazia é preservada como lista vazia', () {
      final p = Participant(id: 'p1', name: 'Ana', phone: '11900000001');
      final restored = Participant.fromJson(p.toJson());
      expect(restored.wishlist, isEmpty);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Event
  // ═══════════════════════════════════════════════════════════════════════════

  group('Event - serialização JSON', () {
    // ── Teste 15 ──────────────────────────────────────────────────────────────
    test('15. Serializa e desserializa com participantes e drawResult', () {
      final date = DateTime(2025, 12, 20, 19, 0);
      final event = Event(
        id: 'EVT001',
        name: 'Natal da Família',
        date: date,
        location: 'Casa da Vovó',
        message: 'Com muito amor!',
        adminPhone: '11900000001',
        participants: [
          _p('p1', 'Ana', '11900000001'),
          _p('p2', 'Bruno', '11900000002'),
          _p('p3', 'Carla', '11900000003'),
        ],
        drawResult: {
          '11900000001': '11900000002',
          '11900000002': '11900000003',
          '11900000003': '11900000001',
        },
        isDrawn: true,
      );
      final restored = Event.fromJson(event.toJson());
      expect(restored.id, equals('EVT001'));
      expect(restored.name, equals('Natal da Família'));
      expect(restored.date, equals(date));
      expect(restored.location, equals('Casa da Vovó'));
      expect(restored.message, equals('Com muito amor!'));
      expect(restored.isDrawn, isTrue);
      expect(restored.participants.length, equals(3));
      expect(restored.drawResult!['11900000001'], equals('11900000002'));
    });

    // ── Teste 16 ──────────────────────────────────────────────────────────────
    test('16. drawResult null é preservado como null', () {
      final event = Event(
        id: 'EVT002',
        name: 'Pendente',
        date: DateTime(2025, 12, 25),
        location: 'Local',
        adminPhone: '11900000001',
      );
      final restored = Event.fromJson(event.toJson());
      expect(restored.drawResult, isNull);
      expect(restored.isDrawn, isFalse);
    });

    // ── Teste 17 ──────────────────────────────────────────────────────────────
    test('17. message null é preservado como null', () {
      final event = Event(
        id: 'EVT003',
        name: 'Sem mensagem',
        date: DateTime(2025, 12, 25),
        location: 'Local',
        adminPhone: '11900000001',
      );
      final restored = Event.fromJson(event.toJson());
      expect(restored.message, isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Event.getSecretFriend
  // ═══════════════════════════════════════════════════════════════════════════

  group('Event.getSecretFriend', () {
    late Event event;

    setUp(() {
      event = Event(
        id: 'EVT010',
        name: 'Amigo Secreto',
        date: DateTime(2025, 12, 15),
        location: 'Escritório',
        adminPhone: '11900000001',
        participants: [
          _p('p1', 'Diana', '11900000001'),
          _p('p2', 'Eduardo', '11900000002'),
          _p('p3', 'Flávia', '11900000003'),
        ],
        drawResult: {
          '11900000001': '11900000003', // Diana → Flávia
          '11900000002': '11900000001', // Eduardo → Diana
          '11900000003': '11900000002', // Flávia → Eduardo
        },
        isDrawn: true,
      );
    });

    // ── Teste 18 ──────────────────────────────────────────────────────────────
    test('18. Retorna participante correto para cada phone', () {
      expect(event.getSecretFriend('11900000001')?.name, equals('Flávia'));
      expect(event.getSecretFriend('11900000002')?.name, equals('Diana'));
      expect(event.getSecretFriend('11900000003')?.name, equals('Eduardo'));
    });

    // ── Teste 19 ──────────────────────────────────────────────────────────────
    test('19. Retorna null quando sorteio não foi realizado', () {
      final pendente = Event(
        id: 'EVT011',
        name: 'Pendente',
        date: DateTime(2025, 11, 1),
        location: 'Online',
        adminPhone: '11900000001',
        isDrawn: false,
      );
      expect(pendente.getSecretFriend('11900000001'), isNull);
    });

    // ── Teste 20 ──────────────────────────────────────────────────────────────
    test('20. Retorna null para phone não encontrado no drawResult', () {
      expect(event.getSecretFriend('99999999999'), isNull);
    });
  });
}
