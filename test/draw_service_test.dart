import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftloop/models/participant.dart';
import 'package:giftloop/services/draw_service.dart';

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

// ── Testes ────────────────────────────────────────────────────────────────────

void main() {
  group('DrawService - lógica do sorteio', () {
    late DrawService drawService;

    // setUp garante instância nova e isolada a cada teste
    setUp(() => drawService = DrawService());

    // ── Teste 1 ──────────────────────────────────────────────────────────────
    test('1. Lança exceção com menos de 2 participantes', () {
      expect(
        () => drawService.draw([_p('1', 'Ana', '11900000001')]),
        throwsException,
      );
    });

    // ── Teste 2 ──────────────────────────────────────────────────────────────
    test('2. Ninguém tira a si mesmo', () {
      final participants = _group(6);
      final result = drawService.draw(participants);
      final phones = participants.map((p) => p.phone).toSet();

      for (final entry in result.entries) {
        expect(
          entry.key,
          isNot(equals(entry.value)),
          reason: '${entry.key} não pode tirar a si mesmo.',
        );
      }
      expect(result.keys.toSet(), equals(phones));
      expect(result.values.toSet(), equals(phones));
    });

    // ── Teste 3 ──────────────────────────────────────────────────────────────
    test('3. Resultado forma ciclo hamiltoniano (20 execuções)', () {
      for (int run = 0; run < 20; run++) {
        final participants = _group(5);
        final result = drawService.draw(participants);
        expect(
          drawService.validateCycle(result, participants),
          isTrue,
          reason: 'Rodada $run: deve ser ciclo único válido.',
        );
      }
    });

    // ── Teste 4 ──────────────────────────────────────────────────────────────
    test('4. validateCycle rejeita pares diretos (A ↔ B)', () {
      final participants = _group(4);
      final phones = participants.map((p) => p.phone).toList();
      final invalid = {
        phones[0]: phones[1],
        phones[1]: phones[0], // par direto
        phones[2]: phones[3],
        phones[3]: phones[2], // par direto
      };
      expect(drawService.validateCycle(invalid, participants), isFalse);
    });

    // ── Teste 5 ──────────────────────────────────────────────────────────────
    test('5. validateCycle rejeita microciclos (A→B→C→A | D→E→D)', () {
      final participants = _group(5);
      final phones = participants.map((p) => p.phone).toList();
      final invalid = {
        phones[0]: phones[1],
        phones[1]: phones[2],
        phones[2]: phones[0], // microciclo de 3
        phones[3]: phones[4],
        phones[4]: phones[3], // microciclo de 2
      };
      expect(drawService.validateCycle(invalid, participants), isFalse);
    });

    // ── Teste 6 ──────────────────────────────────────────────────────────────
    // Com 2 participantes só existe um ciclo possível: A→B→A.
    // Usamos Random com seed fixo para resultado determinístico.
    test('6. Sorteio com 2 participantes produz ciclo A→B→A', () {
      final deterministicService = DrawService(rng: Random(42));
      final participants = [
        _p('1', 'Ana', '11900000001'),
        _p('2', 'Bia', '11900000002'),
      ];
      final result = deterministicService.draw(participants);
      expect(result.length, equals(2));
      // Com 2 participantes o único ciclo válido é sempre A↔B
      expect(result['11900000001'], equals('11900000002'));
      expect(result['11900000002'], equals('11900000001'));
      expect(deterministicService.validateCycle(result, participants), isTrue);
    });

    // ── Teste 7 ──────────────────────────────────────────────────────────────
    test('7. validateCycle rejeita resultado incompleto', () {
      final participants = _group(4);
      final phones = participants.map((p) => p.phone).toList();
      final incomplete = {
        phones[0]: phones[1],
        phones[1]: phones[2],
        phones[2]: phones[3],
        // phones[3] ausente — ciclo incompleto
      };
      expect(drawService.validateCycle(incomplete, participants), isFalse);
    });

    // ── Teste 8 ──────────────────────────────────────────────────────────────
    // Seed fixo garante que o mesmo embaralhamento ocorre sempre —
    // permite verificar determinismo sem depender do resultado real.
    test('8. DrawService com seed fixo produz resultado determinístico', () {
      final s1 = DrawService(rng: Random(99));
      final s2 = DrawService(rng: Random(99));
      final participants = _group(6);
      expect(s1.draw(participants), equals(s2.draw(participants)));
    });
  });
}
