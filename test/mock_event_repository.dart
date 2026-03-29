import 'package:giftloop/models/event.dart';
import 'package:giftloop/repositories/i_event_repository.dart';

/// Implementação em memória de [IEventRepository] para testes unitários.
///
/// Não usa SharedPreferences, Firestore nem nenhuma I/O externa.
/// Cada instância começa com store isolado e vazio.
///
/// Uso:
/// ```dart
/// final repo = MockEventRepository();
/// final provider = EventProvider(
///   repository: repo,
///   drawService: DrawService(),
/// );
/// ```
class MockEventRepository implements IEventRepository {
  final List<Event> _store = [];

  /// Acesso direto ao store interno — útil para assertions nos testes.
  List<Event> get store => List.unmodifiable(_store);

  @override
  Future<List<Event>> loadAll() async => List.from(_store);

  @override
  Future<Event?> findById(String id) async {
    try {
      return _store.firstWhere(
        (e) => e.id.toUpperCase() == id.toUpperCase(),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(Event event) async {
    final idx = _store.indexWhere((e) => e.id == event.id);
    if (idx >= 0) {
      _store[idx] = event;
    } else {
      _store.add(event);
    }
  }

  @override
  Future<void> delete(String id) async {
    _store.removeWhere((e) => e.id == id);
  }

  @override
  Future<void> clearAll() async => _store.clear();
}
