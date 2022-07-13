import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:schema/data/noteData.dart';
import 'package:schema/functions/constants.dart';
import 'package:schema/functions/general.dart';
import 'package:intl/intl.dart';
import 'package:schema/main.dart';
import 'package:schema/models/noteModel.dart';
import 'package:schema/models/noteWidgetModel.dart';
import 'package:schema/widgets/noteEditFieldsWidget.dart';
import 'package:sprintf/sprintf.dart';

// Page that allows user to edit note and add/remove labels
class NoteEditPage extends StatelessWidget {
  NoteEditPage(this.noteWidgetData);

  // Note widget data
  final NoteWidgetData noteWidgetData;

  // Scrollbar for edit page
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    // Sets note variable for convenience
    Note note = noteWidgetData.note;

    // New Scaffold messenger so that snackbars avoid this scaffold
    return ScaffoldMessenger(
      child: Scaffold(
        appBar: AppBar(
          title: ValueListenableBuilder(
            valueListenable: note.isSavedNotifier,
            builder: (BuildContext context, bool isSaved, Widget? child) {
              return noteEditAppBarTitle(note);
            },
          ),
          elevation: 0,
          // Transparent to show through to dialog below
          backgroundColor: Colors.transparent,
          // Manual back button so that it shows while in transition
          automaticallyImplyLeading: false,
          leading: Tooltip(
            message: Constants.backTip,
            child: IconButton(
              onPressed: () => Navigator.of(navigatorKey.currentContext!).pop(),
              icon: Icon(Icons.arrow_back),
            ),
          ),
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
                    note,
                    noteWidgetData.refreshNotes,
                  );
                  Navigator.of(navigatorKey.currentContext!).pop();
                }
              },
            ),
            SizedBox(width: Constants.appBarPadding),
          ],
        ),
        // Transparent to show to dialog beneath
        backgroundColor: Colors.transparent,
        // If user taps outside of text fields, unfocus (and dismiss keyboard)
        body: GestureDetector(
          onTap: () {
            unfocus(context);
          },
          // Scrollable with a scrollbar that is always shown when not mobile
          child: Scrollbar(
            controller: scrollController,
            thumbVisibility: !isMobileDevice(),
            child: SingleChildScrollView(
              controller: scrollController,
              // Text fields for title and text
              child: NoteEditFields(noteWidgetData),
            ),
          ),
        ),
      ),
    );
  }

  // Returns app bar title based on the edit/save state of the note
  Widget noteEditAppBarTitle(Note note) {
    // Initialize the Row with title text
    List<Widget> content = [
      Text(Constants.editTitle),
      SizedBox(width: Constants.appBarPadding),
    ];
    // DateTime when note was last updated
    DateTime timeUpdated = note.timeUpdated.toDate();
    // Note has been saved
    if (note.isSavedNotifier.value) {
      if (note.hasOfflineChanges) {
        // Note has changes that have only been saved to the device
        content.add(
          IconButton(
            icon: Icon(Icons.cloud_off),
            tooltip: Constants.savedOfflineTip,
            onPressed: () {
              // Alert explains how note is saved and the time it was last saved
              showAlert(
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
            icon: Icon(Icons.cloud_done),
            tooltip: Constants.savedCloudTip,
            onPressed: () {
              // Alert explains how note is saved and the time it was last saved
              showAlert(
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
          icon: Icon(Icons.cloud_upload),
          tooltip: Constants.savingTip,
          onPressed: () {},
        ),
      );
    }
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: content,
    );
  }
}
