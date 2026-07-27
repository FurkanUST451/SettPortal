import 'package:get/get.dart';

import '../routes/app_routes.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final auth = Get.find<AuthService>();

  final RxBool loading = false.obs;
  final RxnString errorText = RxnString();

  Future<void> submit(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      errorText.value = 'E-posta ve şifre gerekli.';
      return;
    }
    loading.value = true;
    errorText.value = null;
    final error = await auth.signIn(email, password);
    loading.value = false;
    if (error != null) {
      errorText.value = error;
      return;
    }
    // If a 2FA challenge is now pending, auth.mfaResolver is set and the
    // login screen switches to the code form instead of navigating away.
    if (auth.mfaResolver.value != null) return;
    Get.offAllNamed(AppRoutes.dashboard);
  }

  Future<void> submitMfaCode(String code) async {
    if (code.trim().isEmpty) {
      errorText.value = 'Doğrulama kodu gerekli.';
      return;
    }
    loading.value = true;
    errorText.value = null;
    final error = await auth.submitMfaCode(code);
    loading.value = false;
    if (error != null) {
      errorText.value = error;
      return;
    }
    Get.offAllNamed(AppRoutes.dashboard);
  }

  void cancelMfa() {
    auth.cancelMfaChallenge();
    errorText.value = null;
  }
}
