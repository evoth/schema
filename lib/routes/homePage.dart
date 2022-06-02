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
  List<Note> notes = noteData.notes;

  // Adds a new blank note
  void newNote() async {
    noteData.newNote();
    // Go to the edit screen for the new note
    // Waits to set state so the new note won't show mid-animation
    int newIndex = notes.last.index();
    await noteData.editNote(
      context,
      NoteWidgetData(
        notes[newIndex],
        editNote,
        deleteNote,
      ),
    );
    // Removes note if empty
    if (notes.length == newIndex + 1) {
      if (notes.last.title == '' && notes.last.text == '') {
        notes.removeLast();
        showSnackbar(context, Constants.discardMessage);
        setState(() {});
        // TODO: delete note document
      }
    }
  }

  // Callback all the way from the NoteWidget to edit note
  // *See if there's a way to do this with Providers
  void editNote(int index) {
    setState(() {});
  }

  // Removes note and displays message
  void deleteNote(int index) async {
    await noteData.deleteNote(index);
    showSnackbar(context, Constants.deleteMessage);
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
            DynamicGrid(edit: editNote, delete: deleteNote),
            // Add note button
            Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(Constants.homePadding),
              child: FloatingActionButton(
                onPressed: newNote,
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
