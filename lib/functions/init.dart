import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:schema/data/noteData.dart';
import 'package:schema/data/themeData.dart';
import 'package:schema/functions/general.dart';
import 'package:schema/routes/homePage.dart';
import 'package:schema/routes/signInPage.dart';

// Ensures user is signed in, then refreshes notes before navigating to homepage
void initApp(
  BuildContext context,
  User? user,
) async {
  // Updates whether we are online or not
  ConnectivityResult connectivityResult =
      await (Connectivity().checkConnectivity());
  noteData.setIsOnline(isConnectivityResultOnline(connectivityResult));

  // If user is not signed in, navigate to sign in page
  if (user == null) {
    Navigator.of(context).pushAndRemoveUntil<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => SignInPage(),
      ),
      (route) => route.isFirst,
    );
    return;
  }

  // User data
  noteData.ownerId = user.uid;
  noteData.isAnonymous = user.isAnonymous;
  noteData.email = user.email;

  // If we are in the middle of a transfer, hold off on the updating
  if (noteData.isTransferring) {
    return;
  }

  // Get notes, creating new user data if need be
  await noteData.updateNotes(context, null);

  // Updates theme
  themeData.updateTheme();

  // Go to homepage
  Navigator.of(context).pushAndRemoveUntil<void>(
    MaterialPageRoute<void>(
      builder: (BuildContext context) => HomePage(),
    ),
    (route) => route.isFirst,
  );
}
