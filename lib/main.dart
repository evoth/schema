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
        // Home screen
        '/home': (context) => HomePage(),
        // Edit note screen
        '/edit0': (context) => NoteEditPage(),
        // Loading screen
        '/loading': (context) => LoadingPage(),
        // Sign in screen
        '/signIn': (context) => SignInPage(),
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
