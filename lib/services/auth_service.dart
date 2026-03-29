// ============================================================
// GiftLoop - Amigo Oculto
// Autor: Adelson Alvarez
// Arquivo: lib/services/auth_service.dart
// ============================================================

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Facade sobre o Firebase Auth.
///
/// Centraliza a autenticação do administrador via Google Sign-In.
/// Participantes não precisam de conta — o acesso deles é gerenciado
/// pelo [PinService] com hash SHA-256 local.
///
/// Registrado como [ChangeNotifierProvider] no main.dart.
/// Consumido via context.read<AuthService>() ou context.watch<AuthService>().
class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ── Estado público ────────────────────────────────────────────────────

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  /// Stream de mudanças de estado — útil para reagir a login/logout
  /// em tempo real sem polling.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Google Sign-In (Admin) ────────────────────────────────────────────

  /// Autentica o admin com Google usando a estratégia correta por plataforma.
  ///
  /// **Web:** usa [signInWithPopup] com [GoogleAuthProvider] —
  /// compatível com o Google Identity Services (GIS).
  ///
  /// **Android/iOS:** usa [GoogleSignIn.signIn()] + credential,
  /// que é o fluxo nativo recomendado fora da Web.
  Future<User?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider()
          ..addScope('email')
          ..addScope('profile');
        final result = await _auth.signInWithPopup(provider);
        notifyListeners();
        return result.user;
      } else {
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null; // cancelado pelo usuário

        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final result = await _auth.signInWithCredential(credential);
        notifyListeners();
        return result.user;
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('[AuthService] signInWithGoogle error: ${e.code}');
      rethrow;
    }
  }

  /// Encerra a sessão do admin no Firebase e no Google.
  Future<void> signOut() async {
    if (!kIsWeb) await _googleSignIn.signOut();
    await _auth.signOut();
    notifyListeners();
  }
}