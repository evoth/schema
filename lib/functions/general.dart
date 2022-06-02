import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
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

// Returns whether the platform is mobile or not
bool isMobilePlatform() {
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

// Returns whether we are on a mobile device (includes web browser on mobile)
bool isMobileDevice() {
  bool mobile = isMobilePlatform();

  if (!mobile) {
    mobile = kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android);
  }

  return mobile;
}

// Shows snackbar with given text
void showSnackbar(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..removeCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}
