import 'package:cloud_firestore/cloud_firestore.dart';

/// Mirrors `auditLogs/{id}` — an append-only trail of every admin action.
/// Written either by a Cloud Function (destructive actions, as part of the
/// same operation) or directly by the panel for non-destructive view actions
/// (e.g. opening a conversation), gated by firestore.rules to admin-only
/// creates where `adminUid == request.auth.uid`.
class AuditLogEntry {
  final String id;
  final String adminUid;
  final String? adminEmail;
  final String action;
  final String? targetType;
  final String? targetId;
  final Map<String, dynamic> metadata;
  final DateTime? createdAt;

  const AuditLogEntry({
    required this.id,
    required this.adminUid,
    this.adminEmail,
    required this.action,
    this.targetType,
    this.targetId,
    this.metadata = const {},
    this.createdAt,
  });

  factory AuditLogEntry.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return AuditLogEntry(
      id: doc.id,
      adminUid: (data['adminUid'] as String?) ?? '',
      adminEmail: data['adminEmail'] as String?,
      action: (data['action'] as String?) ?? '',
      targetType: data['targetType'] as String?,
      targetId: data['targetId'] as String?,
      metadata: (data['metadata'] as Map?)?.cast<String, dynamic>() ?? const {},
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toCreateMap() => {
    'adminUid': adminUid,
    'adminEmail': adminEmail,
    'action': action,
    'targetType': targetType,
    'targetId': targetId,
    'metadata': metadata,
    'createdAt': FieldValue.serverTimestamp(),
  };
}
