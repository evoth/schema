import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:schema/functions/constants.dart';
import 'package:schema/functions/general.dart';

/* Authentication methods must be enabled in Firebase project */

// Sign in with Google account
Future<void> signInWithGoogle(BuildContext context) async {
  try {
    if (isMobilePlatform()) {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      // return
      await FirebaseAuth.instance.signInWithCredential(credential);
    } else {
      // Create a new provider
      GoogleAuthProvider googleProvider = GoogleAuthProvider();

      // Once signed in, return the UserCredential
      // return
      await FirebaseAuth.instance.signInWithPopup(googleProvider);
    }
  } catch (e) {
    if (FirebaseAuth.instance.currentUser != null) {
      FirebaseAuth.instance.signOut();
    }
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(Constants.signInErrorMessage)));
  }
}

// Sign in with an anonymous account (specific to device)
Future<void> signInAnonymously(BuildContext context) async {
  try {
    // return
    await FirebaseAuth.instance.signInAnonymously();
  } catch (e) {
    if (FirebaseAuth.instance.currentUser != null) {
      FirebaseAuth.instance.signOut();
    }
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(Constants.signInErrorMessage)));
  }
}
