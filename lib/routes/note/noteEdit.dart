import 'package:flutter/material.dart';
import 'package:schema/models/note/noteModel.dart';
import 'package:schema/models/note/noteWidgetModel.dart';
import 'package:schema/routes/note/noteEditFields.dart';
import 'package:schema/data/noteData.dart';

class NoteEditScreen extends StatefulWidget {
  NoteEditScreen({Key? key}) : super(key: key);

  @override
  _NoteEditScreenState createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  @override
  Widget build(BuildContext context) {
    // Gets index of note to be edited
    final _noteWidgetData =
        ModalRoute.of(context)!.settings.arguments as NoteWidgetData;

    // Sets note variable for convenience
    Note _note = _noteWidgetData.note!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit note'),
        actions: <Widget>[
          // Button to delete note
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete note',
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
