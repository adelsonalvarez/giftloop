// ============================================================
// GiftLoop - Amigo Oculto
// Autor: Adelson Alvarez
// Arquivo: lib/services/pin_service.dart
// ============================================================

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gerencia o PIN do participante.
///
/// Segurança:
///   - O PIN nunca é armazenado em texto puro — apenas o hash SHA-256
///   - O hash é salvo no Firestore dentro do documento do participante
///   - Nem o admin nem o sistema conseguem reverter o hash para o PIN original
///
/// Sessão local:
///   - Após validar o PIN, salva uma sessão em SharedPreferences por [sessionDays] dias
///   - Na próxima entrada no mesmo dispositivo, o PIN não é solicitado novamente
///   - Trocar de dispositivo invalida a sessão automaticamente
class PinService {
  static const int sessionDays = 30;
  static const String _sessionKeyPrefix = 'pin_session_';

  // ── Hash ──────────────────────────────────────────────────────────────

  /// Converte o PIN em hash SHA-256.
  /// Usa telefone como salt para evitar colisões entre participantes.
  static String hash(String pin, String phone) {
    final salt = phone.replaceAll(RegExp(r'\D'), '');
    final bytes = utf8.encode('$salt:$pin');
    return sha256.convert(bytes).toString();
  }

  /// Verifica se o PIN informado corresponde ao hash armazenado.
  static bool verify(String pin, String phone, String storedHash) {
    return hash(pin, phone) == storedHash;
  }

  // ── Sessão local ──────────────────────────────────────────────────────

  /// Chave única por evento + telefone para suportar múltiplos eventos
  /// no mesmo dispositivo sem conflito.
  static String _sessionKey(String eventId, String phone) =>
      '$_sessionKeyPrefix${eventId}_$phone';

  /// Salva sessão local após PIN validado.
  /// O participante não precisará digitar o PIN por [sessionDays] dias
  /// neste dispositivo.
  static Future<void> saveSession(String eventId, String phone) async {
    final prefs = await SharedPreferences.getInstance();
    final expiry = DateTime.now()
        .add(const Duration(days: sessionDays))
        .millisecondsSinceEpoch;
    await prefs.setInt(_sessionKey(eventId, phone), expiry);
  }

  /// Verifica se existe sessão válida para este evento + telefone.
  static Future<bool> hasValidSession(String eventId, String phone) async {
    final prefs = await SharedPreferences.getInstance();
    final expiry = prefs.getInt(_sessionKey(eventId, phone));
    if (expiry == null) return false;
    return DateTime.now().millisecondsSinceEpoch < expiry;
  }

  /// Remove a sessão local (logout do participante).
  static Future<void> clearSession(String eventId, String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey(eventId, phone));
  }
}