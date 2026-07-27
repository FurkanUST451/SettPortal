import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/constants.dart';
import '../models/audit_log_entry.dart';

/// Writes audit trail entries directly to Firestore for NON-destructive admin
/// actions (viewing a conversation, opening a user's detail page). Destructive
/// actions are logged server-side by the Cloud Function that performs them
/// (see functions/index.js) so the log write can't be skipped by the client.
///
/// firestore.rules only allows this collection's `create` when
/// `request.resource.data.adminUid == request.auth.uid` and the caller has
/// the admin claim, so a client can log actions for itself only.
class AuditLogService {
  final _col = FirebaseFirestore.instance.collection(FsCollections.auditLogs);

  Future<void> log({
    required String action,
    String? targetType,
    String? targetId,
    Map<String, dynamic> metadata = const {},
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final entry = AuditLogEntry(
      id: '',
      adminUid: user.uid,
      adminEmail: user.email,
      action: action,
      targetType: targetType,
      targetId: targetId,
      metadata: metadata,
    );
    await _col.add(entry.toCreateMap());
  }

  Future<void> logViewConversation(String chatId) => log(
    action: AuditAction.viewConversation,
    targetType: 'chat',
    targetId: chatId,
  );

  Future<void> logViewUserDetail(String uid) => log(
    action: AuditAction.viewUserDetail,
    targetType: 'user',
    targetId: uid,
  );

  Stream<QuerySnapshot<Map<String, dynamic>>> watchRecent({int limit = 200}) {
    return _col.orderBy('createdAt', descending: true).limit(limit).snapshots();
  }
}
