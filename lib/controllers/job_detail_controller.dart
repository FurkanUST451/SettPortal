import 'package:get/get.dart';

import '../models/app_user.dart';
import '../models/brief.dart';
import '../models/offer.dart';
import '../models/project.dart';
import '../repositories/project_repository.dart';
import '../repositories/user_repository.dart';

class JobDetailController extends GetxController {
  final String projectId;
  JobDetailController(this.projectId);

  final _repo = ProjectRepository();
  final _userRepo = UserRepository();

  final Rxn<Project> project = Rxn<Project>();
  final Rxn<Brief> brief = Rxn<Brief>();
  final Rxn<Offer> offer = Rxn<Offer>();
  final Rxn<AppUser> client = Rxn<AppUser>();
  final Rxn<AppUser> freelancer = Rxn<AppUser>();
  final RxBool loading = true.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    final p = await _repo.fetchById(projectId);
    project.value = p;
    if (p != null) {
      final briefId = p.briefId;
      final offerId = p.offerId;
      final results = await Future.wait([
        briefId != null ? _repo.fetchBrief(briefId) : Future.value(null),
        offerId != null ? _repo.fetchOffer(offerId) : Future.value(null),
        _userRepo.fetchById(p.clientId),
        _userRepo.fetchById(p.freelancerId),
      ]);
      brief.value = results[0] as Brief?;
      offer.value = results[1] as Offer?;
      client.value = results[2] as AppUser?;
      freelancer.value = results[3] as AppUser?;
    }
    loading.value = false;
  }
}
