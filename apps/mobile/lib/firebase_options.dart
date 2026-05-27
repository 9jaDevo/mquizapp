// File generated manually from google-services.json (Android) and
// GoogleService-Info.plist (iOS). Keep in sync if Firebase project changes.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  /// Values sourced from apps/mobile/android/app/google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAus80m4g5Fg_3GQ0rbqljwtbGIiwCpwv4',
    appId: '1:850520168460:android:155ab1d936b04fa91af629',
    messagingSenderId: '850520168460',
    projectId: 'mquiz-a8251',
    storageBucket: 'mquiz-a8251.firebasestorage.app',
  );

  /// Values sourced from apps/mobile/ios/Runner/GoogleService-Info.plist
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCJUVv2Ow4774zugaNp2naK3AX31ZwW2ok',
    appId: '1:850520168460:ios:6f4c06bd6c342d6f1af629',
    messagingSenderId: '850520168460',
    projectId: 'mquiz-a8251',
    storageBucket: 'mquiz-a8251.firebasestorage.app',
    iosClientId:
        '850520168460-qiq3sj00u2o6ck4h4ebvmb0aqvfko5kl.apps.googleusercontent.com',
    iosBundleId: 'com.togafrica.mquiz',
  );
}
