// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
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
    apiKey: 'AIzaSyDj56nGBBAtFwbfLCKBmlpYlrkqgh-qcEA',
    appId: '1:223295734673:web:319946a9deafa2d612d030',
    messagingSenderId: '223295734673',
    projectId: 'schema-93d2f',
    authDomain: 'schema-93d2f.firebaseapp.com',
    storageBucket: 'schema-93d2f.appspot.com',
    measurementId: 'G-DE8DG8MSZN',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBIi_pkP7xOMti4sx6B80lJaougLc5kiVE',
    appId: '1:223295734673:android:0a03ce0bb5aa05b412d030',
    messagingSenderId: '223295734673',
    projectId: 'schema-93d2f',
    storageBucket: 'schema-93d2f.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBC_COYMSn1g1J4nMXjLv2_zk7G5icNm1Y',
    appId: '1:223295734673:ios:cb0e30db3e6b308212d030',
    messagingSenderId: '223295734673',
    projectId: 'schema-93d2f',
    storageBucket: 'schema-93d2f.appspot.com',
    iosClientId: '223295734673-1o96nfn6nh1b1ifb6cp729lqben5osjr.apps.googleusercontent.com',
    iosBundleId: 'com.example.schema',
  );
}