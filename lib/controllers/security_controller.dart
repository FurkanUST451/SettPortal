import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../models/admin_info.dart';
import '../services/auth_service.dart';
import '../services/functions_service.dart';

class SecurityController extends GetxController {
  final _auth = Get.find<AuthService>();
  final _functions = FunctionsService();

  final RxBool loading = true.obs;
  final RxBool enrolled = false.obs;
  final RxBool busy = false.obs;
  final Rxn<TotpSecret> pendingSecret = Rxn<TotpSecret>();
  final RxnString qrUrl = RxnString();
  final RxnString errorText = RxnString();

  final RxList<AdminInfo> admins = <AdminInfo>[].obs;
  final RxBool adminsLoading = true.obs;
  final RxnString adminsError = RxnString();

  String? get currentUid => _auth.currentUser?.uid;

  @override
  void onInit() {
    super.onInit();
    reload();
    loadAdmins();
  }

  Future<void> reload() async {
    loading.value = true;
    enrolled.value = await _auth.hasTotpEnrolled();
    loading.value = false;
  }

  Future<void> loadAdmins() async {
    adminsLoading.value = true;
    adminsError.value = null;
    try {
      admins.assignAll(await _functions.listAdmins());
    } catch (e) {
      adminsError.value = 'Admin listesi alınamadı: $e';
    } finally {
      adminsLoading.value = false;
    }
  }

  Future<void> revokeAdmin(String uid) async {
    adminsLoading.value = true;
    try {
      await _functions.setAdminRole(uid: uid, isAdmin: false);
      await loadAdmins();
    } catch (e) {
      adminsError.value = 'Yetki kaldırılamadı: $e';
      adminsLoading.value = false;
    }
  }

  Future<void> startEnrollment() async {
    errorText.value = null;
    busy.value = true;
    try {
      final secret = await _auth.startTotpEnrollment();
      final url = await secret.generateQrCodeUrl(
        accountName: _auth.currentUser?.email,
        issuer: 'SET Admin Panel',
      );
      pendingSecret.value = secret;
      qrUrl.value = url;
    } catch (e) {
      errorText.value = 'Kurulum başlatılamadı: $e';
    } finally {
      busy.value = false;
    }
  }

  Future<void> confirmEnrollment(String code) async {
    final secret = pendingSecret.value;
    if (secret == null || code.trim().isEmpty) return;
    errorText.value = null;
    busy.value = true;
    try {
      await _auth.confirmTotpEnrollment(secret, code);
      pendingSecret.value = null;
      qrUrl.value = null;
      await reload();
    } catch (e) {
      errorText.value =
          'Kod doğrulanamadı, authenticator uygulamandaki güncel kodu dene.';
    } finally {
      busy.value = false;
    }
  }

  void cancelEnrollment() {
    pendingSecret.value = null;
    qrUrl.value = null;
    errorText.value = null;
  }

  Future<void> disable() async {
    busy.value = true;
    try {
      await _auth.unenrollTotp();
      await reload();
    } finally {
      busy.value = false;
    }
  }
}
