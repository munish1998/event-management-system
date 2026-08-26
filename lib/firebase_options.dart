
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
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBq9vZOmJZx11G7zTMTK7teQwGpThRpJcs',
    appId: '1:1060096165530:web:b7926bd62d0f8448bbc123',
    messagingSenderId: '1060096165530',
    projectId: 'event-management-system-8f9e1',
    authDomain: 'event-management-system-8f9e1.firebaseapp.com',
    storageBucket: 'event-management-system-8f9e1.firebasestorage.app',
    measurementId: 'G-2NK61Q8Q8Y',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAWdOFoqbZbPvunrid6ciO2T9J5qQ4d6eA',
    appId: '1:1060096165530:android:b4b5df0d9bf2a9b4bbc123',
    messagingSenderId: '1060096165530',
    projectId: 'event-management-system-8f9e1',
    storageBucket: 'event-management-system-8f9e1.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCMwH-jzUOysIfBZ6Ggmbdb68gT0iKXBPY',
    appId: '1:1060096165530:ios:aac5fbc9e2ea2fa6bbc123',
    messagingSenderId: '1060096165530',
    projectId: 'event-management-system-8f9e1',
    storageBucket: 'event-management-system-8f9e1.firebasestorage.app',
    iosBundleId: 'com.example.eventManagementSystem',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCMwH-jzUOysIfBZ6Ggmbdb68gT0iKXBPY',
    appId: '1:1060096165530:ios:aac5fbc9e2ea2fa6bbc123',
    messagingSenderId: '1060096165530',
    projectId: 'event-management-system-8f9e1',
    storageBucket: 'event-management-system-8f9e1.firebasestorage.app',
    iosBundleId: 'com.example.eventManagementSystem',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBq9vZOmJZx11G7zTMTK7teQwGpThRpJcs',
    appId: '1:1060096165530:web:12867c4d4f11e8dfbbc123',
    messagingSenderId: '1060096165530',
    projectId: 'event-management-system-8f9e1',
    authDomain: 'event-management-system-8f9e1.firebaseapp.com',
    storageBucket: 'event-management-system-8f9e1.firebasestorage.app',
    measurementId: 'G-1TREW1CXFD',
  );
}
