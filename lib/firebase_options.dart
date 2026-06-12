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
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD4yVvmxHqlwbY7T3mAljKAfwexWQXxVnw',
    appId: '1:92371015435:web:d678364f2cf76c8a65340e',
    messagingSenderId: '92371015435',
    projectId: 'camera-83e7b',
    authDomain: 'camera-83e7b.firebaseapp.com',
    databaseURL: 'https://camera-83e7b.firebaseio.com',
    storageBucket: 'camera-83e7b.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD4yVvmxHqlwbY7T3mAljKAfwexWQXxVnw',
    appId: '1:92371015435:android:d678364f2cf76c8a65340e',
    messagingSenderId: '92371015435',
    projectId: 'camera-83e7b',
    storageBucket: 'camera-83e7b.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD4yVvmxHqlwbY7T3mAljKAfwexWQXxVnw',
    appId: '1:92371015435:ios:d678364f2cf76c8a65340e',
    messagingSenderId: '92371015435',
    projectId: 'camera-83e7b',
    storageBucket: 'camera-83e7b.firebasestorage.app',
    iosBundleId: 'com.example.camera.cameraAppIp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD4yVvmxHqlwbY7T3mAljKAfwexWQXxVnw',
    appId: '1:92371015435:macos:d678364f2cf76c8a65340e',
    messagingSenderId: '92371015435',
    projectId: 'camera-83e7b',
    storageBucket: 'camera-83e7b.firebasestorage.app',
    iosBundleId: 'com.example.camera.cameraAppIp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD4yVvmxHqlwbY7T3mAljKAfwexWQXxVnw',
    appId: '1:92371015435:windows:d678364f2cf76c8a65340e',
    messagingSenderId: '92371015435',
    projectId: 'camera-83e7b',
    storageBucket: 'camera-83e7b.firebasestorage.app',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyD4yVvmxHqlwbY7T3mAljKAfwexWQXxVnw',
    appId: '1:92371015435:linux:d678364f2cf76c8a65340e',
    messagingSenderId: '92371015435',
    projectId: 'camera-83e7b',
    storageBucket: 'camera-83e7b.firebasestorage.app',
  );
}
