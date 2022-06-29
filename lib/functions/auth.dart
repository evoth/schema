import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:schema/data/noteData.dart';
import 'package:schema/functions/constants.dart';
import 'package:schema/functions/general.dart';
import 'package:schema/main.dart';
import 'package:schema/routes/loadingPage.dart';

/* Authentication methods must be enabled in Firebase project */

// Sign in with Google account
Future<void> signInWithGoogle() async {
  // Get credential to sign in
  final AuthCredential? credential = await getGoogleCredential();
  if (credential != null) {
    // Push loading screen with signing in text
    Navigator.of(navigatorKey.currentContext!).pushAndRemoveUntil<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => LoadingPage(
          text: Constants.signInLoading,
        ),
      ),
      (route) => false,
    );
    // Simple error catching (most likely error is user exiting sign in flow)
    try {
      // Sign in with the UserCredential
      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      signInError();
    }
  }
}

Future<AuthCredential?> getGoogleCredential() async {
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
    signInError();
    return null;
  }
}

// Sign in with an anonymous account (persistent across reloads on the device)
Future<void> signInAnonymously() async {
  // Push loading screen with signing in text
  Navigator.of(navigatorKey.currentContext!).pushAndRemoveUntil<void>(
    MaterialPageRoute<void>(
      builder: (BuildContext context) => LoadingPage(
        text: Constants.signInLoading,
      ),
    ),
    (route) => false,
  );
  // Simple error catching
  try {
    // Sign in anonymously
    await FirebaseAuth.instance.signInAnonymously();
  } catch (e) {
    signInError();
  }
}

// Signs out if necessary and shows snackbar with error message
void signInError() {
  showAlert(Constants.signInErrorMessage, useSnackbar: true);
}
