import 'package:flutter/material.dart';
import 'package:schema/layout/grid.dart';
import 'package:schema/models/noteModel.dart';
import 'package:schema/models/noteWidgetModel.dart';
import 'package:schema/functions/general.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Notes App',
      // *Play around with this, add ways to change theme (much later)
      theme: ThemeData(
        // Sets theme colors
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Initializes list of notes
  // *Later will retrieve from storage
  List<Note> notes = <Note>[];

  // Adds a new blank note
  // *Doesn't need any special provider because it's changing the state directly?
  void _newNote() {
    setState(() {
      notes.add(Note(notes.length, notes.length, "", "", notes.length, false));
    });
  }

  // Callback all the way from the NoteWidget to edit note
  void editNote(int index, String newText) {
    notes[index].text = newText;
  }

  // Callback to delete note
  void deleteNote(int index) {
    notes.removeWhere((item) => item.index == index);
  }

  /*
  // Stores whether button should allow delete or not (if a note is dragging)
  bool deleteMode = false;

  // deleteMode is true if any notes are dragging
  void deleteModeUpdate() {
    bool deleteModeTest = false;
    for (int i = 0; i < notes.length; i++) {
      if (notes[i].drag) {
        deleteModeTest = true;
      }
    }
    deleteMode = deleteModeTest;
    setState(() {});
  }

  FloatingActionButton actionButton(deleteMode) {
    if (deleteMode) {
      return FloatingActionButton(
        onPressed: deleteNote,
        tooltip: 'Delete Note',
        child: Icon(Icons.delete),
      );
    } else {
      return FloatingActionButton(
        onPressed: _newNote,
        tooltip: 'New Note',
        child: Icon(Icons.add),
      );
    }
  }
  */

  @override
  Widget build(BuildContext context) {
    // If user taps outside of text fields, unfocus (and dismiss keyboard)
    return GestureDetector(
        onTap: () => unfocus(context),
        // App scaffold
        child: Scaffold(
          // App bar with title
          appBar: new AppBar(
            title: new Text("Simple Notes App (no save)"),
          ),
          // Stack so that buttons can go over the grid
          body: Stack(children: <Widget>[
            // Grid with notes
            DynamicGrid(
                notes: notes,
                noteWidgetData:
                    // *JANK see noteWidgetModel
                    NoteWidgetData(editNote, deleteNote, () {}, () {})),
            // Add note button
            Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(20),
                child: FloatingActionButton(
                  onPressed: _newNote,
                  tooltip: 'New Note',
                  child: Icon(Icons.add),
                )),
          ]),
        ));
  }
}
