import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:schema/data/noteData.dart';
import 'package:schema/functions/constants.dart';
import 'package:schema/functions/general.dart';

// Returns a list tile representing a label in the home drawer
// TODO: comment
class HomeDrawerLabel extends StatelessWidget {
  const HomeDrawerLabel(
    this.labelId,
    this.editMode,
    this.nameEditMode,
    this.refreshNotes,
    this.editLabelName,
    this.doneLabelName,
    this.updateLabelName,
  );

  // Label data and refresh function for refreshing the home page
  final int labelId;
  final bool editMode;
  final bool nameEditMode;
  final Function refreshNotes;
  final Function editLabelName;
  final Function doneLabelName;
  final Function updateLabelName;

  @override
  Widget build(BuildContext context) {
    // Returns different tile depending on editMode and nameEditMode
    if (editMode) {
      if (nameEditMode) {
        // Text controller to populate and get text in text field
        final customTextController = TextEditingController(
          text: noteData.labelName(labelId),
        );

        // Tile in name edit mode
        return ListTile(
          // Delete label button
          leading: IconButton(
            splashRadius: Constants.drawerLabelSplashRadius,
            tooltip: Constants.deleteLabelTip,
            icon: Icon(Icons.delete),
            onPressed: () async {
              // Confirms with user before deleting
              if (await confirm(
                context,
                title: Text(Constants.deleteLabelMessageTitle),
                content: Text(Constants.deleteLabelMessage),
              )) {
                noteData.deleteLabel(labelId);
                refreshNotes();
              }
            },
          ),
          title: TextField(
            decoration: noBorder(
              hintText: Constants.labelNameHint,
            ),
            // Focus on this field
            autofocus: true,
            // Pre-populates text
            controller: customTextController,
            // Updates temp label name
            onChanged: (String text) {
              updateLabelName(text);
            },
            // Updates label name when user presses enter, done, etc.
            onEditingComplete: () {
              doneLabelName();
            },
          ),
          // Done button
          trailing: IconButton(
            splashRadius: Constants.drawerLabelSplashRadius,
            tooltip: Constants.doneLabelNameTip,
            icon: Icon(Icons.check),
            // Tells drawer to update label name
            onPressed: () {
              doneLabelName();
            },
          ),
        );
      } else {
        // Tile in edit mode, but not name edit mode
        return ListTile(
          // Delete label button
          leading: IconButton(
            splashRadius: Constants.drawerLabelSplashRadius,
            tooltip: Constants.deleteLabelTip,
            icon: Icon(Icons.delete),
            onPressed: () async {
              // Confirms with user before deleting
              if (await confirm(
                context,
                title: Text(Constants.deleteLabelMessageTitle),
                content: Text(Constants.deleteLabelMessage),
              )) {
                noteData.deleteLabel(labelId);
                refreshNotes();
              }
            },
          ),
          title: Text(noteData.labelName(labelId)),
          // Edit name button
          trailing: IconButton(
            splashRadius: Constants.drawerLabelSplashRadius,
            tooltip: Constants.editLabelNameTip,
            icon: Icon(Icons.edit),
            // Tells drawer to update to name edit mode
            onPressed: () {
              editLabelName(labelId);
            },
          ),
          onTap: () {
            editLabelName(labelId);
          },
        );
      }
    } else {
      // Normal tile
      return ListTile(
        leading: Icon(Icons.label),
        title: Text(noteData.labelName(labelId)),
      );
    }
  }
}
