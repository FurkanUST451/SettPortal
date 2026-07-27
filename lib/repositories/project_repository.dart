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

  Future<Brief?> fetchBrief(String id) async {
    final doc = await _briefCol.doc(id).get();
    return doc.exists ? Brief.fromFirestore(doc) : null;
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
}
