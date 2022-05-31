import 'package:schema/models/noteModel.dart';

// Easy way to store and pass all the data needed by notes widgets at multiple
// levels
class NoteWidgetData {
  Note note;
  final Function edit;
  final Function delete;
  final Function? drag1;
  final Function? drag2;
  final double originalX;
  final double originalY;

  NoteWidgetData(
    this.note,
    this.edit,
    this.delete, {
    this.drag1,
    this.drag2,
    this.originalX = 0,
    this.originalY = 0,
  });
}
