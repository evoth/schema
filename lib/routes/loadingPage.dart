import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:schema/data/noteData.dart';
import 'package:schema/functions/constants.dart';
import 'package:schema/functions/general.dart';
import 'package:schema/functions/init.dart';

class LoadingPage extends StatefulWidget {
  // If there's no text, needs mainContext
  const LoadingPage({this.mainContext, this.text});

  // Loading text
  final String? text;
  final BuildContext? mainContext;

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  Widget build(BuildContext context) {
    // If no arguments, assume we are initializing app
    if (widget.text == null) {
      // Reinitializes app whenever user signs in or out
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (!noteData.isDeleting) {
          initApp(widget.mainContext!, user);
        }
      });
      // Listens to and updates connection state, notifying user of changes
      Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
        bool isOnline = isConnectivityResultOnline(result);
        if (isOnline && !noteData.isOnline) {
          showAlert(widget.mainContext!, Constants.isOnlineMessage,
              useSnackbar: true);
        } else if (!isOnline && noteData.isOnline) {
          showAlert(widget.mainContext!, Constants.isOfflineMessage,
              useSnackbar: true);
        }
        noteData.setIsOnline(isOnline);
      });
    }

    return Scaffold(
      // App bar with title
      appBar: AppBar(
        title: Text(Constants.appTitle),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      // Loading symbol with text
      body: Center(
        child: Column(
          children: [
            Text(widget.text ?? Constants.initLoading),
            SizedBox(height: 15),
            CircularProgressIndicator(),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
    );
  }
}
