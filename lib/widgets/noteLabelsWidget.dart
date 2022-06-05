import 'package:flutter/material.dart';
import 'package:schema/data/noteData.dart';
import 'package:schema/functions/constants.dart';
import 'package:schema/models/noteModel.dart';
import 'package:schema/models/noteWidgetModel.dart';
import 'package:schema/widgets/noteAddLabelWidget.dart';

// Returns the labels section at the bottom of a note
class NoteLabels extends StatefulWidget {
  const NoteLabels(this.noteWidgetData);

  // Note widget data
  final NoteWidgetData noteWidgetData;

  @override
  State<NoteLabels> createState() => _NoteLabelsState();
}

class _NoteLabelsState extends State<NoteLabels> {
  @override
  Widget build(BuildContext context) {
    // Sets note variable for convenience
    Note note = widget.noteWidgetData.note;

    // Gets list of chips fot the note's labels and the add label button
    List<Widget> allChips() {
      List<Widget> chips = labelChips(
          context,
          note,
          Theme.of(context).backgroundColor.withOpacity(Constants.noteOpacity),
          setState,
          true);
      chips.add(
        NoteAddLabelButton(
          widget.noteWidgetData,
          () => setState(() {}),
        ),
      );
      return chips;
    }

    // Wraps the chips across multiple lines if necessary
    return Wrap(
      spacing: Constants.labelChipSpacing,
      runSpacing: Constants.labelChipSpacing,
      children: allChips(),
    );
  }
}

// Gets list of chips for the note's labels
List<Widget> labelChips(
  BuildContext context,
  Note note,
  Color color,
  Function? setState,
  bool showDelete,
) {
  List<int> labelIds = note.getLabels();
  List<Widget> chips = labelIds.isEmpty
      ? []
      : labelIds
          .map<Widget>(
            (int labelId) => Chip(
              backgroundColor: color,
              label: Text(noteData.labelName(labelId)),
              onDeleted: showDelete
                  ? () {
                      noteData.removeLabel(note, labelId);
                      setState!(() {});
                    }
                  : null,
              deleteIcon: showDelete
                  ? Icon(Icons.close, size: Constants.labelChipIconSize)
                  : null,
              deleteButtonTooltipMessage:
                  showDelete ? Constants.removeLabelTip : null,
            ),
          )
          .toList();
  return chips;
}
