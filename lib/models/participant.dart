// ============================================================
// GiftLoop - Amigo Oculto
// Autor: Adelson Alvarez
// Arquivo: lib/models/participant.dart
// ============================================================

import 'gift.dart';

class Participant {
  final String id;
  String name;
  String phone;
  String? photoUrl;
  List<Gift> wishlist;
  bool optedOutOfGifts;
  String? pinHash; // SHA-256 do PIN — nunca armazenado em texto puro

  Participant({
    required this.id,
    required this.name,
    required this.phone,
    this.photoUrl,
    List<Gift>? wishlist,
    this.optedOutOfGifts = false,
    this.pinHash,
  }) : wishlist = wishlist ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'photoUrl': photoUrl,
        'wishlist': wishlist.map((g) => g.toJson()).toList(),
        'optedOutOfGifts': optedOutOfGifts,
        'pinHash': pinHash,
      };

  factory Participant.fromJson(Map<String, dynamic> json) => Participant(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        phone: json['phone'] ?? '',
        photoUrl: json['photoUrl'],
        wishlist: (json['wishlist'] as List<dynamic>?)
                ?.map((g) => Gift.fromJson(g))
                .toList() ??
            [],
        optedOutOfGifts: json['optedOutOfGifts'] ?? false,
        pinHash: json['pinHash'],
      );
}