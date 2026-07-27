import 'package:get/get.dart';

import '../core/constants.dart';
import '../repositories/project_repository.dart';
import '../repositories/user_repository.dart';
import '../repositories/work_repository.dart';
import '../services/auth_service.dart';

class DashboardController extends GetxController {
  final _userRepo = UserRepository();
  final _projectRepo = ProjectRepository();
  final _workRepo = WorkRepository();
  final _auth = Get.find<AuthService>();

  final RxBool loading = true.obs;
  final RxBool mfaEnrolled =
      true.obs; // optimistic default, avoids a flash of the banner
  final RxInt totalUsers = 0.obs;
  final RxInt totalClients = 0.obs;
  final RxInt totalFreelancers = 0.obs;
  final RxInt newUsersToday = 0.obs;
  final RxInt totalProjects = 0.obs;
  final RxInt activeProjects = 0.obs;
  final RxInt completedProjects = 0.obs;
  final RxInt flaggedWorks = 0.obs;

  @override
  void onInit() {
    super.onInit();
    reload();
  }

  Future<void> reload() async {
    loading.value = true;
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);

    final results = await Future.wait([
      _userRepo.countAll(),
      _userRepo.countByRole(UserRole.client),
      _userRepo.countByRole(UserRole.freelancer),
      _userRepo.countCreatedSince(startOfToday),
      _projectRepo.countAll(),
      _projectRepo.countByStatus(ProjectStatus.active),
      _projectRepo.countByStatus(ProjectStatus.completed),
      _workRepo.countFlagged(),
    ]);

    totalUsers.value = results[0];
    totalClients.value = results[1];
    totalFreelancers.value = results[2];
    newUsersToday.value = results[3];
    totalProjects.value = results[4];
    activeProjects.value = results[5];
    completedProjects.value = results[6];
    flaggedWorks.value = results[7];

    mfaEnrolled.value = await _auth.hasTotpEnrolled();

    loading.value = false;
  }
}
