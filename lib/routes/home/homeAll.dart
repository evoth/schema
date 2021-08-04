import 'package:flutter/material.dart';
import 'package:schema/layout/grid.dart';
import 'package:schema/models/note/noteModel.dart';
import 'package:schema/models/note/noteWidgetModel.dart';
import 'package:schema/functions/general.dart';
import 'package:schema/data/noteData.dart';

class HomeScreenAll extends StatefulWidget {
  HomeScreenAll({Key? key}) : super(key: key);

  @override
  _HomeScreenAllState createState() => _HomeScreenAllState();
}

class _HomeScreenAllState extends State<HomeScreenAll> {
  // Initializes list of notes
  // *Later will retrieve from storage
  List<Note> _notes = noteData.notes;

  // Adds a new blank note
  // *Doesn't need any special provider because it's changing the state directly?
  void _newNote() async {
    // Literally add a note
    _notes.add(
      Note(noteData.idCounter, _notes.length, '', '', _notes.length, false),
    );
    // Increases id counter by 1
    noteData.incId();
    // Go to the edit screen for the new note
    // Waits to set state so the new note won't show mid-animation
    int newIndex = _notes.length - 1;
    await Navigator.pushNamed(
      context,
      '/edit0',
      arguments: NoteWidgetData(_editNote, _deleteNote,
          note: _notes[newIndex], isNew: true),
    );
    // Removes note if empty
    if (_notes.length == newIndex + 1) {
      if (_notes.last.title == '' && _notes.last.text == '') {
        _notes.removeLast();
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text('Empty note discarded')));
      }
      setState(() {});
    }
  }

  // Callback all the way from the NoteWidget to edit note
  // *Not necessary because references?
  // *Providers??
  void _editNote() {
    setState(() {});
  }

  // Removes note and shifts indices
  void _deleteNote(int index) {
    _notes[index].deleted = true;
    _notes.removeAt(index);
    for (int i = index; i < _notes.length; i++) {
      _notes[i].index--;
      _notes[i].tempIndex--;
    }
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Note deleted')));
    setState(() {});
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
          title: new Text('Simple Notes App (no save)'),
        ),
        // Stack so that buttons can go over the grid
        body: Stack(
          children: <Widget>[
            // Grid with notes
            DynamicGrid(noteWidgetData: NoteWidgetData(_editNote, _deleteNote)),
            // Add note button
            Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(20),
              child: FloatingActionButton(
                onPressed: _newNote,
                tooltip: 'New Note',
                child: Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
