import 'package:flutter/material.dart';
import 'package:schema/models/note/noteModel.dart';
import 'dart:io' show Platform;

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

// Returns whether mobile or not
bool isMobile() {
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
  return mobile;
}
