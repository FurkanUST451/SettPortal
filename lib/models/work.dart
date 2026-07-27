import 'package:cloud_firestore/cloud_firestore.dart';

/// Mirrors the mobile app's `works/{workId}` document (the freelancer's public
/// "showreel" feed). `flagged`/`flaggedReason`/`flaggedAt`/`flaggedBy` are
/// admin-only fields written exclusively by the `flagWork`/`unflagWork`
/// Cloud Functions — the mobile app does not read or write them.
class Work {
  final String id;
  final String title;
  final String studio;
  final String type; // video | photo | cgiVfx | graphic | sound
  final int likeCount;
  final int commentCount;
  final String? coverImage;
  final String? freelancerId;
  final String? description;
  final String? mediaUrl;
  final bool isVideo;
  final DateTime? createdAt;
  final bool flagged;
  final String? flaggedReason;
  final DateTime? flaggedAt;

  const Work({
    required this.id,
    required this.title,
    required this.studio,
    required this.type,
    this.likeCount = 0,
    this.commentCount = 0,
    this.coverImage,
    this.freelancerId,
    this.description,
    this.mediaUrl,
    this.isVideo = false,
    this.createdAt,
    this.flagged = false,
    this.flaggedReason,
    this.flaggedAt,
  });

  factory Work.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Work(
      id: doc.id,
      title: (data['title'] as String?) ?? '',
      studio: (data['studio'] as String?) ?? '',
      type: (data['type'] as String?) ?? 'video',
      likeCount: (data['likes'] as num?)?.toInt() ?? 0,
      commentCount: (data['comments'] as num?)?.toInt() ?? 0,
      coverImage: data['coverImage'] as String?,
      freelancerId: data['freelancerId'] as String?,
      description: data['description'] as String?,
      mediaUrl: data['mediaUrl'] as String?,
      isVideo: data['isVideo'] as bool? ?? false,
      createdAt: _parseIso(data['createdAt']),
      flagged: data['flagged'] as bool? ?? false,
      flaggedReason: data['flaggedReason'] as String?,
      flaggedAt: _parseIso(data['flaggedAt']),
    );
  }

  static DateTime? _parseIso(dynamic value) =>
      value is String && value.isNotEmpty ? DateTime.tryParse(value) : null;
}
