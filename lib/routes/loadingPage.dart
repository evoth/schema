import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:schema/functions/constants.dart';
import 'package:schema/functions/init.dart';

class LoadingPage extends StatefulWidget {
  // If there's no text, needs mainContext
  const LoadingPage({this.mainContext, this.text});

  // Loading text
  final String? text;
  final BuildContext? mainContext;

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  Widget build(BuildContext context) {
    // If no arguments, assume we are initializing app
    if (widget.text == null) {
      // Reinitializes app whenever user signs in or out
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        initApp(widget.mainContext!, user);
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
            Text(widget.text ?? Constants.initLoading),
            SizedBox(height: 15),
            CircularProgressIndicator(),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
    );
  }
}
