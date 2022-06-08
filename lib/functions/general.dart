import 'dart:io' show Platform;
import 'package:alert_dialog/alert_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
void showAlert(BuildContext context, String text, {bool useSnackbar = false}) {
  if (useSnackbar) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  } else {
    alert(context, title: Text(text));
  }
}

// Removes border from textfield
InputDecoration noBorder({
  EdgeInsetsGeometry? contentPadding,
  String? hintText,
}) {
  return InputDecoration(
    // Removes border
    isDense: true,
    contentPadding: contentPadding,
    border: InputBorder.none,
    focusedBorder: InputBorder.none,
    enabledBorder: InputBorder.none,
    errorBorder: InputBorder.none,
    disabledBorder: InputBorder.none,
    // Text label
    hintText: hintText,
  );
}

// Attempts an operation, returning the return value and type of error / success
// 0 = success, 1 = unknown error, 2 = permission denied error
Future<TryData> tryQuery(Function func) async {
  int status = 0;
  dynamic returnValue;
  try {
    returnValue = await func();
  } on FirebaseException catch (e) {
    // My security rules block attempts to get a document that doesn't exist
    status = (e.code == 'permission-denied') ? 2 : 1;
  } catch (e) {
    status = 1;
  }
  return TryData(returnValue, status);
}

class TryData {
  dynamic returnValue;
  int status;

  TryData(this.returnValue, this.status);
}
