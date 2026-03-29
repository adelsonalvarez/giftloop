// ============================================================
// GiftLoop - Amigo Oculto
// Autor: Adelson Alvarez
// Arquivo: lib/repositories/i_draw_service.dart
// ============================================================

import '../models/participant.dart';

/// Contrato para o algoritmo de sorteio do amigo oculto.
///
/// O [EventProvider] depende apenas desta interface. Isso permite
/// substituir ou mockar o algoritmo nos testes unitários sem
/// alterar nenhum outro código.
///
/// Implementações:
///   - [DrawService] → ciclo hamiltoniano com Fisher-Yates
abstract interface class IDrawService {
  /// Realiza o sorteio e retorna Map<phone, phone>:
  /// chave = quem sorteia, valor = quem foi sorteado.
  ///
  /// Garante um único ciclo hamiltoniano — nunca pares nem microciclos.
  /// Lança [Exception] se [participants] tiver menos de 2 elementos.
  Map<String, String> draw(List<Participant> participants);

  /// Valida se [result] forma um ciclo hamiltoniano completo e válido
  /// para a lista de [participants].
  bool validateCycle(
    Map<String, String> result,
    List<Participant> participants,
  );
}
