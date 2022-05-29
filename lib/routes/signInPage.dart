import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:schema/functions/auth.dart';
import 'package:schema/functions/constants.dart';
import 'package:schema/functions/general.dart';

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
          child: SingleChildScrollView(
            child: Container(
              width: Constants.signInWidth,
              height: Constants.signInHeight,
              padding: EdgeInsets.all(Constants.signInPadding),
              decoration: BoxDecoration(
                border: isMobileDevice()
                    ? null
                    : Border.all(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                borderRadius: BorderRadius.circular(Constants.signInPadding),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    Constants.signInTitle,
                    style: TextStyle(
                      fontSize: Constants.signInTextSize * 2,
                    ),
                  ),
                  Text(
                    Constants.welcomeText,
                    style: TextStyle(
                      fontSize: Constants.signInTextSize,
                    ),
                  ),
                  SignInButton(
                    icon: SvgPicture.asset(
                      Constants.googleG,
                      height: Constants.signInButtonSize,
                    ),
                    text: Constants.googleButton,
                    onPressed: signInWithGoogle,
                  ),
                  SignInButton(
                    icon: Icon(
                      Icons.fast_forward,
                      size: Constants.signInButtonSize,
                    ),
                    text: Constants.anonButton,
                    onPressed: signInAnonymously,
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

class SignInButton extends StatelessWidget {
  SignInButton({
    required Widget this.icon,
    required String this.text,
    required void Function(BuildContext) this.onPressed,
  });

  final Widget icon;
  final String text;
  final void Function(BuildContext) onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Theme.of(context).primaryColor,
        padding: const EdgeInsets.all(Constants.signInButtonPadding),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Constants.signInPadding),
            side: BorderSide(color: Theme.of(context).primaryColor)),
      ),
      child: Row(
        children: [
          icon,
          Flexible(
            fit: FlexFit.tight,
            child: Text(
              text,
              style: TextStyle(
                fontSize: Constants.signInButtonSize,
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
