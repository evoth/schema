import 'package:flutter/material.dart';
import 'package:schema/data/noteData.dart';
import 'package:schema/functions/constants.dart';
import 'package:schema/functions/general.dart';
import 'package:schema/models/noteModel.dart';
import 'package:schema/models/noteWidgetModel.dart';
import 'package:schema/widgets/noteLabelsWidget.dart';

// Returns the content of the note edit screen
class NoteEditFields extends StatelessWidget {
  const NoteEditFields(this.noteWidgetData);

  // Note widget data
  final NoteWidgetData noteWidgetData;

  @override
  Widget build(BuildContext context) {
    // Sets note variable for convenience
    Note note = noteWidgetData.note;

    // Text controllers to be used while editing
    final customTextController0 = TextEditingController(text: note.title);
    final customTextController1 = TextEditingController(text: note.text);

    // Column that holds text fields and labels section
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: Constants.editPadding),
        // Title text field
        TextField(
          decoration: noBorder(
            contentPadding: EdgeInsets.symmetric(
              horizontal: Constants.editPadding,
            ),
            hintText: Constants.titleHint,
          ),
          // Text style
          style: Theme.of(context).textTheme.headline6,
          // Pre-populates text
          controller: customTextController0,
          // Capitalization
          textCapitalization: TextCapitalization.sentences,
          // Next button for mobile keyboards
          textInputAction: TextInputAction.next,
          // Edits the note when text is changed (trims whitespace)
          onChanged: (newText) {
            note.title = newText.trim();
            noteData.saveNote(note);
            //noteWidgetData.refreshNotes();
          },
        ),
        SizedBox(height: Constants.editPadding),
        // Text text field (with a set minimum height)
        Container(
          child: TextField(
            decoration: noBorder(
              contentPadding: EdgeInsets.symmetric(
                horizontal: Constants.editPadding,
              ),
              hintText: Constants.textHint,
            ),
            // Multiline, with a minimum height of 3 lines
            keyboardType: TextInputType.multiline,
            minLines: 3,
            maxLines: null,
            // Focus on this field initially
            autofocus: noteWidgetData.note.isNew,
            // Pre-populates text
            controller: customTextController1,
            // Capitalization
            textCapitalization: TextCapitalization.sentences,
            // Edits the note when text is changed (trims whitespace)
            onChanged: (newText) {
              note.text = newText.trim();
              noteData.saveNote(note);
              //noteWidgetData.refreshNotes();
            },
          ),
        ),
        SizedBox(height: Constants.editPadding),
        // Labels section
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: Constants.editPadding,
          ),
          child: NoteLabels(noteWidgetData),
        ),
        // Add padding if on mobile
        isMobileDevice()
            ? SizedBox(height: Constants.editPadding)
            : Container(),
      ],
    );
  }
}
