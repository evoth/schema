import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:schema/data/noteData.dart';
import 'package:schema/functions/constants.dart';
import 'package:schema/models/noteModel.dart';
import 'package:schema/models/noteWidgetModel.dart';
import 'package:schema/widgets/noteEditFieldsWidget.dart';

// Page that allows user to edit note and add/remove labels
class NoteEditPage extends StatelessWidget {
  const NoteEditPage(this.noteWidgetData);

  // Note widget data
  final NoteWidgetData noteWidgetData;

  @override
  Widget build(BuildContext context) {
    // Sets note variable for convenience
    Note note = noteWidgetData.note;

    return Scaffold(
      appBar: AppBar(
        title: Text(Constants.editTitle),
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
                  note.index(noteData),
                  noteWidgetData.refreshNotes,
                );
                Navigator.of(context).pop(context);
              }
            },
          ),
          SizedBox(width: Constants.appBarPadding),
        ],
      ),
      // Text fields for title and text
      body: NoteEditFields(noteWidgetData),
    );
  }
}
