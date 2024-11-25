
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for android - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAITTuZb2cXoZdtLuGzPruXFHt2S91oNoc',
    appId: '1:958733498686:web:bd7f00a4cfb88db7f0d46f',
    messagingSenderId: '958733498686',
    projectId: 'elearning-app-a6e15',
    authDomain: 'elearning-app-a6e15.firebaseapp.com',
    storageBucket: 'elearning-app-a6e15.appspot.com',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAITTuZb2cXoZdtLuGzPruXFHt2S91oNoc',
    appId: '1:958733498686:web:acecec69a098fc4ff0d46f',
    messagingSenderId: '958733498686',
    projectId: 'elearning-app-a6e15',
    authDomain: 'elearning-app-a6e15.firebaseapp.com',
    storageBucket: 'elearning-app-a6e15.appspot.com',
  );
}
