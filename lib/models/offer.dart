import 'package:cloud_firestore/cloud_firestore.dart';

/// Mirrors the mobile app's `offers/{offerId}` document.
class Offer {
  final String id;
  final String chatId;
  final String briefId;
  final String briefTitle;
  final String senderId;
  final String receiverId;
  final double amount;
  final String message;
  final String status; // pending | accepted | rejected
  final DateTime? createdAt;

  const Offer({
    required this.id,
    required this.chatId,
    required this.briefId,
    required this.briefTitle,
    required this.senderId,
    required this.receiverId,
    required this.amount,
    required this.message,
    required this.status,
    this.createdAt,
  });

  factory Offer.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Offer(
      id: doc.id,
      chatId: (data['chatId'] as String?) ?? '',
      briefId: (data['briefId'] as String?) ?? '',
      briefTitle: (data['briefTitle'] as String?) ?? '',
      senderId: (data['senderId'] as String?) ?? '',
      receiverId: (data['receiverId'] as String?) ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      message: (data['message'] as String?) ?? '',
      status: (data['status'] as String?) ?? 'pending',
      createdAt: _parseIso(data['createdAt']),
    );
  }

  static DateTime? _parseIso(dynamic value) =>
      value is String && value.isNotEmpty ? DateTime.tryParse(value) : null;
}
