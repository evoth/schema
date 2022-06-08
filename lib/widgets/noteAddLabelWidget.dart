import 'package:flutter/material.dart';
import 'package:prompt_dialog/prompt_dialog.dart';
import 'package:schema/data/noteData.dart';
import 'package:schema/functions/constants.dart';
import 'package:schema/functions/general.dart';
import 'package:schema/models/noteModel.dart';
import 'package:schema/models/noteWidgetModel.dart';

// Returns the button to add a new label to a note
class NoteAddLabelButton extends StatelessWidget {
  const NoteAddLabelButton(this.noteWidgetData, this.refreshLabels);

  // Note widget data and function to update labels in drawer
  final NoteWidgetData noteWidgetData;
  final Function refreshLabels;

  @override
  Widget build(BuildContext context) {
    // Sets note variable for convenience
    Note note = noteWidgetData.note;

    // Gets list of dialog options for adding a new label
    List<SimpleDialogOption> addLabelDialogOptions() {
      // Gets list of label ids that note doesn't already have
      List<int> labelIds = noteData
          .getLabels()
          .where((int labelId) => !note.hasLabel(labelId))
          .toList();
      // Makes list of dialog options from label ids
      List<SimpleDialogOption> options = labelIds.map((labelId) {
        return SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context, labelId);
          },
          child: Text(
            noteData.labelName(labelId),
            style: TextStyle(fontSize: Constants.addLabelOptionSize),
          ),
        );
      }).toList();
      // Inserts option to create new label at beginning of list
      options.insert(
        0,
        SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context, -1);
          },
          child: Row(
            children: [
              Icon(
                Icons.add,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(width: Constants.addNewGap),
              Text(
                Constants.newLabelText,
                style: TextStyle(
                  fontSize: Constants.addLabelOptionSize,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      );
      return options;
    }

    // Button to add label to note
    return TextButton(
      style: TextButton.styleFrom(
        //textStyle: const TextStyle(fontSize: 20),
        padding: EdgeInsets.all(0),
      ),
      onPressed: () async {
        // Shows dialog with labels returns id of selected label (null means
        // dialog was dismissed early, and -1 means create new note)
        int? labelId = await showDialog<int>(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              title: Text(
                Constants.addLabelText,
                style: TextStyle(fontSize: Constants.addLabelTitleSize),
              ),
              children: addLabelDialogOptions(),
            );
          },
        );
        if (labelId == null) {
          // Dialog was dismissed
          return;
        } else if (labelId == -1) {
          // Prompt user for name and attempt to create new label
          addNewLabel(context, note, refreshLabels);
        } else {
          // Adds the selected label to the current note
          noteData.addLabel(note, labelId);
          refreshLabels();
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add, size: Constants.labelChipIconSize),
          SizedBox(width: Constants.addNewGap),
          Text(Constants.addLabelText),
        ],
      ),
    );
  }
}

// Prompt user for new label name and either create it or display error message
void addNewLabel(
    BuildContext context, Note? note, Function refreshLabels) async {
  // Prompt user for new label name
  String? newLabelName = await prompt(
    context,
    title: Text(
      Constants.newLabelText,
      style: TextStyle(fontSize: Constants.addLabelTitleSize),
    ),
    hintText: Constants.labelNameHint,
  );
  // Checks label name to make sure it's valid
  newLabelName = await checkLabelName(context, newLabelName);
  if (newLabelName == null) {
    return;
  }
  // Creates new label with the given name
  int newLabelId = noteData.newLabel(newLabelName);
  // Adds the new label to the current note if note is
  // not null; if it is null then don't do anything (note will be null when
  // called from the drawer on home page)
  if (note != null) {
    noteData.addLabel(note, newLabelId);
  }
  refreshLabels();
}

// Checks label name and displays error message if name is invalid
Future<String?> checkLabelName(BuildContext context, String? newName) async {
  // Trim whitespace
  newName = newName?.trim();
  if (newName == null) {
    // User dismissed prompt or pressed cancel
    return null;
  }
  if (newName.isEmpty) {
    // Label name was empty or only consisted of whitespace
    showAlert(context, Constants.labelNameEmptyMessage);
    return null;
  }
  if (noteData.labelExists(newName)) {
    // A label with a similar name already exists
    showAlert(context, Constants.labelExistsMessage);
    return null;
  }
  return newName;
}