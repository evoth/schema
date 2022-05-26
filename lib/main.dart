import "package:flutter/material.dart";
import "package:schema/routes/home/homeAll.dart";
import "package:schema/routes/note/noteEdit.dart";
import "package:schema/functions/constants.dart";

void main() {
  runApp(Schema());
}

class Schema extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constants.appTitle,
      // Defaut route
      initialRoute: "/",
      routes: {
        // Home screen
        "/": (context) => HomeScreenAll(),
        // Edit note screen
        "/edit0": (context) => NoteEditScreen(),
      },
      // *Play around with this, add ways to change theme (much later)
      theme: ThemeData(
        // Sets theme colors
        primarySwatch: Colors.green,
      ),
    );
  }
}
