// ============================================================
// GiftLoop - Amigo Oculto
// Autor: Adelson Alvarez
// Arquivo: lib/repositories/local_event_repository.dart
// ============================================================

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event.dart';
import '../repositories/i_event_repository.dart';

/// Implementação local de [IEventRepository] usando SharedPreferences.
///
class LocalEventRepository implements IEventRepository {
  static const _eventsKey = 'giftloop_events';

  @override
  Future<List<Event>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_eventsKey);
    if (jsonStr == null) return [];
    final list = jsonDecode(jsonStr) as List<dynamic>;
    return list.map((e) => Event.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Event?> findById(String id) async {
    final events = await loadAll();
    try {
      return events.firstWhere(
        (e) => e.id.toUpperCase() == id.toUpperCase(),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(Event event) async {
    final events = await loadAll();
    final idx = events.indexWhere((e) => e.id == event.id);
    if (idx >= 0) {
      events[idx] = event;
    } else {
      events.add(event);
    }
    await _persist(events);
  }

  @override
  Future<void> delete(String id) async {
    final events = await loadAll();
    events.removeWhere((e) => e.id == id);
    await _persist(events);
  }

  @override
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_eventsKey);
  }

  // ── Privado ───────────────────────────────────────────────────────────

  Future<void> _persist(List<Event> events) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(events.map((e) => e.toJson()).toList());
    await prefs.setString(_eventsKey, jsonStr);
  }
}
