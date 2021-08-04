import 'package:schema/models/note/noteModel.dart';

// It's a note, what can I say
class NoteData {
  List<Note> notes;
  int idCounter;

  void incId() {
    idCounter++;
  }

  NoteData(this.notes, {this.idCounter = 0});
}

NoteData noteData = NoteData([]);
