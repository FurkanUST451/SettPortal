import 'package:cloud_firestore/cloud_firestore.dart';

/// Mirrors the mobile app's `chats/{chatId}` document.
class Chat {
  final String id;
  final String clientId;
  final String clientName;
  final String freelancerId;
  final String freelancerName;
  final String briefId;
  final String briefTitle;
  final DateTime? createdAt;
  final String? lastMessage;
  final DateTime? lastMessageAt;

  const Chat({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.freelancerId,
    required this.freelancerName,
    required this.briefId,
    required this.briefTitle,
    this.createdAt,
    this.lastMessage,
    this.lastMessageAt,
  });

  factory Chat.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Chat(
      id: doc.id,
      clientId: (data['clientId'] as String?) ?? '',
      clientName: (data['clientName'] as String?) ?? '',
      freelancerId: (data['freelancerId'] as String?) ?? '',
      freelancerName: (data['freelancerName'] as String?) ?? '',
      briefId: (data['briefId'] as String?) ?? '',
      briefTitle: (data['briefTitle'] as String?) ?? '',
      createdAt: _parseIso(data['createdAt']),
      lastMessage: data['lastMessage'] as String?,
      lastMessageAt: _parseIso(data['lastMessageAt']),
    );
  }

  static DateTime? _parseIso(dynamic value) =>
      value is String && value.isNotEmpty ? DateTime.tryParse(value) : null;
}
