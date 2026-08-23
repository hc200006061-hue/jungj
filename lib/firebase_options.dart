import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web is not supported yet.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Unsupported platform.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCLzIJHb-mGkNWPJPJAlzmKuN68ZeOnVXQ',
    appId: '1:1040737314901:android:20cf0b3b184012c6000cdc',
    messagingSenderId: '1040737314901',
    projectId: 'japanese-starter',
    storageBucket: 'japanese-starter.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDW9lNKr6AR-k1MslhofI4SgMWv5Q3Ozi8',
    appId: '1:1040737314901:ios:615348f9c0e50a8f000cdc',
    messagingSenderId: '1040737314901',
    projectId: 'japanese-starter',
    storageBucket: 'japanese-starter.firebasestorage.app',
    iosBundleId: 'com.jung.japanese-starter',
  );
}