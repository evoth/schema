import 'package:flutter/material.dart';
import 'package:schema/data/noteData.dart';
import 'package:schema/functions/constants.dart';
import 'package:schema/functions/general.dart';
import 'package:schema/layout/grid.dart';
import 'package:schema/models/noteModel.dart';
import 'package:schema/models/noteWidgetModel.dart';
import 'package:schema/widgets/homeDrawerWidget.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Note> notes = noteData.notes;
  DrawerLabelsEditData labelsEditData = DrawerLabelsEditData();

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
        () => setState(() {}),
      ),
      () => setState(() {}),
    );
    // Removes note if empty
    if (notes.length == newIndex + 1) {
      if (notes.last.title == '' && notes.last.text == '') {
        notes.removeLast();
        showAlert(context, Constants.discardMessage, useSnackbar: true);
        setState(() {});
        // TODO: delete note document
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If user taps outside of text fields, unfocus (and dismiss keyboard)
    return Scaffold(
      // App bar with title
      appBar: AppBar(
        title: Text(Constants.appTitle),
        elevation: 0,
        //automaticallyImplyLeading: false,
      ),
      // Drawer with settings, labels, etc
      drawer: HomeDrawer(labelsEditData, () => setState(() {})),
      // Saves label name when drawer is closed
      onDrawerChanged: (isOpen) {
        if (!isOpen) {
          // Saves label name if one was being edited
          if (labelsEditData.labelsEditMode &&
              labelsEditData.labelEditing != -1 &&
              labelsEditData.labelName != null &&
              labelsEditData.labelName !=
                  noteData.labelName(labelsEditData.labelEditing)) {
            noteData.editLabelName(context, labelsEditData.labelEditing,
                labelsEditData.labelName!);
          }
          // Resets data
          labelsEditData = DrawerLabelsEditData();
          setState(() {});
        }
      },
      // Stack so that buttons can go over the grid
      body: Stack(
        children: <Widget>[
          // Grid with notes
          DynamicGrid(refreshNotes: () => setState(() {})),
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
    );
  }
}

// This is necessary (as opposed to keeping a state in the drawer widget)
// solely because we need to access and update this when the drawer widget
// doesn't exist, such as right after it is closed
class DrawerLabelsEditData {
  // Whether the labels section is in edit mode
  bool labelsEditMode = false;
  // Which label is in name edit mode (-1 for none)
  int labelEditing = -1;
  // Current edited label name
  String? labelName;
}
