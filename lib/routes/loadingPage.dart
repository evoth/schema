import 'package:flutter/material.dart';
import 'package:schema/functions/constants.dart';

// Returns loading page with custom text
class LoadingPage extends StatelessWidget {
  const LoadingPage({required this.text});

  // Loading text
  final String text;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
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
              Text(text),
              SizedBox(height: 15),
              CircularProgressIndicator(),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ),
      ),
    );
  }
}
