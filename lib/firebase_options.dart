// lib/firebase_options.dart

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyDeU1PH61nr41VPBxOHqm0YWwcgAJPRKHw",
    authDomain: "flutter-project-1fbb5.firebaseapp.com",
    projectId: "flutter-project-1fbb5",
    storageBucket: "flutter-project-1fbb5.appspot.com",
    messagingSenderId: "784683648808",
    appId: "1:784683648808:web:e91db4d84028ef4e43f21d",
  );
}
