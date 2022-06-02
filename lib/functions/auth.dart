import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:schema/functions/constants.dart';
import 'package:schema/functions/general.dart';

/* Authentication methods must be enabled in Firebase project */

// Sign in with Google account
Future<void> signInWithGoogle(BuildContext context) async {
  // Simple error catching (most likely error is user exiting sign in flow)
  try {
    // Different flow based on whether platform is mobile or web
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

      // Sign in with the UserCredential
      await FirebaseAuth.instance.signInWithCredential(credential);
    } else {
      // Create a new provider
      GoogleAuthProvider googleProvider = GoogleAuthProvider();

      // Sign in with the UserCredential
      await FirebaseAuth.instance.signInWithPopup(googleProvider);
    }
  } catch (e) {
    signInError(context);
  }
}

// Sign in with an anonymous account (persistent across reloads on the device)
Future<void> signInAnonymously(BuildContext context) async {
  // Simple error catching
  try {
    await FirebaseAuth.instance.signInAnonymously();
  } catch (e) {
    signInError(context);
  }
}

// Signs out if necessary and shows snackbar with error message
void signInError(BuildContext context) {
  if (FirebaseAuth.instance.currentUser != null) {
    FirebaseAuth.instance.signOut();
  }
  showSnackbar(context, Constants.signInErrorMessage);
}
