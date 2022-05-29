import "package:flutter/material.dart";
import 'package:schema/routes/homePage.dart';
import 'package:schema/routes/noteEditPage.dart';
import 'package:schema/routes/loadingPage.dart';
import "package:schema/functions/constants.dart";

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(Schema());
}

class Schema extends StatelessWidget {
  // INIT

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constants.appTitle,
      // Defaut route
      initialRoute: "/home",
      routes: {
        // Home screen
        "/home": (context) => HomePage(),
        // Edit note screen
        "/edit0": (context) => NoteEditPage(),
        // Loading screen
        "/loading": (context) => LoadingPage(),
      },
      // *Play around with this, add ways to change theme (much later)
      theme: ThemeData(
        // Sets theme colors
        primarySwatch: Colors.green,
      ),
    );
  }
}
