import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants.dart';
import '../models/brief.dart';
import '../models/offer.dart';
import '../models/project.dart';

/// Covers `projects` (the primary "iş/anlaşma" entity) plus read-only lookups
/// into the `briefs`/`offers` that a project originated from, for the detail
/// view. There is no "disputed" status in the current data model (see
/// project memory) — filtering only covers the four real lifecycle statuses.
class ProjectRepository {
  static const pageSize = 25;

  final _col = FirebaseFirestore.instance.collection(FsCollections.projects);
  final _briefCol = FirebaseFirestore.instance.collection(FsCollections.briefs);
  final _offerCol = FirebaseFirestore.instance.collection(FsCollections.offers);

  Future<List<Project>> fetchPage({
    String? status,
    String? startAfterCreatedAt,
    int limit = pageSize,
  }) async {
    Query<Map<String, dynamic>> q = _col.orderBy('createdAt', descending: true);
    if (status != null && status.isNotEmpty) {
      q = q.where('status', isEqualTo: status);
    }
    q = q.limit(limit);
    if (startAfterCreatedAt != null) q = q.startAfter([startAfterCreatedAt]);
    final snap = await q.get();
    return snap.docs.map(Project.fromFirestore).toList();
  }

  Future<Project?> fetchById(String id) async {
    final doc = await _col.doc(id).get();
    return doc.exists ? Project.fromFirestore(doc) : null;
  }

  Future<List<Brief>> fetchBriefsPage({
    String? status,
    String? startAfterCreatedAt,
    int limit = pageSize,
  }) async {
    Query<Map<String, dynamic>> q = _briefCol.orderBy(
      'createdAt',
      descending: true,
    );
    if (status != null && status.isNotEmpty) {
      q = q.where('status', isEqualTo: status);
    }
    q = q.limit(limit);
    if (startAfterCreatedAt != null) q = q.startAfter([startAfterCreatedAt]);
    final snap = await q.get();
    return snap.docs.map(Brief.fromFirestore).toList();
  }

  Future<Brief?> fetchBrief(String id) async {
    final doc = await _briefCol.doc(id).get();
    return doc.exists ? Brief.fromFirestore(doc) : null;
  }

  Future<void> updateBrief(
    String id, {
    required String title,
    required String category,
    required String status,
  }) async {
    await _briefCol.doc(id).update({
      'title': title,
      'category': category,
      'status': status,
    });
  }

  Future<void> deleteBrief(String id) async {
    await _briefCol.doc(id).delete();
  }

  Future<Offer?> fetchOffer(String id) async {
    final doc = await _offerCol.doc(id).get();
    return doc.exists ? Offer.fromFirestore(doc) : null;
  }

  Future<int> countAll() async => (await _col.count().get()).count ?? 0;

  Future<int> countByStatus(String status) async {
    final agg = await _col.where('status', isEqualTo: status).count().get();
    return agg.count ?? 0;
  }

  Future<List<Brief>> fetchBriefsForOwner(String uid) async {
    final snap = await _briefCol.where('ownerId', isEqualTo: uid).get();
    final briefs = snap.docs.map(Brief.fromFirestore).toList();
    briefs.sort((a, b) {
      if (a.createdAt == null || b.createdAt == null) return 0;
      return b.createdAt!.compareTo(a.createdAt!);
    });
    return briefs;
  }

  /// A user is either the sender OR receiver of an offer, never both at
  /// once, so two single-field queries and a merge (same pattern as
  /// [ChatRepository.fetchForUser]) is enough — no dedupe needed.
  Future<List<Offer>> fetchOffersForUser(String uid) async {
    final results = await Future.wait([
      _offerCol.where('senderId', isEqualTo: uid).get(),
      _offerCol.where('receiverId', isEqualTo: uid).get(),
    ]);
    final offers = [
      ...results[0].docs.map(Offer.fromFirestore),
      ...results[1].docs.map(Offer.fromFirestore),
    ];
    offers.sort((a, b) {
      if (a.createdAt == null || b.createdAt == null) return 0;
      return b.createdAt!.compareTo(a.createdAt!);
    });
    return offers;
  }

  /// A user is either the client OR the freelancer side of a project, never
  /// both at once, so two single-field queries and a merge is enough.
  Future<List<Project>> fetchProjectsForUser(String uid) async {
    final results = await Future.wait([
      _col.where('clientId', isEqualTo: uid).get(),
      _col.where('freelancerId', isEqualTo: uid).get(),
    ]);
    final projects = [
      ...results[0].docs.map(Project.fromFirestore),
      ...results[1].docs.map(Project.fromFirestore),
    ];
    projects.sort((a, b) {
      if (a.createdAt == null || b.createdAt == null) return 0;
      return b.createdAt!.compareTo(a.createdAt!);
    });
    return projects;
  }
}
