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
  DynamicGrid({Key? key, required this.edit, required this.delete})
      : super(key: key);

  // Gets note functions to pass down
  final Function edit;
  final Function delete;

  @override
  _DynamicGridState createState() => _DynamicGridState();
}

class _DynamicGridState extends State<DynamicGrid> {
  // Get notes
  List<Note> notes = noteData.notes;
  Map<int, Map> meta = noteData.noteMeta;

  // Stores the constraints of the grid each time it is built (through the
  // calcNotePositions function) so that it can be used elsewhere
  double globalGridWidth = 0;

  // Fill mode (if true, fills up entire width; if false, adds margins to
  // maintain preferred note size)
  final bool fillMode = isMobileDevice();

  // Returns number of columns based on space available
  int nColumns(double gridWidth) {
    if (fillMode) {
      return max(gridWidth ~/ Constants.minNoteWidth, 1);
    } else {
      return max(gridWidth ~/ Constants.prefNoteWidth, 1);
    }
  }

  // If not on mobile, makes it so notes are preffered size
  // In any case, if too narrow to display two notes, note fills entire width
  double calcWidth(double maxWidth) {
    double gridWidth = 0;
    if (fillMode) {
      gridWidth = maxWidth;
    } else {
      if (maxWidth >= Constants.prefNoteWidth) {
        gridWidth = maxWidth - maxWidth.remainder(Constants.prefNoteWidth);
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
    double height = width * Constants.noteAR;
    return <double>[height, width];
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
    for (int i = 0; i < notes.length; i++) {
      // Shouldn't use tempIndex when using this to find index from position
      int noteIndex;
      if (useTemp) {
        noteIndex = notes[i].tempIndex;
      } else {
        noteIndex = notes[i].index();
      }
      notePositions.add(
        NotePosition(
          width,
          height,
          padding + (width + padding) * (noteIndex % nColumns),
          padding + (height + padding) * (noteIndex ~/ nColumns),
          notes[i].index(),
          notes[i].id,
        ),
      );
    }

    notePositions.sort(
      (a, b) => a.id.compareTo(b.id),
    );

    NotePositionData positions = NotePositionData(
      notePositions,
      padding + (height + padding) * (1 + (notes.length - 1) ~/ nColumns),
      width,
      height,
    );

    return positions;
  }

  // Marks a note as being dragged or not and resets delta
  void dragUpdateNote(int index, bool drag,
      {double originalX = 0, double originalY = 0}) {
    notes[index].drag = drag;
    if (drag) {
      notes[index].dragX = originalX;
      notes[index].dragY = originalY;
    } else {
      // Reassigns indices
      for (int i = 0; i < notes.length; i++) {
        notes[i].setIndex(notes[i].tempIndex);
        meta[notes[i].id]?['index'] = notes[i].tempIndex;
      }
      noteData.updateData();
      notes.sort(
        (a, b) => a.index().compareTo(b.index()),
      );
    }

    // Updates
    setState(() {});

    shiftNotes(notes);
  }

  // Shifts notes around dragging notes
  void shiftNotes(notes) {
    // Warns non dragging notes of dragging notes
    List<bool> dragNoteHere = List<bool>.filled(notes.length, false);
    for (int i = 0; i < notes.length; i++) {
      if (notes[i].drag) {
        dragNoteHere[notes[i].tempIndex] = true;
      }
    }

    // Proceed to iterate through and assign notes appropriate tempIndex
    int j = 0;
    for (int i = 0; i < notes.length; i++) {
      if (!notes[i].drag) {
        if (dragNoteHere[j]) {
          while (dragNoteHere[j]) {
            j++;
          }
        }
        notes[i].tempIndex = j;
        j++;
      }
    }

    // Update
    setState(() {});
  }

  // Allows undragged notes to shift around accordingly
  void dragUpdateNotePositions(int index, DragUpdateDetails dragUpdateDetails) {
    // Keeps track of relative postition since beginning of drag
    notes[index].dragX += dragUpdateDetails.delta.dx;
    notes[index].dragY += dragUpdateDetails.delta.dy;

    // Gets dimensinos of notes
    List<double> noteDim = calcNoteDimensions(
        globalGridWidth, nColumns(globalGridWidth), Constants.gridPadding);
    double width = noteDim[0];
    double height = noteDim[1];

    // Gets index using math
    // Gets width and height from indexPositions
    int closeColumn = min(
        max(
            (notes[index].dragX + 0.5 * width) ~/
                (width + Constants.gridPadding),
            0),
        nColumns(globalGridWidth) - 1);
    int closeRow = min(
        max(
            (notes[index].dragY + 0.5 * height) ~/
                (height + Constants.gridPadding),
            0),
        (notes.length / nColumns(globalGridWidth)).ceil() - 1);
    int closeIndex = min(
        max(closeRow * nColumns(globalGridWidth) + closeColumn, 0),
        notes.length - 1);

    // Doesn't have to change anything if it's already been dealt with
    if (closeIndex != notes[index].tempIndex) {
      // tempIndex for a dragging widget is the closest index
      notes[index].tempIndex = closeIndex;

      shiftNotes(notes);
    }
  }

  // Updates notes when user has scrolled
  void dragUpdateScroll(double? scrollDelta) {
    if (scrollDelta != null) {
      // Checks for dragging notes
      for (int i = 0; i < notes.length; i++) {
        if (notes[i].drag) {
          // Changes dragY by scrollDelta
          notes[i].dragY += scrollDelta;
          // Runs function to update dragging note
          dragUpdateNotePositions(
            notes[i].index(),
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
                  notes,
                  widget.edit,
                  widget.delete,
                  calcNotePositions(
                      notes,
                      calcWidth(constraints.maxWidth),
                      nColumns(constraints.maxWidth),
                      Constants.gridPadding,
                      true),
                  dragUpdateNote,
                  dragUpdateNotePositions,
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
  List<Widget> all(List<Note> notes, Function edit, Function delete,
      NotePositionData notePositionData, Function drag1, Function drag2) {
    // Sorts by id so that each NoteWidget will stay with the same note
    List<Note> sortedNotes = [];
    for (int i = 0; i < notes.length; i++) {
      sortedNotes.add(
        notes[i],
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
            edit,
            delete,
            drag1: drag1,
            drag2: drag2,
            originalX: notePositionData.notePositions
                .firstWhere((i) => i.id == sortedNotes[j].id)
                .left,
            originalY: notePositionData.notePositions
                .firstWhere((i) => i.id == sortedNotes[j].id)
                .top,
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
  final int id;

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
