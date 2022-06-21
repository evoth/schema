import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:schema/data/noteData.dart';
import 'package:schema/functions/constants.dart';
import 'package:schema/functions/general.dart';
import 'package:intl/intl.dart';
import 'package:schema/models/noteModel.dart';
import 'package:schema/models/noteWidgetModel.dart';
import 'package:schema/widgets/noteEditFieldsWidget.dart';
import 'package:sprintf/sprintf.dart';

// Page that allows user to edit note and add/remove labels
class NoteEditPage extends StatelessWidget {
  const NoteEditPage(this.noteWidgetData);

  // Note widget data
  final NoteWidgetData noteWidgetData;

  // Returns app bar title based on the edit/save state of the note
  Row noteEditAppBarTitle(BuildContext context, Note note) {
    // Initialize the Row with title text
    List<Widget> content = [
      Text(Constants.editTitle),
      SizedBox(width: Constants.appBarPadding),
    ];
    // Color to be used by icon and time ago text
    Color editStatusColor = HSVColor.fromColor(Theme.of(context).canvasColor)
        .withValue(1.0)
        .toColor()
        .withOpacity(0.5);
    // DateTime when note was last updated
    DateTime timeUpdated = note.timeUpdated.toDate();
    // Note has been saved
    if (note.isSavedNotifier.value) {
      if (note.hasOfflineChanges) {
        // Note has changes that have only been saved to the device
        content.add(
          IconButton(
            icon: Icon(Icons.cloud_off, color: editStatusColor),
            tooltip: Constants.savedOfflineTip,
            onPressed: () {
              // Alert explains how note is saved and the time it was last saved
              showAlert(
                context,
                sprintf(
                  Constants.savedOfflineMessage,
                  [
                    DateFormat.yMMMMd().format(timeUpdated),
                    DateFormat.jm().format(timeUpdated),
                  ],
                ),
              );
            },
          ),
        );
      } else {
        // Note has been saved to the cloud
        content.add(
          IconButton(
            icon: Icon(Icons.cloud_done, color: editStatusColor),
            tooltip: Constants.savedCloudTip,
            onPressed: () {
              // Alert explains how note is saved and the time it was last saved
              showAlert(
                context,
                sprintf(
                  Constants.savedCloudMessage,
                  [
                    DateFormat.yMMMMd().format(timeUpdated),
                    DateFormat.jm().format(timeUpdated),
                  ],
                ),
              );
            },
          ),
        );
      }
    } else {
      // New changes haven't been saved yet
      content.add(
        IconButton(
          icon: Icon(Icons.cloud_upload, color: editStatusColor),
          tooltip: Constants.savingTip,
          onPressed: () {},
        ),
      );
    }
    content.add(SizedBox(width: Constants.appBarPadding));
    // Time ago text
    content.add(
      Text(
        customTimeAgo(timeUpdated),
        style: TextStyle(color: editStatusColor),
      ),
    );
    return Row(
      children: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sets note variable for convenience
    Note note = noteWidgetData.note;

    return Scaffold(
      appBar: AppBar(
        title: ValueListenableBuilder(
          valueListenable: note.isSavedNotifier,
          builder: (BuildContext context, bool isSaved, Widget? child) {
            return noteEditAppBarTitle(context, note);
          },
        ),
        elevation: 0,
        automaticallyImplyLeading: true,
        actions: <Widget>[
          // Button to delete note
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: Constants.deleteNoteTip,
            onPressed: () async {
              // Confirms with user before deleting
              if (await confirm(
                context,
                title: Text(Constants.deleteNoteMessageTitle),
                content: Text(Constants.deleteNoteMessage),
              )) {
                noteData.deleteNote(
                  context,
                  note,
                  noteWidgetData.refreshNotes,
                );
                Navigator.of(context).pop(context);
              }
            },
          ),
          SizedBox(width: Constants.appBarPadding),
        ],
      ),
      // If user taps outside of text fields, unfocus (and dismiss keyboard)
      body: GestureDetector(
        onTap: () {
          unfocus(context);
        },
        // Content is scrollable
        child: SingleChildScrollView(
          // Text fields for title and text
          child: NoteEditFields(noteWidgetData),
        ),
      ),
    );
  }
}
