import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:schema/data/noteData.dart';
import 'package:schema/data/themeData.dart';
import 'package:schema/functions/general.dart';
import 'package:schema/functions/init.dart';
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
    // Cannot modify settings because Firebase has already been running.
  }
  // Get theme data from shared preferences
  themeData = await SchemaThemeData.fromSP();
  // Get timeOffline from shared preferences
  await noteData.getTimeOfflineSP();
  // Remove hashtag from url
  setPathUrlStrategy();
  runApp(Schema());
}

// Scaffold messenger key so that we can display messages only on home screen
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

// Navigator key so that we can access root context from anywhere
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class Schema extends StatefulWidget {
  @override
  State<Schema> createState() => _SchemaState();
}

class _SchemaState extends State<Schema> {
  // Stream subscriptions for authentication and connectivity state
  late StreamSubscription<User?> authSubscription;
  late StreamSubscription<ConnectivityResult> connectivitySubscription;

  @override
  void initState() {
    // Listen to changes in themeData so we can update the theme throughout app
    themeData.addListener(() {
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // Reinitializes app whenever user signs in or out
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (!noteData.isDeleting) {
          initApp(user);
        }
      });

      // Listens to and updates connection state, notifying user of changes
      Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
        bool newIsOnline = isConnectivityResultOnline(result);
        if (newIsOnline && !noteData.isOnline) {
          showAlert(Constants.isOnlineMessage, useSnackbar: true);
        } else if (!newIsOnline && noteData.isOnline) {
          showAlert(Constants.isOfflineMessage, useSnackbar: true);
        }
        noteData.setIsOnline(newIsOnline);
      });
    });

    super.initState();
  }

  // Unsubscribes from streams when widget is disposed
  @override
  void dispose() {
    // Unsubscribes from respective streams
    authSubscription.cancel();
    connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constants.appTitleLong,
      // Default route
      initialRoute: '/',
      routes: {
        // If user is signed in, skip loading page
        '/': (context) => noteData.ownerId == null
            ? LoadingPage(text: Constants.initLoading)
            : HomePage(),
      },
      // Theme data that we're listening to
      theme: themeData.getTheme(),
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      navigatorKey: navigatorKey,
    );
  }
}
