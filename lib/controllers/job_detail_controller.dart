import 'package:get/get.dart';

import '../models/brief.dart';
import '../models/offer.dart';
import '../models/project.dart';
import '../repositories/project_repository.dart';

class JobDetailController extends GetxController {
  final String projectId;
  JobDetailController(this.projectId);

  final _repo = ProjectRepository();

  final Rxn<Project> project = Rxn<Project>();
  final Rxn<Brief> brief = Rxn<Brief>();
  final Rxn<Offer> offer = Rxn<Offer>();
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
    if (p?.briefId != null) brief.value = await _repo.fetchBrief(p!.briefId!);
    if (p?.offerId != null) offer.value = await _repo.fetchOffer(p!.offerId!);
    loading.value = false;
  }
}
