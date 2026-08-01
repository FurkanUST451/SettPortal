import 'package:get/get.dart';

import '../models/app_user.dart';
import '../models/brief.dart';
import '../models/offer.dart';
import '../repositories/project_repository.dart';
import '../repositories/user_repository.dart';

class OfferDetailController extends GetxController {
  final String offerId;
  OfferDetailController(this.offerId);

  final _projectRepo = ProjectRepository();
  final _userRepo = UserRepository();

  final Rxn<Offer> offer = Rxn<Offer>();
  final Rxn<Brief> brief = Rxn<Brief>();
  final Rxn<AppUser> sender = Rxn<AppUser>();
  final Rxn<AppUser> receiver = Rxn<AppUser>();
  final RxBool loading = true.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    final o = await _projectRepo.fetchOffer(offerId);
    offer.value = o;
    if (o != null) {
      final results = await Future.wait([
        _userRepo.fetchById(o.senderId),
        _userRepo.fetchById(o.receiverId),
        if (o.briefId.isNotEmpty) _projectRepo.fetchBrief(o.briefId),
      ]);
      sender.value = results[0] as AppUser?;
      receiver.value = results[1] as AppUser?;
      if (o.briefId.isNotEmpty) brief.value = results[2] as Brief?;
    }
    loading.value = false;
  }
}
