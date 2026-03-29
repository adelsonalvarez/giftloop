// ============================================================
// GiftLoop - Amigo Oculto
// Autor: Adelson Alvarez
// Arquivo: lib/models/event.dart
// ============================================================

import 'participant.dart';

class Event {
  final String id;
  String name;
  DateTime date;
  String location;
  String? message;
  String adminPhone;
  List<Participant> participants;
  Map<String, String>? drawResult; // phone -> phone
  bool isDrawn;
  DateTime createdAt;

  Event({
    required this.id,
    required this.name,
    required this.date,
    required this.location,
    this.message,
    required this.adminPhone,
    List<Participant>? participants,
    this.drawResult,
    this.isDrawn = false,
    DateTime? createdAt,
  })  : participants = participants ?? [],
        createdAt = createdAt ?? DateTime.now();

  /// Retorna quem [phone] tirou no sorteio
  Participant? getSecretFriend(String phone) {
    if (drawResult == null) return null;
    final targetPhone = drawResult![phone];
    if (targetPhone == null) return null;
    return participants.firstWhere(
      (p) => p.phone == targetPhone,
      orElse: () => Participant(id: '', name: 'Desconhecido', phone: ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'date': date.toIso8601String(),
        'location': location,
        'message': message,
        'adminPhone': adminPhone,
        'participants': participants.map((p) => p.toJson()).toList(),
        'drawResult': drawResult,
        'isDrawn': isDrawn,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
        location: json['location'] ?? '',
        message: json['message'],
        adminPhone: json['adminPhone'] ?? '',
        participants: (json['participants'] as List<dynamic>?)
                ?.map((p) => Participant.fromJson(p as Map<String, dynamic>))
                .toList() ??
            [],
        drawResult: json['drawResult'] != null
            ? Map<String, String>.from(json['drawResult'])
            : null,
        isDrawn: json['isDrawn'] ?? false,
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      );
}