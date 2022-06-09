import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:schema/data/noteData.dart';
import 'package:schema/data/themeData.dart';
import 'package:schema/functions/general.dart';
import 'package:schema/routes/homePage.dart';
import 'package:url_strategy/url_strategy.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:schema/functions/constants.dart';
import 'package:schema/routes/loadingPage.dart';

void main() async {
  // Initialize Firebase and related settings
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
    print('Cannot modify settings because Firebase has already been running.');
  }
  // Get theme data from shared preferences
  themeData = await SchemaThemeData.fromSP();
  // Remove hashtag from url
  setPathUrlStrategy();
  runApp(Schema());
}

class Schema extends StatefulWidget {
  @override
  State<Schema> createState() => _SchemaState();
}

class _SchemaState extends State<Schema> {
  // Stores one HomePage so it doesn't update every time
  HomePage homePage = HomePage();

  // Listen to changes in themeData so we can update the theme throughout app
  @override
  void initState() {
    super.initState();
    themeData.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constants.appTitle,
      // Default route
      initialRoute: '/',
      routes: {
        // If user is signed in, skip loading page
        '/': (context) => noteData.ownerId == null
            ? LoadingPage(mainContext: context)
            : homePage,
      },
      // Theme data that we're listening to
      theme: themeData.getTheme(),
      debugShowCheckedModeBanner: false,
    );
  }
}
