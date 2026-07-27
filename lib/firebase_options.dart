// Web-only Firebase options for the SET Admin Portal.
//
// Values copied from the SET mobile app's FlutterFire-generated
// `firebase_options.dart` (web platform block) so this panel connects to the
// SAME Firebase project (sett-451) — Auth, Firestore and Storage are shared
// with the mobile app. These are public client identifiers, not secrets.
//
// This panel is Flutter Web only; no other platform block is provided.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    throw UnsupportedError(
      'SET Admin Portal is a web-only app. '
      'DefaultFirebaseOptions have not been configured for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAJsDM0l3Bngc96ugyAPvncKOqUenALc5o',
    appId: '1:618037220000:web:6a1351451db2f8b24a2fc5',
    messagingSenderId: '618037220000',
    projectId: 'sett-451',
    authDomain: 'sett-451.firebaseapp.com',
    storageBucket: 'sett-451.firebasestorage.app',
    measurementId: 'G-HRQVV927GE',
  );
}
