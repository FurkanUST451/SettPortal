import 'package:cloud_functions/cloud_functions.dart';

import '../core/constants.dart';
import '../models/admin_info.dart';

/// Thin wrapper around the deployed callable Cloud Functions
/// (functions/index.js). Every destructive/sensitive action goes through
/// here instead of writing to Firestore directly from the client.
class FunctionsService {
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: 'europe-west1',
  );

  Future<void> setAdminRole({required String uid, required bool isAdmin}) =>
      _call(CallableFunctions.setAdminRole, {'uid': uid, 'isAdmin': isAdmin});

  Future<List<AdminInfo>> listAdmins() async {
    try {
      final result = await _functions
          .httpsCallable(CallableFunctions.listAdmins)
          .call();
      final admins = (result.data['admins'] as List)
          .cast<Map<Object?, Object?>>();
      return admins
          .map((m) => AdminInfo.fromMap(m.cast<String, dynamic>()))
          .toList();
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'Admin listesi alınamadı (${e.code}).');
    }
  }

  Future<void> banUser({required String uid, required String reason}) =>
      _call(CallableFunctions.banUser, {'uid': uid, 'reason': reason});

  Future<void> unbanUser({required String uid}) =>
      _call(CallableFunctions.unbanUser, {'uid': uid});

  Future<void> flagWork({required String workId, required String reason}) =>
      _call(CallableFunctions.flagWork, {'workId': workId, 'reason': reason});

  Future<void> unflagWork({required String workId}) =>
      _call(CallableFunctions.unflagWork, {'workId': workId});

  Future<void> deleteWork({required String workId}) =>
      _call(CallableFunctions.deleteWork, {'workId': workId});

  Future<void> deleteWorkComment({
    required String workId,
    required String commentId,
  }) => _call(CallableFunctions.deleteWorkComment, {
    'workId': workId,
    'commentId': commentId,
  });

  Future<void> deleteWorkLike({
    required String workId,
    required String likeId,
  }) => _call(CallableFunctions.deleteWorkLike, {
    'workId': workId,
    'likeId': likeId,
  });

  Future<void> _call(String name, Map<String, dynamic> data) async {
    try {
      await _functions.httpsCallable(name).call(data);
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'İşlem başarısız oldu (${e.code}).');
    }
  }
}
