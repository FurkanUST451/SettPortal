import 'package:get/get.dart';

import '../core/constants.dart';
import '../models/app_user.dart';
import '../models/brief.dart';
import '../models/chat.dart';
import '../models/freelancer_profile.dart';
import '../models/offer.dart';
import '../models/project.dart';
import '../repositories/chat_repository.dart';
import '../repositories/project_repository.dart';
import '../repositories/user_repository.dart';
import '../services/audit_log_service.dart';
import '../services/functions_service.dart';

class UserDetailController extends GetxController {
  final String uid;
  UserDetailController(this.uid);

  final _repo = UserRepository();
  final _chatRepo = ChatRepository();
  final _projectRepo = ProjectRepository();
  final _functions = FunctionsService();
  final _auditLog = AuditLogService();

  final Rxn<AppUser> user = Rxn<AppUser>();
  final Rxn<FreelancerProfile> freelancerProfile = Rxn<FreelancerProfile>();
  final RxBool loading = true.obs;
  final RxBool actionLoading = false.obs;
  final RxBool isAdmin = false.obs;
  final RxBool adminStatusLoading = true.obs;

  final RxList<Chat> chats = <Chat>[].obs;
  final RxBool chatsLoading = true.obs;

  final RxList<Brief> briefs = <Brief>[].obs;
  final RxBool briefsLoading = true.obs;

  final RxList<Offer> offers = <Offer>[].obs;
  final RxBool offersLoading = true.obs;

  final RxList<Project> projects = <Project>[].obs;
  final RxBool projectsLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    load();
    _loadAdminStatus();
    _loadChats();
    _loadBriefs();
    _loadOffers();
    _loadProjects();
  }

  Future<void> _loadChats() async {
    chatsLoading.value = true;
    chats.assignAll(await _chatRepo.fetchForUser(uid));
    chatsLoading.value = false;
  }

  Future<void> _loadBriefs() async {
    briefsLoading.value = true;
    briefs.assignAll(await _projectRepo.fetchBriefsForOwner(uid));
    briefsLoading.value = false;
  }

  Future<void> _loadOffers() async {
    offersLoading.value = true;
    offers.assignAll(await _projectRepo.fetchOffersForUser(uid));
    offersLoading.value = false;
  }

  Future<void> _loadProjects() async {
    projectsLoading.value = true;
    projects.assignAll(await _projectRepo.fetchProjectsForUser(uid));
    projectsLoading.value = false;
  }

  Future<void> load() async {
    loading.value = true;
    final u = await _repo.fetchById(uid);
    user.value = u;
    if (u?.role == UserRole.freelancer) {
      freelancerProfile.value = await _repo.fetchFreelancerProfile(uid);
    }
    await _auditLog.logViewUserDetail(uid);
    loading.value = false;
  }

  /// Admin status lives in a Firebase Auth custom claim, not Firestore, so
  /// there's no cheap way to read it for a single user — this reuses the
  /// same `listAdmins` Cloud Function the Security screen uses and checks
  /// membership.
  Future<void> _loadAdminStatus() async {
    adminStatusLoading.value = true;
    try {
      final admins = await _functions.listAdmins();
      isAdmin.value = admins.any((a) => a.uid == uid);
    } finally {
      adminStatusLoading.value = false;
    }
  }

  Future<void> ban(String reason) async {
    actionLoading.value = true;
    try {
      await _functions.banUser(uid: uid, reason: reason);
      await load();
    } finally {
      actionLoading.value = false;
    }
  }

  Future<void> unban() async {
    actionLoading.value = true;
    try {
      await _functions.unbanUser(uid: uid);
      await load();
    } finally {
      actionLoading.value = false;
    }
  }

  Future<void> toggleAdmin() async {
    actionLoading.value = true;
    try {
      await _functions.setAdminRole(uid: uid, isAdmin: !isAdmin.value);
      await _loadAdminStatus();
    } finally {
      actionLoading.value = false;
    }
  }
}
