import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:schema/functions/constants.dart';
import 'package:schema/functions/init.dart';

class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _text = ModalRoute.of(context)!.settings.arguments as String?;

    // If no arguments, assume we are initializing app
    if (_text == null) {
      // Reinitializes app whenever user signs in or out
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        initApp(context, user);
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
            Text(_text ?? Constants.initLoading),
            Container(height: 15),
            CircularProgressIndicator(),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
    );
  }
}
