import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../services/auth_service.dart';
import 'app_routes.dart';

/// Blocks any protected route unless the signed-in user's Firebase Auth ID
/// token carries the `admin` custom claim (checked once at startup and
/// re-checked on every sign-in; see AuthService.refreshAdminClaim).
class AdminGuardMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final auth = Get.find<AuthService>();
    final isAuthorizedAdmin =
        auth.firebaseUser.value != null && auth.isAdmin.value;
    if (!isAuthorizedAdmin) {
      return const RouteSettings(name: AppRoutes.login);
    }
    return null;
  }
}

/// Keeps an already-authenticated admin off the login screen.
class GuestOnlyMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final auth = Get.find<AuthService>();
    if (auth.firebaseUser.value != null && auth.isAdmin.value) {
      return const RouteSettings(name: AppRoutes.dashboard);
    }
    return null;
  }
}
