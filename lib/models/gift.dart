// ============================================================
// GiftLoop - Amigo Oculto
// Autor: Adelson Alvarez
// Arquivo: lib/models/gift.dart
// ============================================================

class Gift {
  final String id;
  String name;
  String? notes;

  Gift({
    required this.id,
    required this.name,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'notes': notes,
      };

  factory Gift.fromJson(Map<String, dynamic> json) => Gift(
        id: json['id'],
        name: json['name'],
        notes: json['notes'],
      );
}