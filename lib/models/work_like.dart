import 'package:cloud_firestore/cloud_firestore.dart';

/// Mirrors `works/{workId}/likes/{likeId}` — doc id is typically the liking
/// user's uid (one like per user), but this model doesn't assume that.
class WorkLike {
  final String id;
  final String workId;
  final String userId;
  final DateTime? createdAt;

  const WorkLike({
    required this.id,
    required this.workId,
    required this.userId,
    this.createdAt,
  });

  factory WorkLike.fromFirestore(
    String workId,
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return WorkLike(
      id: doc.id,
      workId: workId,
      userId: (data['userId'] as String?) ?? doc.id,
      createdAt: _parseFlexible(data['createdAt']),
    );
  }

  static DateTime? _parseFlexible(dynamic value) {
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    if (value is Timestamp) return value.toDate();
    return null;
  }
}
