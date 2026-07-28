import 'dart:async';

import 'package:get/get.dart';

import '../core/constants.dart';
import '../models/report.dart';
import '../services/report_service.dart';

class ReportsController extends GetxController {
  final _service = ReportService();

  final RxList<Report> reports = <Report>[].obs;
  final RxBool loading = true.obs;
  final RxnString statusFilter = RxnString(ReportStatus.pending);

  StreamSubscription? _sub;

  @override
  void onInit() {
    super.onInit();
    _sub = _service.watchRecent().listen((snap) {
      reports.assignAll(snap.docs.map(Report.fromFirestore));
      loading.value = false;
    });
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  List<Report> get filtered {
    final status = statusFilter.value;
    if (status == null || status.isEmpty) return reports;
    return reports.where((r) => r.status == status).toList();
  }

  void setStatusFilter(String? status) {
    statusFilter.value = status;
  }
}
