import 'package:cloud_firestore/cloud_firestore.dart';

/// Mirrors the mobile app's `briefs/{briefId}` document.
class Brief {
  final String id;
  final String ownerId;
  final String title;
  final String category;
  final String status; // draft | submitted | offer_sent
  final Map<String, dynamic> answers;
  final DateTime? createdAt;
  final List<String> sentToIds;

  const Brief({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.category,
    required this.status,
    this.answers = const {},
    this.createdAt,
    this.sentToIds = const [],
  });

  factory Brief.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Brief(
      id: doc.id,
      ownerId: (data['ownerId'] as String?) ?? '',
      title: (data['title'] as String?) ?? '',
      category: (data['category'] as String?) ?? '',
      status: (data['status'] as String?) ?? 'draft',
      answers: (data['answers'] as Map?)?.cast<String, dynamic>() ?? const {},
      createdAt: _parseIso(data['createdAt']),
      sentToIds: (data['sentToIds'] as List?)?.cast<String>() ?? const [],
    );
  }

  static DateTime? _parseIso(dynamic value) =>
      value is String && value.isNotEmpty ? DateTime.tryParse(value) : null;
}
