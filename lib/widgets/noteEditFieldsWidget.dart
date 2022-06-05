import 'package:flutter/material.dart';
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
          // Edits the note when text is changed
          onChanged: (newText) {
            note.title = newText;
            //noteWidgetData.edit();
          },
        ),
        SizedBox(height: Constants.editPadding),
        // Text text field (with a set minimum height)
        Container(
          constraints: BoxConstraints(minHeight: Constants.textMinHeight),
          child: TextField(
            decoration: noBorder(
              contentPadding: EdgeInsets.symmetric(
                horizontal: Constants.editPadding,
              ),
              hintText: Constants.textHint,
            ),
            // Text style
            //style: Theme.of(context).textTheme.bodyText1,
            // Multiline
            keyboardType: TextInputType.multiline,
            maxLines: null,
            // Focus on this field initially
            autofocus: noteWidgetData.note.isNew,
            // Pre-populates text
            controller: customTextController1,
            // Capitalization
            textCapitalization: TextCapitalization.sentences,
            // Edits the note when text is changed
            onChanged: (newText) {
              note.text = newText;
              //noteWidgetData.edit();
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
      ],
    );
  }
}
