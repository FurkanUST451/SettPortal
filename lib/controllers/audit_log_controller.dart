import 'dart:async';

import 'package:get/get.dart';

import '../models/audit_log_entry.dart';
import '../services/audit_log_service.dart';

class AuditLogController extends GetxController {
  final _service = AuditLogService();

  final RxList<AuditLogEntry> entries = <AuditLogEntry>[].obs;
  final RxBool loading = true.obs;
  final RxnString actionFilter = RxnString();

  StreamSubscription? _sub;

  @override
  void onInit() {
    super.onInit();
    _sub = _service.watchRecent().listen((snap) {
      entries.assignAll(snap.docs.map(AuditLogEntry.fromFirestore));
      loading.value = false;
    });
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  List<AuditLogEntry> get filtered {
    final action = actionFilter.value;
    if (action == null || action.isEmpty) return entries;
    return entries.where((e) => e.action == action).toList();
  }

  void setActionFilter(String? action) {
    actionFilter.value = action;
  }
}
