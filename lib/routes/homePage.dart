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
  // Data used to edit and filter labels
  late LabelsData labelsData =
      LabelsData(null, () => setState(() {}), filterLabel);

  // Adds a new blank note
  void newNote() async {
    int newId = noteData.newNote(labelsData.filterLabelId).id;
    // Go to the edit screen for the new note
    // Waits to set state so the new note won't show mid-animation
    await noteData.editNote(
      context,
      NoteWidgetData(
        noteData.notes[0],
        () => setState(() {}),
        filterLabelId: labelsData.filterLabelId,
      ),
      () => setState(() {}),
    );
    // Removes note if empty
    if (noteData.notes[0].id == newId) {
      if (noteData.notes[0].title == '' && noteData.notes[0].text == '') {
        noteData.deleteNote(context, 0, () => setState(() {}),
            message: Constants.discardMessage);
      }
    }
  }

  // Filters by the given label (if null, stops filtering and shows all notes)
  void filterLabel(int? labelId) async {
    labelsData.filterLabelId = labelId;
    setState(() {});
    await noteData.updateNotes(context, labelId);
    setState(() {});
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
      drawer: HomeDrawer(labelsData),
      // Saves label name when drawer is closed
      onDrawerChanged: (isOpen) {
        if (!isOpen) {
          // Saves label name if one was being edited
          if (labelsData.labelsEditMode &&
              labelsData.labelEditing != -1 &&
              labelsData.labelName != null &&
              labelsData.labelName !=
                  noteData.labelName(labelsData.labelEditing)) {
            noteData.editLabelName(
                context, labelsData.labelEditing, labelsData.labelName!);
          }
          // Resets data
          labelsData.resetEditing();
          setState(() {});
        }
      },
      // Stack so that buttons can go over the grid
      body: Stack(
        children: <Widget>[
          // Grid with notes
          DynamicGrid(
            refreshNotes: () => setState(() {}),
            filterLabelId: labelsData.filterLabelId,
            key: ValueKey(labelsData.filterLabelId),
          ),
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
class LabelsData {
  // Whether the labels section is in edit mode
  bool labelsEditMode = false;
  // Which label is in name edit mode (-1 for none)
  int labelEditing = -1;
  // Current edited label name
  String? labelName;
  // Filtering label
  int? filterLabelId;
  // Function for refreshing the home page
  final Function refreshNotes;
  // Function to filter by a label
  final Function filterLabel;

  // Resets variables related to label editing
  void resetEditing() {
    labelsEditMode = false;
    labelEditing = -1;
    labelName = null;
  }

  LabelsData(this.filterLabelId, this.refreshNotes, this.filterLabel);
}
