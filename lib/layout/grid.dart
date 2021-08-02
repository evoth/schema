import 'package:flutter/material.dart';
import 'package:schema/widgets/noteWidget.dart';
import 'package:schema/models/noteModel.dart';
import 'package:schema/models/noteWidgetModel.dart';
import 'dart:math';

/*
// Fixed grid
class Grid extends StatefulWidget {
  Grid({Key? key, required this.notes, required this.noteWidgetData})
      : super(key: key);

  // A list of notes to be displayed
  // *Will have to deal with different types of notes in the future
  final List<Note> notes;

  // Gets note wdget data to pass down
  final NoteWidgetData noteWidgetData;

  @override
  _GridState createState() => _GridState();
}

class _GridState extends State<Grid> {
  // Returns number of columns based on space available (min width 250)
  int _nColumns(double gridWidth) {
    return max((gridWidth) ~/ 200, 2);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) => GridView.count(
            padding: const EdgeInsets.all(10),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: _nColumns(constraints.maxWidth),
            children:
                NoteWidgetList().all(widget.notes, widget.noteWidgetData)));
  }
}
*/

// Dynamic, animated grid
class DynamicGrid extends StatefulWidget {
  DynamicGrid({Key? key, required this.notes, required this.noteWidgetData})
      : super(key: key);

  // A list of notes to be displayed
  // *Will have to deal with different types of notes in the future
  final List<Note> notes;

  // Gets note wdget data to pass down
  final NoteWidgetData noteWidgetData;

  @override
  _DynamicGridState createState() => _DynamicGridState();
}

class _DynamicGridState extends State<DynamicGrid> {
  // Get notes
  List<Note> notes = [];

  void initState() {
    notes = widget.notes;
    super.initState();
  }

  // Sets grid style variables
  final double gridPadding = 10;

  // Stores the constraints of the grid each time it is built (through the calcNotePositions function) so that it can be used elsewhere
  double globalGridWidth = 0;

  // Returns number of columns based on space available (min width 250)
  int nColumns(double gridWidth) {
    return max(gridWidth ~/ 200, 2);
  }

  // Creates a list of note positions based off of tempIndex, used when building and arranging
  NotePositionData calcNotePositions(List<Note> notes, double gridWidth,
      int nColumns, double padding, bool useTemp) {
    // Stores grid width so that it can be used elsewhere
    globalGridWidth = gridWidth;

    // Calculates width based off of grid width and padding
    double width = (gridWidth - (padding * (nColumns + 1))) / nColumns;
    // For now notes are square
    // *Assumes square
    double height = width;

    // Positions note widgets
    List<NotePosition> notePositions = [];
    for (int i = 0; i < notes.length; i++) {
      // This is important because
      // I don't want to use temp when using this to find index from position
      int noteIndex;
      if (useTemp) {
        noteIndex = notes[i].tempIndex;
      } else {
        noteIndex = notes[i].index;
      }
      notePositions.add(NotePosition(
          width,
          height,
          padding + (width + padding) * (noteIndex % nColumns),
          padding + (height + padding) * (noteIndex ~/ nColumns),
          notes[i].index,
          notes[i].id));
    }

    NotePositionData positions = NotePositionData(
        notePositions,
        padding + (height + padding) * (1 + (notes.length - 1) ~/ nColumns),
        width,
        height);
    // See DynamicGridNoteWidgetList.all()
    positions.notePositions.sort((a, b) => a.id.compareTo(b.id));

    return positions;
  }

  // Marks a note as being dragged or not, resets delta
  void dragUpdateNote(int index, bool drag,
      {double originalX = 0, double originalY = 0}) {
    notes[index].drag = drag;
    if (drag) {
      notes[index].dragX = originalX;
      notes[index].dragY = originalY;
    } else {
      // Reassigns indices
      for (int i = 0; i < notes.length; i++) {
        notes[i].index = notes[i].tempIndex;
      }
      notes.sort((a, b) => a.index.compareTo(b.index));
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
  // *Keeps track of position in a way that works (cumulative delta), but it shouldn't be that hard
  void dragUpdateNotePositions(int index, DragUpdateDetails dragUpdateDetails) {
    // Keeps track of relative postition since beginning of drag
    notes[index].dragX += dragUpdateDetails.delta.dx;
    notes[index].dragY += dragUpdateDetails.delta.dy;

    // Commence inefficient but effective way to find closest index to dragged widget
    NotePositionData indexData = calcNotePositions(
        notes, globalGridWidth, nColumns(globalGridWidth), gridPadding, false);
    List<NotePosition> indexPositions = indexData.notePositions;

    /*
    // Gets index by looping through and seeing which is closest
    num closeDistance = 1 / 0;
    int closeIndex = -1;
    for (int i = 0; i < indexPositions.length; i++) {
      num iDistance = pow(notes[index].dragX - indexPositions[i].left, 2) +
          pow(notes[index].dragY - indexPositions[i].top, 2);
      if (iDistance < closeDistance) {
        closeDistance = iDistance;
        closeIndex = indexPositions[i].index;
      }
    }
    */

    // Gets index using math
    // *Gets width and height from indexPositions
    int closeColumn = min(
        max(
            (notes[index].dragX + 0.5 * indexData.noteWidth) ~/
                (indexData.noteWidth + gridPadding),
            0),
        nColumns(globalGridWidth) - 1);
    int closeRow = min(
        max(
            (notes[index].dragY + 0.5 * indexData.noteHeight) ~/
                (indexData.noteHeight + gridPadding),
            0),
        (indexPositions.length / nColumns(globalGridWidth)).ceil() - 1);
    int closeIndex = min(
        max(closeRow * nColumns(globalGridWidth) + closeColumn, 0),
        indexPositions.length - 1);

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
              notes[i].index, DragUpdateDetails(globalPosition: Offset.zero));
        }
      }
    }
  }

  // A stack of manually placed note widgets
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        // Scroll
        builder: (context, constraints) =>
            NotificationListener<ScrollUpdateNotification>(
              child: SingleChildScrollView(
                  // Stack of note widgets and a container which defines its height (for scroll)
                  child: Stack(
                      children: DynamicGridNoteWidgetList().all(
                          notes,
                          widget.noteWidgetData,
                          calcNotePositions(
                              notes,
                              constraints.maxWidth,
                              nColumns(constraints.maxWidth),
                              gridPadding,
                              true),
                          dragUpdateNote,
                          dragUpdateNotePositions))),
              onNotification: (notification) {
                dragUpdateScroll(notification.scrollDelta);
                // *null safety was being weird
                return true;
              },
            ));
  }
}

// Returns a list of positioned note widgets to put in a stack
class DynamicGridNoteWidgetList {
  List<Widget> all(List<Note> notes, NoteWidgetData noteWidgetData,
      NotePositionData notePositionData, Function drag1, Function drag2) {
    // Sorts by id so that each NoteWidget will stay with the same note
    List<Note> sortedNotes = [];
    for (int i = 0; i < notes.length; i++) {
      sortedNotes.add(notes[i]);
    }
    sortedNotes.sort((a, b) => a.id.compareTo(b.id));
    // Positions note widgets
    List<AnimatedPositioned> noteWidgets = sortedNotes
        .map((note) => AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            curve: Curves.fastOutSlowIn,
            left: notePositionData.notePositions[note.id].left,
            top: notePositionData.notePositions[note.id].top,
            width: notePositionData.notePositions[note.id].width,
            height: notePositionData.notePositions[note.id].height,
            // *Obnoxious, inefficient
            child: NoteWidget(
                noteWidgetData: NoteWidgetData(
                    noteWidgetData.edit, noteWidgetData.delete, drag1, drag2,
                    title: note.title,
                    text: note.text,
                    index: note.index,
                    originalX: notePositionData.notePositions[note.id].left,
                    originalY: notePositionData.notePositions[note.id].top))))
        .toList();

    // Conversion from List<Positioned> to List<Widget>
    // *Jank, find out better way
    List<Widget> allWidgets = <Widget>[];
    for (int i = 0; i < noteWidgets.length; i++) {
      allWidgets.add(noteWidgets[i]);
    }

    // Adds a container to specify the total height of the stack (Positioned() widgets don't count toward dimensions)
    allWidgets.add(Container(height: notePositionData.gridHeight));

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
      this.width, this.height, this.left, this.top, this.index, this.id);
}

// Just what it looks like: a jank way to get the correct data to DynamicGridNoteWidgetList
class NotePositionData {
  List<NotePosition> notePositions;
  double gridHeight;
  double noteWidth;
  double noteHeight;

  NotePositionData(
      this.notePositions, this.gridHeight, this.noteWidth, this.noteHeight);
}
