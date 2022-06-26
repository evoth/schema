import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:schema/data/noteData.dart';
import 'package:schema/functions/constants.dart';
import 'package:schema/functions/general.dart';
import 'package:schema/functions/init.dart';
import 'package:schema/routes/loadingPage.dart';

class InitPage extends StatefulWidget {
  const InitPage({
    required this.mainContext,
    required this.authController,
    required this.connectivityController,
  });

  final BuildContext mainContext;
  final StreamController<User?> authController;
  final StreamController<ConnectivityResult> connectivityController;

  @override
  State<InitPage> createState() => _InitPageState();
}

// Underlying route that manages streams for authentication and connectivity
class _InitPageState extends State<InitPage> {
  // Stream subscriptions
  late StreamSubscription<User?> authSubscription;
  late StreamSubscription<ConnectivityResult> connectivitySubscription;

  // Subscribes to authentication and connectivity streams
  @override
  void initState() {
    // Reinitializes app whenever user signs in or out
    authSubscription = widget.authController.stream.listen((User? user) {
      if (!noteData.isDeleting) {
        initApp(widget.mainContext, user);
      }
    });

    // Listens to and updates connection state, notifying user of changes
    connectivitySubscription = widget.connectivityController.stream
        .listen((ConnectivityResult result) {
      bool isOnline = isConnectivityResultOnline(result);
      if (isOnline && !noteData.isOnline) {
        showAlert(widget.mainContext, Constants.isOnlineMessage,
            useSnackbar: true);
      } else if (!isOnline && noteData.isOnline) {
        showAlert(widget.mainContext, Constants.isOfflineMessage,
            useSnackbar: true);
      }
      noteData.setIsOnline(isOnline);
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
    return LoadingPage(text: Constants.initLoading);
  }
}
