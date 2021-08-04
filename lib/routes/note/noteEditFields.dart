import 'package:flutter/material.dart';
import 'package:schema/models/note/noteModel.dart';
import 'package:schema/models/note/noteWidgetModel.dart';

// Returns a note widget base, used to draw the actual widget
class NoteEditFields extends StatefulWidget {
  NoteEditFields(this._noteWidgetData);

  // Note widget data, yep
  final NoteWidgetData _noteWidgetData;

  @override
  _NoteEditFieldsState createState() => _NoteEditFieldsState();
}

class _NoteEditFieldsState extends State<NoteEditFields> {
  @override
  Widget build(BuildContext context) {
    // Sets note variable for convenience
    Note _note = widget._noteWidgetData.note!;

    // Text controllers to be used while editing
    final _customTextController0 = TextEditingController(text: _note.title);
    final _customTextController1 = TextEditingController(text: _note.text);

    // Creates a container around the note in order to decorate and pad it.
    return Column(
      children: <Widget>[
        TextField(
          decoration: new InputDecoration(
            // Removes border
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            // Text label
            hintText: 'Title',
          ),
          // Text style
          style: Theme.of(context).textTheme.headline6,
          // Can fil multiple lines
          maxLines: null,
          // Pre-populates text
          controller: _customTextController0,
          // Capitalization
          textCapitalization: TextCapitalization.sentences,
          // Edits the note when text is changed
          onChanged: (newText) {
            _note.title = newText;
            widget._noteWidgetData.edit();
          },
        ),
        Expanded(
          child: TextField(
            decoration: new InputDecoration(
              // Removes border
              isDense: true,
              contentPadding: EdgeInsets.fromLTRB(30, 0, 30, 30),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              // Text label
              hintText: 'Note',
            ),
            // Text style
            //style: Theme.of(context).textTheme.bodyText1,
            // Multiline
            keyboardType: TextInputType.multiline,
            maxLines: null,
            // Focus on this field initially
            autofocus: widget._noteWidgetData.isNew,
            // Pre-populates text
            controller: _customTextController1,
            // Capitalization
            textCapitalization: TextCapitalization.sentences,
            // Edits the note when text is changed
            onChanged: (newText) {
              _note.text = newText;
              widget._noteWidgetData.edit();
            },
          ),
        ),
      ],
    );
  }
}
