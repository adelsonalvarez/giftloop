// ============================================================
// GiftLoop - Amigo Oculto
// Autor: Adelson Alvarez
// Arquivo: lib/services/draw_service.dart
// ============================================================

import 'dart:math';
import '../models/participant.dart';
import '../repositories/i_draw_service.dart';

/// Implementação do sorteio do amigo oculto.
///
/// Garante um único ciclo hamiltoniano usando embaralhamento Fisher-Yates:
///   Ex: A → B → C → D → E → A
///
/// Nunca gera:
///   - Auto-sorteio  (A → A)
///   - Pares         (A → B → A)
///   - Microciclos   (A → B → C → A com outros fora do ciclo)
class DrawService implements IDrawService {
  final Random _rng;

  /// [rng] é injetável para permitir testes determinísticos.
  /// Em produção usa [Random()] por padrão.
  DrawService({Random? rng}) : _rng = rng ?? Random();

  @override
  Map<String, String> draw(List<Participant> participants) {
    if (participants.length < 2) {
      throw Exception(
        'São necessários pelo menos 2 participantes para sortear.',
      );
    }

    // Embaralha com Fisher-Yates
    final shuffled = List<Participant>.from(participants);
    for (int i = shuffled.length - 1; i > 0; i--) {
      final j = _rng.nextInt(i + 1);
      final temp = shuffled[i];
      shuffled[i] = shuffled[j];
      shuffled[j] = temp;
    }

    // Conecta em ciclo: 0→1→2→...→n-1→0
    final result = <String, String>{};
    for (int i = 0; i < shuffled.length; i++) {
      final giver  = shuffled[i];
      final target = shuffled[(i + 1) % shuffled.length];
      result[giver.phone] = target.phone;
    }

    return result;
  }

  @override
  bool validateCycle(
    Map<String, String> result,
    List<Participant> participants,
  ) {
    if (result.length != participants.length) return false;

    // Ninguém pode tirar a si mesmo
    for (final entry in result.entries) {
      if (entry.key == entry.value) return false;
    }

    // Percorre o grafo verificando ciclo único completo
    final phones = participants.map((p) => p.phone).toList();
    final start = phones.first;
    String current = start;
    int steps = 0;

    do {
      current = result[current] ?? '';
      steps++;
      if (steps > phones.length) return false;
    } while (current != start);

    return steps == phones.length;
  }
}