import 'package:cloud_firestore/cloud_firestore.dart';

/// Mirrors the mobile app's `projects/{projectId}` document — this is the
/// "iş/anlaşma" (job/agreement) entity created when a client accepts an offer.
/// There is no dispute/anlaşmazlık status in the current data model; only the
/// four lifecycle statuses below exist.
class Project {
  final String id;
  final String clientId;
  final String freelancerId;
  final String status; // pending | active | completed | cancelled
  final String title;
  final String description;
  final double budget;
  final DateTime? createdAt;
  final String? offerId;
  final String? briefId;
  final String? chatId;
  final DateTime? deadline;
  final String? category;
  final String? location;

  const Project({
    required this.id,
    required this.clientId,
    required this.freelancerId,
    required this.status,
    required this.title,
    required this.description,
    required this.budget,
    this.createdAt,
    this.offerId,
    this.briefId,
    this.chatId,
    this.deadline,
    this.category,
    this.location,
  });

  factory Project.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Project(
      id: doc.id,
      clientId: (data['clientId'] as String?) ?? '',
      freelancerId: (data['freelancerId'] as String?) ?? '',
      status: (data['status'] as String?) ?? 'pending',
      title: (data['title'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      budget: (data['budget'] as num?)?.toDouble() ?? 0,
      createdAt: _parseIso(data['createdAt']),
      offerId: data['offerId'] as String?,
      briefId: data['briefId'] as String?,
      chatId: data['chatId'] as String?,
      deadline: _parseIso(data['deadline']),
      category: data['category'] as String?,
      location: data['location'] as String?,
    );
  }

  static DateTime? _parseIso(dynamic value) =>
      value is String && value.isNotEmpty ? DateTime.tryParse(value) : null;
}
