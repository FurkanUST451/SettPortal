import 'package:cloud_firestore/cloud_firestore.dart';

/// Mirrors the mobile app's `users/{uid}` document (see lib/data/models/user_model.dart
/// in the SET mobile repo), plus admin-only fields (`banned`, `bannedAt`, `banReason`)
/// written exclusively by the `banUser`/`unbanUser` Cloud Functions.
class AppUser {
  final String id;
  final String name;
  final String? surname;
  final int? age;
  final String? gender;
  final String email;
  final String role; // UserRole.client | UserRole.freelancer
  final String? avatarUrl;
  final DateTime? createdAt;
  final bool hasPushToken;
  final bool banned;
  final DateTime? bannedAt;
  final String? banReason;

  const AppUser({
    required this.id,
    required this.name,
    this.surname,
    this.age,
    this.gender,
    required this.email,
    required this.role,
    this.avatarUrl,
    this.createdAt,
    this.hasPushToken = false,
    this.banned = false,
    this.bannedAt,
    this.banReason,
  });

  String get fullName =>
      [name, surname].where((s) => (s ?? '').isNotEmpty).join(' ');

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return AppUser(
      id: doc.id,
      name: (data['name'] as String?) ?? '',
      surname: data['surname'] as String?,
      age: data['age'] as int?,
      gender: data['gender'] as String?,
      email: (data['email'] as String?) ?? '',
      role: (data['role'] as String?) ?? 'client',
      avatarUrl: data['avatarUrl'] as String?,
      createdAt: _parseIso(data['createdAt']),
      hasPushToken: (data['fcmToken'] as String?)?.isNotEmpty ?? false,
      banned: data['banned'] as bool? ?? false,
      bannedAt: _parseIso(data['bannedAt']),
      banReason: data['banReason'] as String?,
    );
  }

  static DateTime? _parseIso(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
