import 'package:flutter/material.dart';
import 'package:schema/models/noteModel.dart';

// Unfocuses text fields and dismisses keyboard
void unfocus(BuildContext context) {
  FocusScopeNode currentFocus = FocusScope.of(context);

  if (!currentFocus.hasPrimaryFocus) {
    currentFocus.unfocus();
  }
}

// Gets a note
Note getNote(List<Note> notes, int id) {
  return notes.firstWhere((i) => i.id == id);
}
