import "package:schema/models/noteModel.dart";

// Keeps track of notes and counts id
class NoteData {
  List<Note> notes;
  int idCounter;

  void incId() {
    idCounter++;
  }

  NoteData(this.notes, {this.idCounter = 0});
}

NoteData noteData = NoteData([]);
