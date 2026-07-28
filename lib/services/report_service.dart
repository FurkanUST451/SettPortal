import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants.dart';

/// Reads the `reports` collection the mobile app writes to when a user
/// reports a Keşfet feed item. Admin-only via firestore.rules; the panel
/// never writes here directly — status changes go through a Cloud Function
/// once one exists (currently view-only).
class ReportService {
  final _col = FirebaseFirestore.instance.collection(FsCollections.reports);

  Stream<QuerySnapshot<Map<String, dynamic>>> watchRecent({int limit = 200}) {
    return _col.orderBy('createdAt', descending: true).limit(limit).snapshots();
  }
}
