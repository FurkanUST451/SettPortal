import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants.dart';
import '../models/app_user.dart';
import '../models/freelancer_profile.dart';

class UserRepository {
  static const pageSize = 25;

  final _col = FirebaseFirestore.instance.collection(FsCollections.users);
  final _freelancerCol = FirebaseFirestore.instance.collection(
    FsCollections.freelancers,
  );

  /// [startAfterCreatedAt] is the ISO8601 `createdAt` string of the last item
  /// on the previous page (cursor-based pagination without keeping raw
  /// `DocumentSnapshot`s around in the UI layer).
  Future<List<AppUser>> fetchPage({
    String? role,
    bool? banned,
    String? startAfterCreatedAt,
    int limit = pageSize,
  }) async {
    Query<Map<String, dynamic>> q = _col.orderBy('createdAt', descending: true);
    if (role != null && role.isNotEmpty) q = q.where('role', isEqualTo: role);
    if (banned != null) q = q.where('banned', isEqualTo: banned);
    q = q.limit(limit);
    if (startAfterCreatedAt != null) q = q.startAfter([startAfterCreatedAt]);
    final snap = await q.get();
    return snap.docs.map(AppUser.fromFirestore).toList();
  }

  /// Firestore has no full-text search; this does a case-sensitive prefix
  /// match on `email`. Appending `` (highest Unicode private-use code
  /// point) to the range end gives a "starts with" range query.
  Future<List<AppUser>> searchByEmailPrefix(
    String prefix, {
    int limit = pageSize,
  }) async {
    final snap = await _col
        .orderBy('email')
        .startAt([prefix])
        .endAt(['$prefix'])
        .limit(limit)
        .get();
    return snap.docs.map(AppUser.fromFirestore).toList();
  }

  Future<List<AppUser>> searchByNamePrefix(
    String prefix, {
    int limit = pageSize,
  }) async {
    final snap = await _col
        .orderBy('name')
        .startAt([prefix])
        .endAt(['$prefix'])
        .limit(limit)
        .get();
    return snap.docs.map(AppUser.fromFirestore).toList();
  }

  Future<AppUser?> fetchById(String uid) async {
    final doc = await _col.doc(uid).get();
    return doc.exists ? AppUser.fromFirestore(doc) : null;
  }

  /// Fetched one doc at a time (not a single `whereIn`) since callers pass
  /// small, ad-hoc id lists (e.g. a brief's `sentToIds`) where a batch query
  /// isn't worth the added complexity.
  Future<List<AppUser>> fetchByIds(List<String> uids) async {
    final results = await Future.wait(uids.map(fetchById));
    return results.whereType<AppUser>().toList();
  }

  Future<FreelancerProfile?> fetchFreelancerProfile(String uid) async {
    final doc = await _freelancerCol.doc(uid).get();
    return doc.exists ? FreelancerProfile.fromFirestore(doc) : null;
  }

  Future<int> countAll() async => (await _col.count().get()).count ?? 0;

  Future<int> countByRole(String role) async {
    final agg = await _col.where('role', isEqualTo: role).count().get();
    return agg.count ?? 0;
  }

  Future<int> countCreatedSince(DateTime since) async {
    final agg = await _col
        .where('createdAt', isGreaterThanOrEqualTo: since.toIso8601String())
        .count()
        .get();
    return agg.count ?? 0;
  }
}
