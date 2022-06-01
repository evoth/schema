import 'package:flutter/material.dart';
import 'package:schema/data/noteData.dart';
import 'package:schema/functions/constants.dart';
import 'package:schema/functions/general.dart';
import 'package:schema/layout/grid.dart';
import 'package:schema/models/noteModel.dart';
import 'package:schema/models/noteWidgetModel.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Initializes list of notes
  // *Later will retrieve from storage
  List<Note> _notes = noteData.notes;

  // Adds a new blank note
  void _newNote() async {
    noteData.newNote();
    // Go to the edit screen for the new note
    // Waits to set state so the new note won't show mid-animation
    int newIndex = _notes.last.index();
    await noteData.editNote(
      context,
      NoteWidgetData(
        _notes[newIndex],
        _editNote,
        _deleteNote,
      ),
    );
    // Removes note if empty
    if (_notes.length == newIndex + 1) {
      if (_notes.last.title == '' && _notes.last.text == '') {
        _notes.removeLast();
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(Constants.discardMessage)));
        setState(() {});
        // TODO: delete note document
      }
    }
  }

  // Callback all the way from the NoteWidget to edit note
  // *Not necessary because references?
  // *Providers??
  void _editNote(int index) {
    setState(() {});
  }

  // Removes note and displays message
  void _deleteNote(int index) async {
    await noteData.deleteNote(index);
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(Constants.deleteMessage)));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // If user taps outside of text fields, unfocus (and dismiss keyboard)
    return GestureDetector(
      onTap: () => unfocus(context),
      // App scaffold
      child: Scaffold(
        // App bar with title
        appBar: AppBar(
          title: Text(Constants.appTitle),
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        // Stack so that buttons can go over the grid
        body: Stack(
          children: <Widget>[
            // Grid with notes
            DynamicGrid(edit: _editNote, delete: _deleteNote),
            // Add note button
            Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(20),
              child: FloatingActionButton(
                onPressed: _newNote,
                tooltip: Constants.newNoteTip,
                child: Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
