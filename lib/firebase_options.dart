// File generated to prevent compilation errors.
// The user MUST run `flutterfire configure` to generate the real configuration.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return ios;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA4-eH5UwDfyn7LS2m1MUOHWP_2vj1RFDA',
    appId: '1:861922031134:web:e83c0f8cd1490611ff600f',
    messagingSenderId: '861922031134',
    projectId: 'code-runner-nijqz',
    authDomain: 'code-runner-nijqz.firebaseapp.com',
    storageBucket: 'code-runner-nijqz.firebasestorage.app',
    measurementId: 'G-1EJLDCQT0K',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBKm_2KFFkZ-DjIHM0C7UMO3A6P_IVN8cs',
    appId: '1:861922031134:android:5f495bad296733b4ff600f',
    messagingSenderId: '861922031134',
    projectId: 'code-runner-nijqz',
    storageBucket: 'code-runner-nijqz.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB6RvCUdq3Tvv7bcP2ZaPMX-66AYofAWVw',
    appId: '1:861922031134:ios:167d87c74c179e61ff600f',
    messagingSenderId: '861922031134',
    projectId: 'code-runner-nijqz',
    storageBucket: 'code-runner-nijqz.firebasestorage.app',
    iosClientId: '861922031134-9s0edhlq1pe88btkat9114r8tqnk2muf.apps.googleusercontent.com',
    iosBundleId: 'com.irontrack.irontrack',
  );
}
