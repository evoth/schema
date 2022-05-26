import "package:schema/models/note/noteModel.dart";

// Easy way to store and pass all the data needed by notes widgets at multiple
// levels
class NoteWidgetData {
  Note? note;
  final Function edit;
  final Function delete;
  final Function? drag1;
  final Function? drag2;
  final double originalX;
  final double originalY;
  final bool isNew;

  NoteWidgetData(
    this.edit,
    this.delete, {
    this.drag1,
    this.drag2,
    this.note,
    this.originalX = 0,
    this.originalY = 0,
    this.isNew = false,
  });
}