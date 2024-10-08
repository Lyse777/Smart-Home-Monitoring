// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
    apiKey: 'AIzaSyCVeNMuJR2YrC2wKuRuKMTSxmXwW33A7Bw',
    appId: '1:32191230194:web:2a24641db4050a3833606b',
    messagingSenderId: '32191230194',
    projectId: 'authenticate-6a3c8',
    authDomain: 'authenticate-6a3c8.firebaseapp.com',
    storageBucket: 'authenticate-6a3c8.appspot.com',
    measurementId: 'G-NMLPJS27H8',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBvPOhaDKAqsJonpBnoU-HvTKxF-1OY9go',
    appId: '1:32191230194:android:8be94e20eba0222133606b',
    messagingSenderId: '32191230194',
    projectId: 'authenticate-6a3c8',
    storageBucket: 'authenticate-6a3c8.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBXbPQX1dzPOItxioc1En2Y8lg0ByJ54ks',
    appId: '1:32191230194:ios:c75ebe4b8056300933606b',
    messagingSenderId: '32191230194',
    projectId: 'authenticate-6a3c8',
    storageBucket: 'authenticate-6a3c8.appspot.com',
    androidClientId: '32191230194-47sc3dfbopvvjvi9jmk99me9lkd0b706.apps.googleusercontent.com',
    iosClientId: '32191230194-4rjo6ke7gu47bqseq64p8p8aogm6k1ac.apps.googleusercontent.com',
    iosBundleId: 'com.example.smartHomeApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBXbPQX1dzPOItxioc1En2Y8lg0ByJ54ks',
    appId: '1:32191230194:ios:c75ebe4b8056300933606b',
    messagingSenderId: '32191230194',
    projectId: 'authenticate-6a3c8',
    storageBucket: 'authenticate-6a3c8.appspot.com',
    androidClientId: '32191230194-47sc3dfbopvvjvi9jmk99me9lkd0b706.apps.googleusercontent.com',
    iosClientId: '32191230194-4rjo6ke7gu47bqseq64p8p8aogm6k1ac.apps.googleusercontent.com',
    iosBundleId: 'com.example.smartHomeApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCVeNMuJR2YrC2wKuRuKMTSxmXwW33A7Bw',
    appId: '1:32191230194:web:cad1579ad6790efc33606b',
    messagingSenderId: '32191230194',
    projectId: 'authenticate-6a3c8',
    authDomain: 'authenticate-6a3c8.firebaseapp.com',
    storageBucket: 'authenticate-6a3c8.appspot.com',
    measurementId: 'G-H1M5PQKDQB',
  );
}
