import 'package:cloud_firestore/cloud_firestore.dart';

/// Reported content (denormalized snapshot of the `works` doc at the time of
/// the report, so the admin panel can show it even if the work is later
/// edited or deleted).
class ReportTarget {
  final String? workId;
  final String? title;
  final String? description;
  final String? studio;
  final String? type;
  final String? thumbnailUrl;
  final String? mediaUrl;
  final String? freelancerId;

  const ReportTarget({
    this.workId,
    this.title,
    this.description,
    this.studio,
    this.type,
    this.thumbnailUrl,
    this.mediaUrl,
    this.freelancerId,
  });

  factory ReportTarget.fromMap(Map<String, dynamic> data) => ReportTarget(
    workId: data['workId'] as String?,
    title: data['title'] as String?,
    description: data['description'] as String?,
    studio: data['studio'] as String?,
    type: data['type'] as String?,
    thumbnailUrl: data['thumbnailUrl'] as String?,
    mediaUrl: data['mediaUrl'] as String?,
    freelancerId: data['freelancerId'] as String?,
  );
}

/// Snapshot of the reporting user at the time of the report.
class ReportReporter {
  final String? userId;
  final String? name;
  final String? email;
  final String? role;
  final String? avatarUrl;

  const ReportReporter({
    this.userId,
    this.name,
    this.email,
    this.role,
    this.avatarUrl,
  });

  factory ReportReporter.fromMap(Map<String, dynamic> data) => ReportReporter(
    userId: data['userId'] as String?,
    name: data['name'] as String?,
    email: data['email'] as String?,
    role: data['role'] as String?,
    avatarUrl: data['avatarUrl'] as String?,
  );
}

/// Mirrors `reports/{reportId}` — created by the mobile app when a user taps
/// "Bildir" on a Keşfet feed item. `createdAt` is stored as an ISO-8601
/// string by the mobile app, not a Firestore Timestamp.
class Report {
  final String id;
  final String type;
  final String targetId;
  final ReportTarget target;
  final ReportReporter reporter;
  final String reason;
  final String status;
  final DateTime? createdAt;

  const Report({
    required this.id,
    required this.type,
    required this.targetId,
    required this.target,
    required this.reporter,
    required this.reason,
    required this.status,
    this.createdAt,
  });

  factory Report.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Report(
      id: doc.id,
      type: (data['type'] as String?) ?? '',
      targetId: (data['targetId'] as String?) ?? '',
      target: ReportTarget.fromMap(
        (data['target'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      reporter: ReportReporter.fromMap(
        (data['reporter'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      reason: (data['reason'] as String?) ?? '',
      status: (data['status'] as String?) ?? 'pending',
      createdAt: _parseIso(data['createdAt']),
    );
  }

  static DateTime? _parseIso(dynamic value) =>
      value is String && value.isNotEmpty ? DateTime.tryParse(value) : null;
}
