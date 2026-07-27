import 'dart:async';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app.dart';
import 'core/constants.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // App Check enforcement isn't turned on for anything yet (see
  // functions/index.js), so this is best-effort: skip entirely until a real
  // site key replaces the placeholder, and never `await` it — a slow or
  // blocked reCAPTCHA script load must not be able to hang app boot / login.
  if (AppCheckConfig.isConfigured) {
    unawaited(
      FirebaseAppCheck.instance.activate(
        webProvider: ReCaptchaV3Provider(AppCheckConfig.recaptchaV3SiteKey),
      ),
    );
  }

  // Resolved BEFORE runApp so the app's initial route is decided correctly
  // on the very first frame instead of flashing the login screen.
  await Get.putAsync(() => AuthService().init());
  runApp(const SetAdminApp());
}
