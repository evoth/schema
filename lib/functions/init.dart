import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:schema/data/noteData.dart';
import 'package:schema/data/themeData.dart';
import 'package:schema/functions/constants.dart';
import 'package:schema/functions/general.dart';
import 'package:schema/main.dart';
import 'package:schema/routes/homePage.dart';
import 'package:schema/routes/signInPage.dart';

// Ensures user is signed in, then refreshes notes before navigating to homepage
void initApp(
  User? user,
) async {
  // Updates whether we are online or not
  ConnectivityResult connectivityResult =
      await (Connectivity().checkConnectivity());
  noteData.isOnline = isConnectivityResultOnline(connectivityResult);
  await setFirestoreNetwork(noteData.isOnline);

  // If user is not signed in, navigate to sign in page
  if (user == null) {
    // Temporarily changes theme color to blue
    themeData.tempTheme(
      Constants.themeDefaultColorId,
      noteData.themeIsDark,
      noteData.themeIsMonochrome,
    );

    Navigator.of(navigatorKey.currentContext!).pushAndRemoveUntil<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => SignInPage(),
      ),
      (route) => false,
    );
    return;
  }

  // User data
  noteData.ownerId = user.uid;
  noteData.isAnonymous = user.isAnonymous;

  // If we are in the middle of a transfer, hold off on the updating
  if (noteData.isTransferring) {
    return;
  }

  // Get notes, creating new user data if need be
  await noteData.updateNotes(null);

  // Updates theme
  themeData.updateTheme();

  // Go to homepage
  Navigator.of(navigatorKey.currentContext!).pushAndRemoveUntil<void>(
    MaterialPageRoute<void>(
      builder: (BuildContext context) => HomePage(),
    ),
    (route) => false,
  );
}
