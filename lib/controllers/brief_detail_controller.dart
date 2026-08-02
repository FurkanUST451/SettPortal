import 'package:get/get.dart';

import '../models/app_user.dart';
import '../models/brief.dart';
import '../repositories/project_repository.dart';
import '../repositories/user_repository.dart';
import '../services/audit_log_service.dart';

class BriefDetailController extends GetxController {
  final String briefId;
  BriefDetailController(this.briefId);

  final _projectRepo = ProjectRepository();
  final _userRepo = UserRepository();
  final _auditLog = AuditLogService();

  final Rxn<Brief> brief = Rxn<Brief>();
  final Rxn<AppUser> owner = Rxn<AppUser>();
  final RxList<AppUser> sentTo = <AppUser>[].obs;
  final RxBool loading = true.obs;
  final RxBool actionLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    final b = await _projectRepo.fetchBrief(briefId);
    brief.value = b;
    if (b != null) {
      owner.value = await _userRepo.fetchById(b.ownerId);
      sentTo.assignAll(await _userRepo.fetchByIds(b.sentToIds));
    }
    loading.value = false;
  }

  Future<void> saveEdits({
    required String title,
    required String category,
    required String status,
  }) async {
    actionLoading.value = true;
    try {
      await _projectRepo.updateBrief(
        briefId,
        title: title,
        category: category,
        status: status,
      );
      await _auditLog.logEditBrief(briefId);
      await load();
    } finally {
      actionLoading.value = false;
    }
  }

  Future<void> delete() async {
    actionLoading.value = true;
    try {
      await _projectRepo.deleteBrief(briefId);
      await _auditLog.logDeleteBrief(briefId);
    } finally {
      actionLoading.value = false;
    }
  }
}
