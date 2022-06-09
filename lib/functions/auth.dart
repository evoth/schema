import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:schema/data/noteData.dart';
import 'package:schema/functions/constants.dart';
import 'package:schema/functions/general.dart';

/* Authentication methods must be enabled in Firebase project */

// Sign in with Google account
Future<void> signInWithGoogle(BuildContext context) async {
  final AuthCredential? credential = await getGoogleCredential(context);
  if (credential != null) {
    // Simple error catching (most likely error is user exiting sign in flow)
    try {
      // Sign in with the UserCredential
      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      signInError(context);
    }
  }
}

Future<AuthCredential?> getGoogleCredential(BuildContext context) async {
  // Simple error catching (most likely error is user exiting sign in flow)
  try {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create and return a new credential
    return GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
  } catch (e) {
    signInError(context);
    return null;
  }
}

// Sign in with an anonymous account (persistent across reloads on the device)
Future<void> signInAnonymously(BuildContext context) async {
  // Simple error catching
  try {
    // Only sign out if we're signed in
    if (noteData.ownerId != null) {
      await FirebaseAuth.instance.signOut();
    }
    await FirebaseAuth.instance.signInAnonymously();
  } catch (e) {
    signInError(context);
  }
}

// Signs out if necessary and shows snackbar with error message
void signInError(BuildContext context) {
  if (FirebaseAuth.instance.currentUser != null) {
    //FirebaseAuth.instance.signOut();
  }
  showAlert(context, Constants.signInErrorMessage, useSnackbar: true);
}
