import 'package:cloud_firestore/cloud_firestore.dart';

/// Mirrors the mobile app's `chats/{chatId}/messages/{messageId}` document.
class ChatMessage {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final DateTime? createdAt;
  final String type; // text | offer
  final String? offerId;

  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    this.createdAt,
    required this.type,
    this.offerId,
  });

  factory ChatMessage.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return ChatMessage(
      id: doc.id,
      chatId: (data['chatId'] as String?) ?? '',
      senderId: (data['senderId'] as String?) ?? '',
      content: (data['content'] as String?) ?? '',
      createdAt: _parseIso(data['createdAt']),
      type: (data['type'] as String?) ?? 'text',
      offerId: data['offerId'] as String?,
    );
  }

  static DateTime? _parseIso(dynamic value) =>
      value is String && value.isNotEmpty ? DateTime.tryParse(value) : null;
}
