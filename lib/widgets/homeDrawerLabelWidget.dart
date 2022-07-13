import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:schema/data/noteData.dart';
import 'package:schema/functions/constants.dart';
import 'package:schema/functions/general.dart';
import 'package:schema/main.dart';
import 'package:schema/routes/homePage.dart';

// Returns a list tile representing a label in the home drawer
class HomeDrawerLabel extends StatelessWidget {
  const HomeDrawerLabel(
    this.labelId,
    this.updateLabelName,
    this.editLabelName,
    this.doneLabelName,
    this.data,
  );

  // Label data and function callbacks
  final String labelId;
  final Function updateLabelName;
  final Function editLabelName;
  final Function doneLabelName;
  final LabelsData data;

  @override
  Widget build(BuildContext context) {
    // Returns different tile depending on editMode and nameEditMode
    if (data.labelsEditMode) {
      if (data.editLabelId == labelId) {
        // Text controller to populate and get text in text field
        final customTextController = TextEditingController(
          text: noteData.getLabelName(labelId),
        );

        // Tile in name edit mode
        return ListTile(
          // Delete label button
          leading: IconButton(
            splashRadius: Constants.drawerLabelSplashRadius,
            icon: Icon(Icons.delete),
            tooltip: Constants.deleteLabelTip,
            onPressed: () async {
              // Confirms with user before deleting
              if (await confirm(
                context,
                title: Text(Constants.deleteLabelMessageTitle),
                content: Text(Constants.deleteLabelMessage),
              )) {
                noteData.deleteLabel(labelId);
                data.refreshNotes();
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
            // Capitalization
            textCapitalization: TextCapitalization.sentences,
            // Done button for mobile keyboards
            textInputAction: TextInputAction.done,
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
            icon: Icon(Icons.check),
            tooltip: Constants.doneLabelNameTip,
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
            icon: Icon(Icons.delete),
            tooltip: Constants.deleteLabelTip,
            onPressed: () async {
              // Confirms with user before deleting
              if (await confirm(
                context,
                title: Text(Constants.deleteLabelMessageTitle),
                content: Text(Constants.deleteLabelMessage),
              )) {
                noteData.deleteLabel(labelId);
                data.refreshNotes();
              }
            },
          ),
          title: Text(noteData.getLabelName(labelId)),
          // Edit name button
          trailing: IconButton(
            splashRadius: Constants.drawerLabelSplashRadius,
            icon: Icon(Icons.edit),
            tooltip: Constants.editLabelNameTip,
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
        title: Text(noteData.getLabelName(labelId)),
        // Tells HomePage to filter by this label
        onTap: () async {
          data.filterLabel(labelId);
        },
        // If filtering by this label, highlight and show stop filtering button
        tileColor: data.filterLabelId == labelId
            ? Theme.of(navigatorKey.currentContext!).dialogBackgroundColor
            : null,
        trailing: data.filterLabelId == labelId
            ? IconButton(
                splashRadius: Constants.drawerLabelSplashRadius,
                icon: Icon(Icons.close),
                tooltip: Constants.stopFilterTip,
                // Tells HomePage to stop filtering
                onPressed: () {
                  data.filterLabel(null);
                },
              )
            : null,
      );
    }
  }
}
