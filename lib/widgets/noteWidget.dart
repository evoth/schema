import 'dart:math';
import 'package:flutter/material.dart';
import 'package:schema/data/noteData.dart';
import 'package:schema/functions/general.dart';
import 'package:schema/models/noteModel.dart';
import 'package:schema/models/noteWidgetModel.dart';

// Returns a note widget
class NoteWidget extends StatefulWidget {
  NoteWidget({Key? key, required this.noteWidgetData}) : super(key: key);

  // Gets note wdget data to pass down
  final NoteWidgetData noteWidgetData;

  @override
  _NoteWidgetState createState() => _NoteWidgetState();
}

class _NoteWidgetState extends State<NoteWidget> {
  @override
  Widget build(BuildContext context) {
    // Drag functions to be used by both LongPressDraggable and Draggable
    void _dragStartFunction() {
      // Unfocuses text fields when dragged
      unfocus(context);
      // Gives grid some info about dragging
      widget.noteWidgetData.drag1!(
        widget.noteWidgetData.note.index(),
        true,
        originalX: widget.noteWidgetData.originalX,
        originalY: widget.noteWidgetData.originalY,
      );
    }

    void _dragUpdateFunction(DragUpdateDetails dragDetails) {
      // Gives grid some info about dragging
      widget.noteWidgetData.drag2!(
        widget.noteWidgetData.note.index(),
        dragDetails,
      );
    }

    void _dragEndFunction(DraggableDetails dragDetails) {
      // Gives grid some info about dragging
      widget.noteWidgetData.drag1!(widget.noteWidgetData.note.index(), false);
    }

    // Different draggable mode for different devices
    LayoutBuilder deviceDraggable() {
      if (isMobileDevice()) {
        return LayoutBuilder(
          builder: (context, constraints) => LongPressDraggable(
            // buzz
            hapticFeedbackOnStart: true,
            // long press  before starts to drag
            delay: Duration(milliseconds: 500),
            // Note when not being dragged
            child: NoteWidgetBase(
              noteWidgetData: widget.noteWidgetData,
              width: constraints.maxWidth,
              height: constraints.maxHeight,
            ),
            // Note when dragged (had to wrap in a Material because of a glitch)
            feedback: Material(
              color: Colors.transparent,
              child: NoteWidgetBase(
                noteWidgetData: widget.noteWidgetData,
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                select: true,
              ),
            ),
            childWhenDragging: Container(),
            // See drag functions above
            onDragStarted: _dragStartFunction,
            onDragUpdate: _dragUpdateFunction,
            onDragEnd: _dragEndFunction,
          ),
        );
      } else {
        return LayoutBuilder(
          builder: (context, constraints) => Draggable(
            // Note when not being dragged
            child: NoteWidgetBase(
              noteWidgetData: widget.noteWidgetData,
              width: constraints.maxWidth,
              height: constraints.maxHeight,
            ),
            // Note when dragged (had to wrap in a Material because of a glitch)
            feedback: Material(
              color: Colors.transparent,
              child: NoteWidgetBase(
                noteWidgetData: widget.noteWidgetData,
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                select: true,
              ),
            ),
            childWhenDragging: Container(),
            // See drag functions above
            onDragStarted: _dragStartFunction,
            onDragUpdate: _dragUpdateFunction,
            onDragEnd: _dragEndFunction,
          ),
        );
      }
    }

    return deviceDraggable();
  }
}

// Returns a note widget base, used to draw the actual widget
class NoteWidgetBase extends StatefulWidget {
  NoteWidgetBase({
    Key? key,
    required this.noteWidgetData,
    required this.width,
    required this.height,
    this.select = false,
  }) : super(key: key);

  // Defines data to be displayed and used
  // Data that's been handed down through the generations
  final NoteWidgetData noteWidgetData;
  // Width and height from LayoutBuilder to ensure correct size
  final double width;
  final double height;
  // Keeps track of draggable state
  final bool select;

  @override
  _NoteWidgetBaseState createState() => _NoteWidgetBaseState();
}

class _NoteWidgetBaseState extends State<NoteWidgetBase> {
  // Different BoxDecoration for selected vs not (also when dragging)
  BoxDecoration boxDecoration() {
    if (widget.select) {
      return BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.8),
        /*border: Border.all(
          color: Theme.of(context).primaryColorDark,
          width: 2,
        ),*/
        borderRadius: BorderRadius.circular(10),
      );
    } else {
      return BoxDecoration(
        color: Theme.of(context).backgroundColor.withOpacity(0.8),
        /*border: Border.all(
          color: Theme.of(context).primaryColor,
          width: 1,
        ),*/
        borderRadius: BorderRadius.circular(10),
      );
    }
  }

  // Actions to be completed before and after note opened
  Future<void> edit() async {
    await noteData.editNote(context, widget.noteWidgetData);
  }

  List<Widget> noteDisplayText() {
    // Tries to figure out heights of
    // Adds widgets conditionally
    List<Widget> texts = [];
    // If there's a title
    if (widget.noteWidgetData.note.title != '') {
      // Title
      texts.add(Text(
        widget.noteWidgetData.note.title,
        style:
            Theme.of(context).textTheme.headline6!.apply(fontSizeFactor: 0.9),
        // Allow for two lines, overflow with ellipsis
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ));
      // Space
      texts.add(SizedBox(height: 10));
    }
    // Text
    texts.add(
      Expanded(
        child: mostLinesText(widget.noteWidgetData.note.text),
      ),
    );
    return texts;
  }

  // Workaround from https://github.com/flutter/flutter/issues/15465#issuecomment-868357973
  LayoutBuilder mostLinesText(text) {
    return LayoutBuilder(builder: (context, constraints) {
      //use a text painter to calculate the height taking into account text scale factor.
      //could be moved to a extension method or similar
      final Size size = (TextPainter(
              text: TextSpan(text: text),
              maxLines: 1,
              textScaleFactor: MediaQuery.of(context).textScaleFactor,
              textDirection: TextDirection.ltr)
            ..layout())
          .size;

      //lets not return 0 max lines or less
      final maxLines =
          max(1, (constraints.biggest.height / size.height).floor());

      return Text(
        text,
        overflow: TextOverflow.ellipsis,
        maxLines: maxLines,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Detects taps on the note
    return GestureDetector(
      onTap: edit,
      // Creates a container around the note in order to decorate and pad it.
      child: Container(
        // Expands to correct size when dragging
        width: widget.width,
        height: widget.height,
        // Padding surrounding text field
        padding: const EdgeInsets.all(15),
        // Creates note outline
        decoration: boxDecoration(),
        // Column to show both title and text
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: noteDisplayText(),
        ),
      ),
    );
  }
}

// Returns a list of note widgets
class NoteWidgetList {
  List<NoteWidget> all(List<Note> notes, NoteWidgetData noteWidgetData) {
    return List.generate(
      notes.length,
      (i) => NoteWidget(
        noteWidgetData: NoteWidgetData(
          notes[i],
          noteWidgetData.edit,
          noteWidgetData.delete,
          drag1: noteWidgetData.drag1,
          drag2: noteWidgetData.drag2,
        ),
      ),
    );
  }
}
