// ============================================================
// GiftLoop - Amigo Oculto
// Autor: Adelson Alvarez
// Arquivo: lib/repositories/i_event_repository.dart
// ============================================================

import '../models/event.dart';

/// Contrato de acesso a dados para eventos.
///
/// O [EventProvider] depende apenas desta interface — nunca da
/// implementação concreta. Isso permite trocar SharedPreferences
/// por Firestore sem alterar nenhuma tela.
///
/// Implementações:
///   - [LocalEventRepository]  → SharedPreferences
///   - FirestoreEventRepository → Cloud Firestore
abstract interface class IEventRepository {
  /// Carrega todos os eventos persistidos.
  Future<List<Event>> loadAll();

  /// Busca um evento pelo código. Retorna null se não encontrar.
  Future<Event?> findById(String id);

  /// Persiste um evento (cria ou sobrescreve pelo id).
  Future<void> save(Event event);

  /// Remove um evento pelo id.
  Future<void> delete(String id);

  /// Apaga todos os eventos. Usado pela DevToolsScreen.
  Future<void> clearAll();
}
