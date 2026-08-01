import 'package:get/get.dart';

import '../models/app_user.dart';
import '../models/brief.dart';
import '../repositories/project_repository.dart';
import '../repositories/user_repository.dart';

class BriefDetailController extends GetxController {
  final String briefId;
  BriefDetailController(this.briefId);

  final _projectRepo = ProjectRepository();
  final _userRepo = UserRepository();

  final Rxn<Brief> brief = Rxn<Brief>();
  final Rxn<AppUser> owner = Rxn<AppUser>();
  final RxList<AppUser> sentTo = <AppUser>[].obs;
  final RxBool loading = true.obs;

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
}
