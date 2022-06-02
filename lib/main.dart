import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:schema/functions/general.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:schema/functions/constants.dart';
import 'package:schema/routes/homePage.dart';
import 'package:schema/routes/loadingPage.dart';
import 'package:schema/routes/noteEditPage.dart';
import 'package:schema/routes/signInPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  try {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    if (!isMobilePlatform()) {
      await FirebaseFirestore.instance
          .enablePersistence(const PersistenceSettings(synchronizeTabs: true));
    }
  } catch (e) {
    print("Cannot modify settings because Firebase has alreadly been running.");
  }
  runApp(Schema());
}

class Schema extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constants.appTitle,
      // Defaut route
      initialRoute: '/loading',
      routes: {
        // Default
        '/': (context) => LoadingPage(),
        // Home screen
        '/home': (context) => HomePage(),
        // Edit note screen
        '/edit': (context) => NoteEditPage(),
        // Loading screen
        '/loading': (context) => LoadingPage(),
        // Sign in screen
        '/sign-in': (context) => SignInPage(),
      },
      // *Play around with this, add ways to change theme (much later)
      theme: ThemeData(
        brightness: Brightness.light,
        /* light theme settings */
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        /* dark theme settings */
      ),
      themeMode: ThemeMode.light,
    );
  }
}
