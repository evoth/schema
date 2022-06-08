import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:schema/data/noteData.dart';
import 'package:schema/functions/constants.dart';
import 'package:schema/functions/general.dart';
import 'package:schema/routes/homePage.dart';
import 'package:schema/widgets/homeDrawerWidget.dart';

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
  final int labelId;
  final Function updateLabelName;
  final Function editLabelName;
  final Function doneLabelName;
  final LabelsData data;

  @override
  Widget build(BuildContext context) {
    // Returns different tile depending on editMode and nameEditMode
    if (data.labelsEditMode) {
      if (data.labelEditing == labelId) {
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
                data.refreshNotes();
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
        // Tells HomePage to filter by this label
        onTap: () async {
          data.filterLabel(labelId);
        },
        trailing: data.filterLabelId == labelId
            ? IconButton(
                splashRadius: Constants.drawerLabelSplashRadius,
                tooltip: Constants.stopFilterTip,
                icon: Icon(Icons.close),
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