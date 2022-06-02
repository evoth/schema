import 'package:flutter/material.dart';
import 'package:prompt_dialog/prompt_dialog.dart';
import 'package:schema/data/noteData.dart';
import 'package:schema/functions/constants.dart';
import 'package:schema/functions/general.dart';
import 'package:schema/models/noteModel.dart';
import 'package:schema/models/noteWidgetModel.dart';

// Returns a note widget base, used to draw the actual widget
class NoteAddLabelButton extends StatelessWidget {
  const NoteAddLabelButton(this.noteWidgetData, this.refreshLabels);

  // Note widget data
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
          // Prompt user for new label name
          String? newLabelName = await prompt(
            context,
            title: Text(
              Constants.newLabelText,
              style: TextStyle(fontSize: Constants.addLabelTitleSize),
            ),
            hintText: Constants.newLabelHint,
          );
          // Trim whitespace
          newLabelName = newLabelName?.trim();
          if (newLabelName == null) {
            // User dismissed prompt or pressed cancel
            return;
          }
          if (newLabelName.isEmpty) {
            // Label name was empty or only consisted of whitespace
            showSnackbar(context, Constants.labelNameEmptyMessage);
            return;
          }
          if (noteData.labelExists(newLabelName)) {
            // A label with a similar name already exists
            showSnackbar(context, Constants.labelExistsMessage);
            return;
          }
          // Creates the new label and adds it to the current note
          noteData.addLabel(note, noteData.newLabel(newLabelName));
          refreshLabels();
        } else {
          // Adds the selected label to the current note
          noteData.addLabel(note, labelId);
          refreshLabels();
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add),
          SizedBox(width: Constants.addNewGap),
          Text(Constants.addLabelText),
        ],
      ),
    );
  }
}
