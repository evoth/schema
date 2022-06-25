import 'dart:math';
import 'package:flutter/material.dart';
import 'package:schema/data/noteData.dart';
import 'package:schema/functions/constants.dart';
import 'package:schema/functions/general.dart';
import 'package:schema/models/noteModel.dart';
import 'package:schema/models/noteWidgetModel.dart';
import 'package:schema/widgets/noteWidget.dart';

// Dynamic, animated grid
class DynamicGrid extends StatefulWidget {
  DynamicGrid({
    Key? key,
    required this.refreshNotes,
    required this.filterLabelId,
  }) : super(key: key);

  // Gets note functions to pass down
  final Function refreshNotes;
  // Label filter
  final String? filterLabelId;

  @override
  _DynamicGridState createState() => _DynamicGridState();
}

class _DynamicGridState extends State<DynamicGrid> {
  // Stores the constraints of the grid each time it is built (through the
  // calcNotePositions function) so that it can be used elsewhere
  double globalGridWidth = 0;

  // Stores note width and aspect ratio based on chosen layout
  late double minNoteWidth = Constants.minNoteWidth *
      Constants.layoutDimensionOptions[noteData.layoutDimensionId][0];
  late double prefNoteWidth = Constants.prefNoteWidth *
      Constants.layoutDimensionOptions[noteData.layoutDimensionId][0];
  late double noteAR =
      Constants.layoutDimensionOptions[noteData.layoutDimensionId][0] /
          Constants.layoutDimensionOptions[noteData.layoutDimensionId][1];

  // Fill mode (if true, fills up entire width; if false, adds margins to
  // maintain preferred note size)
  final bool fillMode = isMobileDevice();

  // Stores whether we are filtering by a label for convenience
  late bool filter = widget.filterLabelId != null;

  // Returns number of columns based on space available
  int nColumns(double gridWidth) {
    if (fillMode) {
      return max(gridWidth ~/ minNoteWidth, 1);
    } else {
      return max(gridWidth ~/ prefNoteWidth, 1);
    }
  }

  // If not on mobile, makes it so notes are preferred size
  // In any case, if too narrow to display two notes, note fills entire width
  double calcWidth(double maxWidth) {
    double gridWidth = 0;
    if (fillMode) {
      gridWidth = maxWidth;
    } else {
      if (maxWidth >= prefNoteWidth) {
        gridWidth = maxWidth - maxWidth.remainder(prefNoteWidth);
      } else {
        gridWidth = maxWidth;
      }
    }
    globalGridWidth = gridWidth;
    return gridWidth;
  }

  // Calculates dimensions of notes
  List<double> calcNoteDimensions(
      double gridWidth, int nColumns, double padding) {
    // Calculates width based off of grid width and padding
    double width = (gridWidth - (padding * (nColumns + 1))) / nColumns;
    // Calculates height based off of aspect ratio (for now)
    double height = width / noteAR;
    return <double>[width, height];
  }

  // Creates a list of note positions based off of tempIndex, used when building
  // and arranging
  NotePositionData calcNotePositions(List<Note> notes, double gridWidth,
      int nColumns, double padding, bool useTemp) {
    // Stores grid width so that it can be used elsewhere
    //globalGridWidth = gridWidth;

    // Calculates dimensions of notes
    List<double> noteDim = calcNoteDimensions(gridWidth, nColumns, padding);
    double width = noteDim[0];
    double height = noteDim[1];

    // Positions note widgets
    List<NotePosition> notePositions = [];
    for (int i = 0; i < noteData.notes.length; i++) {
      // Shouldn't use tempIndex when using this to find index from position
      int noteIndex;
      if (useTemp) {
        noteIndex = noteData.notes[i].tempIndex;
      } else {
        noteIndex = noteData.notes[i].indexFilterBased(filter);
      }
      notePositions.add(
        NotePosition(
          width,
          height,
          padding + (width + padding) * (noteIndex % nColumns),
          padding + (height + padding) * (noteIndex ~/ nColumns),
          noteData.notes[i].indexFilterBased(filter),
          noteData.notes[i].id,
        ),
      );
    }

    notePositions.sort(
      (a, b) => a.id.compareTo(b.id),
    );

    NotePositionData positions = NotePositionData(
      notePositions,
      padding +
          (height + padding) * (1 + (noteData.notes.length - 1) ~/ nColumns),
      width,
      height,
    );

    return positions;
  }

  // Marks a note as being dragged or not and resets delta
  void dragUpdateNote(int index, bool drag,
      {double originalX = 0, double originalY = 0}) {
    // Doesn't allow dragging when filtering by a label
    if (filter) {
      if (drag) {
        showAlert(context, Constants.cantDragMessage, useSnackbar: true);
      }
      return;
    }

    // Updates drag status
    noteData.notes[index].drag = drag;
    if (drag) {
      // Resets delta to original x and y
      noteData.notes[index].dragX = originalX;
      noteData.notes[index].dragY = originalY;
    } else {
      // Reassigns indices
      for (int i = 0; i < noteData.notes.length; i++) {
        noteData.notes[i].index = noteData.notes[i].tempIndex;
      }
      noteData.updateData();
      noteData.notes.sort(
        (a, b) =>
            a.indexFilterBased(filter).compareTo(b.indexFilterBased(filter)),
      );
    }

    // Updates
    setState(() {});

    shiftNotes(noteData.notes);
  }

  // Shifts notes around dragging notes
  void shiftNotes(List<Note> notes) {
    // Warns non dragging notes of dragging notes
    List<bool> dragNoteHere = List<bool>.filled(noteData.notes.length, false);
    for (int i = 0; i < noteData.notes.length; i++) {
      if (noteData.notes[i].drag) {
        dragNoteHere[noteData.notes[i].tempIndex] = true;
      }
    }

    // Proceed to iterate through and assign notes appropriate tempIndex
    int j = 0;
    for (int i = 0; i < noteData.notes.length; i++) {
      if (!noteData.notes[i].drag) {
        if (dragNoteHere[j]) {
          while (dragNoteHere[j]) {
            j++;
          }
        }
        noteData.notes[i].tempIndex = j;
        j++;
      }
    }

    // Update
    setState(() {});
  }

  // Allows undragged notes to shift around accordingly
  void dragUpdateNotePositions(int index, DragUpdateDetails dragUpdateDetails) {
    // Doesn't allow dragging when filtering by a label
    if (filter) {
      return;
    }

    // Keeps track of relative postition since beginning of drag
    noteData.notes[index].dragX += dragUpdateDetails.delta.dx;
    noteData.notes[index].dragY += dragUpdateDetails.delta.dy;

    // Gets dimensinos of notes
    List<double> noteDim = calcNoteDimensions(
        globalGridWidth, nColumns(globalGridWidth), Constants.gridPadding);
    double width = noteDim[0];
    double height = noteDim[1];

    // Gets index using math
    // Gets width and height from indexPositions
    int closeColumn = min(
        max(
            (noteData.notes[index].dragX + 0.5 * width) ~/
                (width + Constants.gridPadding),
            0),
        nColumns(globalGridWidth) - 1);
    int closeRow = min(
        max(
            (noteData.notes[index].dragY + 0.5 * height) ~/
                (height + Constants.gridPadding),
            0),
        (noteData.notes.length / nColumns(globalGridWidth)).ceil() - 1);
    int closeIndex = min(
        max(closeRow * nColumns(globalGridWidth) + closeColumn, 0),
        noteData.notes.length - 1);

    // Doesn't have to change anything if it's already been dealt with
    if (closeIndex != noteData.notes[index].tempIndex) {
      // tempIndex for a dragging widget is the closest index
      noteData.notes[index].tempIndex = closeIndex;

      shiftNotes(noteData.notes);
    }
  }

  // Updates notes when user has scrolled
  void dragUpdateScroll(double? scrollDelta) {
    if (scrollDelta != null) {
      // Checks for dragging notes
      for (int i = 0; i < noteData.notes.length; i++) {
        if (noteData.notes[i].drag) {
          // Changes dragY by scrollDelta
          noteData.notes[i].dragY += scrollDelta;
          // Runs function to update dragging note
          dragUpdateNotePositions(
            noteData.notes[i].indexFilterBased(filter),
            DragUpdateDetails(globalPosition: Offset.zero),
          );
        }
      }
    }
  }

  // A stack of manually placed note widgets
  @override
  Widget build(BuildContext context) {
    // LayoutBuilder used to get constraints
    return LayoutBuilder(
      // Scroll
      builder: (context, constraints) =>
          NotificationListener<ScrollUpdateNotification>(
        child: SingleChildScrollView(
          // Centers stack and places in container of appropriate size
          child: Center(
            child: Container(
              // See calcWidth()
              width: calcWidth(constraints.maxWidth),
              // Stack of note widgets and a container which defines its height
              // (for scroll)
              child: Stack(
                children: DynamicGridNoteWidgetList().all(
                  noteData.notes,
                  widget.refreshNotes,
                  calcNotePositions(
                      noteData.notes,
                      calcWidth(constraints.maxWidth),
                      nColumns(constraints.maxWidth),
                      Constants.gridPadding,
                      true),
                  dragUpdateNote,
                  dragUpdateNotePositions,
                  widget.filterLabelId,
                ),
              ),
            ),
          ),
        ),
        onNotification: (notification) {
          dragUpdateScroll(notification.scrollDelta);
          // *null safety was being weird
          return true;
        },
      ),
    );
  }
}

// Returns a list of positioned note widgets to put in a stack
class DynamicGridNoteWidgetList {
  List<Widget> all(
    List<Note> notes,
    Function refreshNotes,
    NotePositionData notePositionData,
    Function drag1,
    Function drag2,
    String? filterLabelId,
  ) {
    // Sorts by id so that each NoteWidget will stay with the same note
    List<Note> sortedNotes = [];
    for (int i = 0; i < noteData.notes.length; i++) {
      sortedNotes.add(
        noteData.notes[i],
      );
    }
    sortedNotes.sort(
      (a, b) => a.id.compareTo(b.id),
    );
    // Positions note widgets
    List<AnimatedPositioned> noteWidgets = List.generate(
      sortedNotes.length,
      (j) => AnimatedPositioned(
        duration: Duration(milliseconds: Constants.noteShiftDuration),
        curve: Curves.fastOutSlowIn,
        left: notePositionData.notePositions
            .firstWhere((i) => i.id == sortedNotes[j].id)
            .left,
        top: notePositionData.notePositions
            .firstWhere((i) => i.id == sortedNotes[j].id)
            .top,
        width: notePositionData.notePositions
            .firstWhere((i) => i.id == sortedNotes[j].id)
            .width,
        height: notePositionData.notePositions
            .firstWhere((i) => i.id == sortedNotes[j].id)
            .height,
        // NoteWidget data for this note
        child: NoteWidget(
          noteWidgetData: NoteWidgetData(
            sortedNotes[j],
            refreshNotes,
            drag1: drag1,
            drag2: drag2,
            originalX: notePositionData.notePositions
                .firstWhere((i) => i.id == sortedNotes[j].id)
                .left,
            originalY: notePositionData.notePositions
                .firstWhere((i) => i.id == sortedNotes[j].id)
                .top,
            filterLabelId: filterLabelId,
          ),
        ),
      ),
    );

    // Conversion from List<Positioned> to List<Widget>
    // (I feel like there should be a better way)
    List<Widget> allWidgets = <Widget>[];
    for (int i = 0; i < noteWidgets.length; i++) {
      allWidgets.add(
        noteWidgets[i],
      );
    }

    // Adds a container to specify the total height of the stack (Positioned
    // widgets don't count toward dimensions)
    allWidgets.add(
      SizedBox(height: notePositionData.gridHeight),
    );

    return allWidgets;
  }
}

// Position which can be updated (used as part of a list)
class NotePosition {
  double width;
  double height;
  double left;
  double top;
  final int index;
  final String id;

  NotePosition(
    this.width,
    this.height,
    this.left,
    this.top,
    this.index,
    this.id,
  );
}

// A way to get the correct data to DynamicGridNoteWidgetList
class NotePositionData {
  List<NotePosition> notePositions;
  double gridHeight;
  double noteWidth;
  double noteHeight;

  NotePositionData(
    this.notePositions,
    this.gridHeight,
    this.noteWidth,
    this.noteHeight,
  );
}
