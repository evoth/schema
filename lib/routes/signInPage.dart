import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:schema/data/noteData.dart';
import 'package:schema/data/themeData.dart';
import 'package:schema/functions/auth.dart';
import 'package:schema/functions/constants.dart';
import 'package:schema/functions/general.dart';
import 'package:schema/main.dart';

// Page displayed when user needs to sign in
class SignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        // App bar with title
        appBar: AppBar(
          title: Text(Constants.signInTitle),
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        // Container in center to contain content
        body: Center(
          // Only centered vertically if not on mobile device
          heightFactor: isMobileDevice() ? 1.0 : null,
          // Vertical scroll if necessary
          child: SingleChildScrollView(
            child: Container(
              width: Constants.signInWidth,
              height: Constants.signInHeight,
              padding: EdgeInsets.all(Constants.signInPadding),
              // If not on mobile, show rounded border
              decoration: BoxDecoration(
                border: isMobileDevice()
                    ? null
                    : Border.all(
                        color: Constants.googleColor,
                        width: 2,
                      ),
                borderRadius: BorderRadius.circular(Constants.signInPadding),
              ),
              // Evenly spaced column
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Sign in title text
                  Text(
                    Constants.signInTitle,
                    style: TextStyle(
                      fontSize: Constants.signInTextSize * 2,
                    ),
                  ),
                  // Sign in welcome text (explains sign in options)
                  Text(
                    Constants.welcomeText,
                    style: TextStyle(
                      fontSize: Constants.signInTextSize,
                    ),
                  ),
                  // Google sign in button
                  SignInButton(
                    icon: SvgPicture.asset(
                      Constants.googleG,
                      height: Constants.signInButtonSize,
                    ),
                    buttonColor: Constants.googleColor,
                    text: Constants.signInGoogleButton,
                    // If we are signed in anonymously, ask to transfer notes.
                    // Otherwise, just sign in normally
                    onPressed: (BuildContext context) {
                      if (noteData.isOnline) {
                        if (noteData.ownerId != null && noteData.isAnonymous) {
                          // Pop sign in page and ask to transfer notes
                          Navigator.of(navigatorKey.currentContext!).pop();
                          noteData.transferNotes();
                        } else {
                          signInWithGoogle();
                        }
                      } else {
                        // If we are offline, block from signing in
                        showAlert(
                          Constants.signInOfflineErrorMessage,
                          useSnackbar: true,
                        );
                      }
                    },
                  ),
                  // If we are already signed and anonymous, this is a cancel
                  // sign in button. Otherwise, it's an anonymous sign in button
                  (noteData.ownerId != null && noteData.isAnonymous)
                      ?
                      // Stay signed out button
                      SignInButton(
                          icon: Icon(
                            Icons.close,
                            color: Constants.googleColor,
                            size: Constants.signInButtonSize,
                          ),
                          buttonColor: Constants.googleColor,
                          text: Constants.signInCancelButton,
                          onPressed: (BuildContext context) =>
                              Navigator.of(context).pop(),
                        )
                      :
                      // Anonymous sign in button
                      SignInButton(
                          icon: Icon(
                            Icons.fast_forward,
                            color: Constants.googleColor,
                            size: Constants.signInButtonSize,
                          ),
                          buttonColor: Constants.googleColor,
                          text: Constants.signInAnonButton,
                          onPressed: (context) {
                            if (noteData.isOnline) {
                              // Sign in using anonymous account
                              signInAnonymously();
                            } else {
                              // If we are offline, block from signing in
                              showAlert(
                                Constants.signInOfflineErrorMessage,
                                useSnackbar: true,
                              );
                            }
                          },
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Rounded sign in button with circular white tile for an icon
class SignInButton extends StatelessWidget {
  const SignInButton({
    required this.icon,
    required this.text,
    required this.onPressed,
    this.scale,
    this.buttonColor,
  });

  final Widget icon;
  final String text;
  final void Function(BuildContext) onPressed;
  final double? scale;
  final Color? buttonColor;

  @override
  Widget build(BuildContext context) {
    // Scale set to 1 if scale is null
    double s = scale ?? 1;
    // Rounded button
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: buttonColor ?? Theme.of(context).primaryColor,
        padding: EdgeInsets.all(Constants.signInButtonPadding * s),
        fixedSize: Size(
          double.infinity,
          (Constants.signInTileSize + Constants.signInButtonPadding * 2) * s,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            (Constants.signInButtonSize + Constants.signInButtonPadding * 2) *
                s,
          ),
        ),
      ),
      // Row to hold content horizontally
      child: Row(
        children: [
          // Circular white tile
          Container(
            width: Constants.signInTileSize * s,
            height: Constants.signInTileSize * s,
            padding: EdgeInsets.all(
              (Constants.signInTileSize - Constants.signInButtonSize) / 2 * s,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Constants.signInTileSize * s),
            ),
            // Icon at same size as text
            child: icon,
          ),
          // Cenetered text that fills the remaining space
          Flexible(
            fit: FlexFit.tight,
            child: Text(
              text,
              style: TextStyle(
                color: Theme.of(context).primaryTextTheme.bodyMedium?.color ??
                    Colors.white,
                fontSize: Constants.signInButtonSize * s,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
      onPressed: () => onPressed(context),
    );
  }
}
