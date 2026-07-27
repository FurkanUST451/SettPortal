import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/theme.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'services/auth_service.dart';

class SetAdminApp extends StatelessWidget {
  const SetAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthService>();
    final initialRoute = (auth.firebaseUser.value != null && auth.isAdmin.value)
        ? AppRoutes.dashboard
        : AppRoutes.login;

    return GetMaterialApp(
      title: 'SET Admin Panel',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: initialRoute,
      getPages: AppPages.pages,
    );
  }
}
