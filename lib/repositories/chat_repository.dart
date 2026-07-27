import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants.dart';
import '../models/chat.dart';
import '../models/chat_message.dart';

class ChatRepository {
  static const pageSize = 25;

  final _col = FirebaseFirestore.instance.collection(FsCollections.chats);

  /// Ordered by `createdAt` (always present) rather than `lastMessageAt`
  /// (optional) — Firestore's orderBy excludes documents missing the sort
  /// field entirely, which would silently hide brand-new chats.
  Future<List<Chat>> fetchPage({
    String? startAfterCreatedAt,
    int limit = pageSize,
  }) async {
    Query<Map<String, dynamic>> q = _col
        .orderBy('createdAt', descending: true)
        .limit(limit);
    if (startAfterCreatedAt != null) q = q.startAfter([startAfterCreatedAt]);
    final snap = await q.get();
    return snap.docs.map(Chat.fromFirestore).toList();
  }

  Future<Chat?> fetchById(String id) async {
    final doc = await _col.doc(id).get();
    return doc.exists ? Chat.fromFirestore(doc) : null;
  }

  Stream<List<ChatMessage>> watchMessages(String chatId) {
    return _col
        .doc(chatId)
        .collection(FsCollections.messages)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((s) => s.docs.map(ChatMessage.fromFirestore).toList());
  }
}
