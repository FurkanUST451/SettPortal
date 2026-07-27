import 'package:cloud_firestore/cloud_firestore.dart';

/// Mirrors the mobile app's `freelancers/{uid}` document (1:1 with `users/{uid}`).
class FreelancerProfile {
  final String userId;
  final String name;
  final String? surname;
  final List<String> categories;
  final String bio;
  final int experience;
  final String location;
  final double rating;
  final List<String> portfolio;
  final String? profileImageUrl;

  const FreelancerProfile({
    required this.userId,
    required this.name,
    this.surname,
    this.categories = const [],
    this.bio = '',
    this.experience = 0,
    this.location = '',
    this.rating = 0,
    this.portfolio = const [],
    this.profileImageUrl,
  });

  factory FreelancerProfile.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return FreelancerProfile(
      userId: (data['userId'] as String?) ?? doc.id,
      name: (data['name'] as String?) ?? '',
      surname: data['surname'] as String?,
      categories: (data['categories'] as List?)?.cast<String>() ?? const [],
      bio: (data['bio'] as String?) ?? '',
      experience: (data['experience'] as num?)?.toInt() ?? 0,
      location: (data['location'] as String?) ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
      portfolio: (data['portfolio'] as List?)?.cast<String>() ?? const [],
      profileImageUrl: data['profileImageUrl'] as String?,
    );
  }
}
