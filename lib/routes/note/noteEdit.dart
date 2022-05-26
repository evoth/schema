import "package:flutter/material.dart";
import "package:schema/models/note/noteModel.dart";
import "package:schema/models/note/noteWidgetModel.dart";
import "package:schema/routes/note/noteEditFields.dart";
import "package:schema/data/noteData.dart";
import "package:schema/functions/constants.dart";

class NoteEditScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Gets index of note to be edited
    final _noteWidgetData =
        ModalRoute.of(context)!.settings.arguments as NoteWidgetData;

    // Sets note variable for convenience
    Note _note = _noteWidgetData.note!;

    return Scaffold(
      appBar: AppBar(
        title: Text(Constants.editTitle),
        actions: <Widget>[
          // Button to delete note
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: Constants.deleteNoteTip,
            onPressed: () {
              noteData.notes[_note.index].deleted = true;
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: NoteEditFields(_noteWidgetData),
    );
  }
}
