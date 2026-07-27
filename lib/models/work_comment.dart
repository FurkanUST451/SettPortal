import 'package:cloud_firestore/cloud_firestore.dart';

/// Mirrors `works/{workId}/comments/{commentId}` (per-user like/comment
/// mechanism the mobile app has locally but hasn't pushed to the shared repo
/// yet). Field names follow the same convention as the rest of the mobile
/// schema (plain strings for dates); adjust here if the mobile team's actual
/// field names differ once merged.
class WorkComment {
  final String id;
  final String workId;
  final String userId;
  final String? userName;
  final String text;
  final DateTime? createdAt;
  final bool flagged;

  const WorkComment({
    required this.id,
    required this.workId,
    required this.userId,
    this.userName,
    required this.text,
    this.createdAt,
    this.flagged = false,
  });

  factory WorkComment.fromFirestore(
    String workId,
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return WorkComment(
      id: doc.id,
      workId: workId,
      userId: (data['userId'] as String?) ?? '',
      userName: data['userName'] as String?,
      text: (data['text'] as String?) ?? (data['content'] as String? ?? ''),
      createdAt: _parseFlexible(data['createdAt']),
      flagged: data['flagged'] as bool? ?? false,
    );
  }

  static DateTime? _parseFlexible(dynamic value) {
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    if (value is Timestamp) return value.toDate();
    return null;
  }
}
