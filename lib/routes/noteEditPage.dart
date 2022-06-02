import 'package:flutter/material.dart';
import 'package:schema/data/noteData.dart';
import 'package:schema/functions/constants.dart';
import 'package:schema/models/noteModel.dart';
import 'package:schema/models/noteWidgetModel.dart';
import 'package:schema/widgets/noteEditFieldsWidget.dart';

class NoteEditPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Gets index of note to be edited
    final noteWidgetData =
        ModalRoute.of(context)!.settings.arguments as NoteWidgetData;

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
              await noteWidgetData.delete(note.index());
              Navigator.pop(context);
            },
          ),
        ],
      ),
      // Text fields for title and text
      body: NoteEditFields(noteWidgetData),
    );
  }
}
