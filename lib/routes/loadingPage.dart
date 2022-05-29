import 'package:flutter/material.dart';

import 'package:schema/functions/constants.dart';

class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _text = ModalRoute.of(context)!.settings.arguments as String?;
    return Scaffold(
      // App bar with title
      appBar: new AppBar(
        title: new Text(Constants.appTitle),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          children: [
            Text(_text ?? "Loading..."),
            Container(height: 15),
            CircularProgressIndicator(),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
    );
  }
}
