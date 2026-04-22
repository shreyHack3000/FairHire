import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show  kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError('This platform is not supported');
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDgQTOcVMdRpfPnvr0vev-QiUuRhbbnKjg',
    authDomain: 'fairhire-74cb5.firebaseapp.com',
    projectId: 'fairhire-74cb5',
    storageBucket: 'fairhire-74cb5.firebasestorage.app',
    messagingSenderId: '340491884657',
    appId: '1:340491884657:web:14d8b71c9df787f92ee3d0',
  );
}