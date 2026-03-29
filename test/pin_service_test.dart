// ============================================================
// GiftLoop - Amigo Oculto
// Autor: Adelson Alvarez
// Arquivo: test/pin_service_test.dart
// ============================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:giftloop/services/pin_service.dart';

void main() {
  // SharedPreferences usa armazenamento em memória nos testes
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Hash SHA-256
  // ═══════════════════════════════════════════════════════════════════════════

  group('PinService.hash — geração do hash SHA-256', () {
    // ── Teste 49 ─────────────────────────────────────────────────────────────
    test('49. Mesmo PIN e telefone sempre geram o mesmo hash', () {
      final h1 = PinService.hash('1234', '11999990001');
      final h2 = PinService.hash('1234', '11999990001');
      expect(h1, equals(h2));
    });

    // ── Teste 50 ─────────────────────────────────────────────────────────────
    test('50. PINs diferentes geram hashes diferentes', () {
      final h1 = PinService.hash('1234', '11999990001');
      final h2 = PinService.hash('5678', '11999990001');
      expect(h1, isNot(equals(h2)));
    });

    // ── Teste 51 ─────────────────────────────────────────────────────────────
    test('51. Mesmo PIN com telefones diferentes geram hashes diferentes (salt)', () {
      final h1 = PinService.hash('1234', '11999990001');
      final h2 = PinService.hash('1234', '11999990002');
      expect(h1, isNot(equals(h2)));
    });

    // ── Teste 52 ─────────────────────────────────────────────────────────────
    test('52. Hash tem formato hexadecimal SHA-256 (64 caracteres)', () {
      final h = PinService.hash('0000', '11999990001');
      expect(h.length, equals(64));
      expect(RegExp(r'^[a-f0-9]+$').hasMatch(h), isTrue);
    });

    // ── Teste 53 ─────────────────────────────────────────────────────────────
    test('53. Telefone com e sem formatação gera o mesmo hash', () {
      // hash remove caracteres não numéricos do telefone antes de usar como salt
      final hFormatado   = PinService.hash('1234', '(11) 99999-0001');
      final hSemFormato  = PinService.hash('1234', '11999990001');
      expect(hFormatado, equals(hSemFormato));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Verificação do PIN
  // ═══════════════════════════════════════════════════════════════════════════

  group('PinService.verify — validação do PIN', () {
    // ── Teste 54 ─────────────────────────────────────────────────────────────
    test('54. PIN correto retorna true', () {
      const pin   = '9876';
      const phone = '11999990001';
      final storedHash = PinService.hash(pin, phone);
      expect(PinService.verify(pin, phone, storedHash), isTrue);
    });

    // ── Teste 55 ─────────────────────────────────────────────────────────────
    test('55. PIN errado retorna false', () {
      const phone = '11999990001';
      final storedHash = PinService.hash('1111', phone);
      expect(PinService.verify('2222', phone, storedHash), isFalse);
    });

    // ── Teste 56 ─────────────────────────────────────────────────────────────
    test('56. Telefone errado retorna false mesmo com PIN correto', () {
      const pin = '4321';
      final storedHash = PinService.hash(pin, '11999990001');
      expect(PinService.verify(pin, '11999990002', storedHash), isFalse);
    });

    // ── Teste 57 ─────────────────────────────────────────────────────────────
    test('57. Hash adulterado retorna false', () {
      const pin   = '1234';
      const phone = '11999990001';
      const hashAdulterado = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
      expect(PinService.verify(pin, phone, hashAdulterado), isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Sessão local (SharedPreferences)
  // ═══════════════════════════════════════════════════════════════════════════

  group('PinService — sessão local', () {
    // ── Teste 58 ─────────────────────────────────────────────────────────────
    test('58. Sem sessão salva, hasValidSession retorna false', () async {
      final valid = await PinService.hasValidSession('EVT001', '11999990001');
      expect(valid, isFalse);
    });

    // ── Teste 59 ─────────────────────────────────────────────────────────────
    test('59. Após saveSession, hasValidSession retorna true', () async {
      await PinService.saveSession('EVT001', '11999990001');
      final valid = await PinService.hasValidSession('EVT001', '11999990001');
      expect(valid, isTrue);
    });

    // ── Teste 60 ─────────────────────────────────────────────────────────────
    test('60. Após clearSession, hasValidSession retorna false', () async {
      await PinService.saveSession('EVT001', '11999990001');
      await PinService.clearSession('EVT001', '11999990001');
      final valid = await PinService.hasValidSession('EVT001', '11999990001');
      expect(valid, isFalse);
    });

    // ── Teste 61 ─────────────────────────────────────────────────────────────
    test('61. Sessões de eventos diferentes são independentes', () async {
      await PinService.saveSession('EVT001', '11999990001');
      // EVT002 com mesmo telefone não deve ter sessão
      final validEVT002 = await PinService.hasValidSession('EVT002', '11999990001');
      expect(validEVT002, isFalse);
      // EVT001 continua válido
      final validEVT001 = await PinService.hasValidSession('EVT001', '11999990001');
      expect(validEVT001, isTrue);
    });

    // ── Teste 62 ─────────────────────────────────────────────────────────────
    test('62. Sessões de participantes diferentes são independentes', () async {
      await PinService.saveSession('EVT001', '11999990001');
      // Outro participante no mesmo evento não deve ter sessão
      final validOutro = await PinService.hasValidSession('EVT001', '11999990002');
      expect(validOutro, isFalse);
    });

    // ── Teste 63 ─────────────────────────────────────────────────────────────
    test('63. Sessão expirada retorna false', () async {
      // Simula sessão com expiry no passado (já expirada)
      final prefs = await SharedPreferences.getInstance();
      const key = 'pin_session_EVT001_11999990001';
      final pastExpiry = DateTime.now()
          .subtract(const Duration(days: 1))
          .millisecondsSinceEpoch;
      await prefs.setInt(key, pastExpiry);

      final valid = await PinService.hasValidSession('EVT001', '11999990001');
      expect(valid, isFalse);
    });

    // ── Teste 64 ─────────────────────────────────────────────────────────────
    test('64. clearSession em sessão inexistente não lança exceção', () async {
      expect(
        () async => PinService.clearSession('EVT_INEXISTENTE', '11999990001'),
        returnsNormally,
      );
    });
  });
}