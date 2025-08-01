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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macOS - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyCxV4k0NK2mGRkXQabfEVcNq4MucNvQDho',
    appId: '1:64581549667:web:b006747f3134c208a48256',
    messagingSenderId: '64581549667',
    projectId: 'fall-detection-1851d',
    authDomain: 'fall-detection-1851d.firebaseapp.com',
    storageBucket: 'fall-detection-1851d.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCxV4k0NK2mGRkXQabfEVcNq4MucNvQDho',
    appId: '1:64581549667:android:b006747f3134c208a48256',
    messagingSenderId: '64581549667',
    projectId: 'fall-detection-1851d',
    storageBucket: 'fall-detection-1851d.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCxV4k0NK2mGRkXQabfEVcNq4MucNvQDho',
    appId: '1:64581549667:ios:b006747f3134c208a48256',
    messagingSenderId: '64581549667',
    projectId: 'fall-detection-1851d',
    storageBucket: 'fall-detection-1851d.firebasestorage.app',
    iosClientId: '64581549667-example.apps.googleusercontent.com',
    iosBundleId: 'com.example.fall_detection',
  );
}
