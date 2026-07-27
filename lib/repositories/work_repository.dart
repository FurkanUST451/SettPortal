import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants.dart';
import '../models/work.dart';
import '../models/work_comment.dart';
import '../models/work_like.dart';

class WorkRepository {
  static const pageSize = 25;

  final _col = FirebaseFirestore.instance.collection(FsCollections.works);

  Future<List<Work>> fetchPage({
    String? type,
    bool? flaggedOnly,
    String? startAfterCreatedAt,
    int limit = pageSize,
  }) async {
    Query<Map<String, dynamic>> q = _col.orderBy('createdAt', descending: true);
    if (type != null && type.isNotEmpty) q = q.where('type', isEqualTo: type);
    if (flaggedOnly == true) q = q.where('flagged', isEqualTo: true);
    q = q.limit(limit);
    if (startAfterCreatedAt != null) q = q.startAfter([startAfterCreatedAt]);
    final snap = await q.get();
    return snap.docs.map(Work.fromFirestore).toList();
  }

  Future<Work?> fetchById(String id) async {
    final doc = await _col.doc(id).get();
    return doc.exists ? Work.fromFirestore(doc) : null;
  }

  Stream<List<WorkComment>> watchComments(String workId) {
    return _col
        .doc(workId)
        .collection(FsCollections.comments)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (s) =>
              s.docs.map((d) => WorkComment.fromFirestore(workId, d)).toList(),
        );
  }

  Stream<List<WorkLike>> watchLikes(String workId) {
    return _col
        .doc(workId)
        .collection(FsCollections.likes)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (s) => s.docs.map((d) => WorkLike.fromFirestore(workId, d)).toList(),
        );
  }

  Future<int> countAll() async => (await _col.count().get()).count ?? 0;

  Future<int> countFlagged() async {
    final agg = await _col.where('flagged', isEqualTo: true).count().get();
    return agg.count ?? 0;
  }
}
