import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:schema/data/noteData.dart';
import 'package:schema/routes/homePage.dart';
import 'package:schema/routes/signInPage.dart';

// Ensures user is signed in, then refreshes notes before navigating to homepage
void initApp(BuildContext context, User? user) async {
  // If user is not signed in, navigate to sign in page
  if (user == null) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => SignInPage(),
      ),
    );
    return;
  }

  // User data
  noteData.ownerId = user.uid;
  noteData.isAnonymous = user.isAnonymous;
  noteData.email = user.email;

  // Get notes, creating new user data if need be
  await noteData.updateNotes(context, null);

  // Go to homepage
  Navigator.push<void>(
    context,
    MaterialPageRoute<void>(
      builder: (BuildContext context) => HomePage(),
    ),
  );
}
