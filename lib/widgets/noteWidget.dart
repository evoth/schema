import 'package:flutter/material.dart';
import 'package:schema/models/noteModel.dart';
import 'package:schema/models/noteWidgetModel.dart';
import 'dart:io' show Platform;
import 'package:schema/functions/general.dart';

// Returns a note widget
class NoteWidget extends StatefulWidget {
  NoteWidget({Key? key, required this.noteWidgetData}) : super(key: key);

  // Gets note wdget data to pass down
  final NoteWidgetData noteWidgetData;

  @override
  // *Do this in the future (not gonna fix right now):
  // *_NoteWidgetState createState() => _NoteWidgetState(this.title, this.text);
  // *Then you don't have to specify the arguments by name every time
  // **NOPE that's not how it works
  _NoteWidgetState createState() => _NoteWidgetState();
}

class _NoteWidgetState extends State<NoteWidget> {
  @override
  Widget build(BuildContext context) {
    // Text controller to pre-populate and keep track of text
    final customTextControlller =
        TextEditingController(text: widget.noteWidgetData.text);

    // Different draggable mode for different devices
    // *FIGURE OUT A MORE ELEGANT WAY
    LayoutBuilder deviceDraggable() {
      // Determines if on mobile
      bool mobile;
      try {
        if (Platform.isAndroid || Platform.isFuchsia || Platform.isIOS) {
          mobile = true;
        } else {
          mobile = false;
        }
      } catch (e) {
        mobile = false;
      }

      if (mobile) {
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
                    textController: customTextControlller,
                  ),
                  // Note when dragged (had to wrap in a Material because of a weird glitch)
                  feedback: Material(
                      color: Colors.transparent,
                      child: NoteWidgetBase(
                          noteWidgetData: widget.noteWidgetData,
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          textController: customTextControlller,
                          select: true)),
                  childWhenDragging: Container(),
                  // Unfocuses text fields when dragged
                  // Gives grid some info about dragging
                  onDragStarted: () {
                    unfocus(context);
                    widget.noteWidgetData.drag1(
                        widget.noteWidgetData.index, true,
                        originalX: widget.noteWidgetData.originalX,
                        originalY: widget.noteWidgetData.originalY);
                  },
                  onDragUpdate: (dragDetails) => widget.noteWidgetData
                      .drag2(widget.noteWidgetData.index, dragDetails),
                  onDragEnd: (dragDetails) => widget.noteWidgetData
                      .drag1(widget.noteWidgetData.index, false),
                ));
      } else {
        return LayoutBuilder(
            builder: (context, constraints) => Draggable(
                  // Note when not being dragged
                  child: NoteWidgetBase(
                    noteWidgetData: widget.noteWidgetData,
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    textController: customTextControlller,
                  ),
                  // Note when dragged (had to wrap in a Material because of a weird glitch)
                  feedback: Material(
                      color: Colors.transparent,
                      child: NoteWidgetBase(
                          noteWidgetData: widget.noteWidgetData,
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          textController: customTextControlller,
                          select: true)),
                  childWhenDragging: Container(),
                  // Unfocuses text fields when dragged
                  // Gives grid some info about dragging
                  onDragStarted: () {
                    unfocus(context);
                    widget.noteWidgetData.drag1(
                        widget.noteWidgetData.index, true,
                        originalX: widget.noteWidgetData.originalX,
                        originalY: widget.noteWidgetData.originalY);
                  },
                  onDragUpdate: (dragDetails) => widget.noteWidgetData
                      .drag2(widget.noteWidgetData.index, dragDetails),
                  onDragEnd: (dragDetails) => widget.noteWidgetData
                      .drag1(widget.noteWidgetData.index, false),
                ));
      }
    }

    return deviceDraggable();
  }
}

// Returns a note widget base, used to draw the actual widget
class NoteWidgetBase extends StatefulWidget {
  NoteWidgetBase(
      {Key? key,
      required this.noteWidgetData,
      required this.width,
      required this.height,
      required this.textController,
      this.select = false})
      : super(key: key);

  // Defines data to be displayed and used
  // Data that's been handed down through the generations
  final NoteWidgetData noteWidgetData;
  // Width and height from LayoutBuilder to ensure correct size
  final double width;
  final double height;
  // TextEditingController in order to keep the state of the text
  final TextEditingController textController;
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
        border: Border.all(
          color: Theme.of(context).primaryColorDark,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(10),
      );
    } else {
      return BoxDecoration(
        color: Theme.of(context).backgroundColor.withOpacity(0.8),
        border: Border.all(
          color: Theme.of(context).primaryColor,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Text controller to pre-populate and keep track of text
    final customTextControlller = widget.textController;

    // Creates a container around the note in order to decorate and pad it.
    return Container(
        // Expands to correct size when dragging
        width: widget.width,
        height: widget.height,
        // Padding surrounding text field
        padding: const EdgeInsets.all(15),
        // Creates note outline
        decoration: boxDecoration(),
        // Multiline text field (without border)
        // *See if there's a less jank way to remove the border!
        // Also removes extra padding added by TextField
        child: TextField(
          decoration: new InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none),
          keyboardType: TextInputType.multiline,
          maxLines: null,
          // Pre-populates text
          controller: customTextControlller,
          // Edits the note when text is changed
          onChanged: (newText) {
            widget.noteWidgetData.edit(widget.noteWidgetData.index, newText);
          },
        ));
  }
}

// Returns a list of note widgets
class NoteWidgetList {
  List<NoteWidget> all(List<Note> notes, NoteWidgetData noteWidgetData) {
    return notes
        .map((note) => NoteWidget(
            noteWidgetData: NoteWidgetData(
                noteWidgetData.edit,
                noteWidgetData.delete,
                noteWidgetData.drag1,
                noteWidgetData.drag2,
                title: note.title,
                text: note.text,
                index: note.index)))
        .toList();
  }
}
