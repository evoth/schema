import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math';
import 'package:alert_dialog/alert_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:schema/data/noteData.dart';
import 'package:schema/main.dart';
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
void showAlert(String text, {bool useSnackbar = false}) {
  if (useSnackbar) {
    rootScaffoldMessengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  } else {
    alert(navigatorKey.currentContext!, title: Text(text));
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
// 0 = success, 1 = unknown error, 2 = permission denied error, 3 = unavailable
Future<TryData> tryQuery(Function func) async {
  int status = 0;
  dynamic returnValue;
  dynamic error;
  try {
    returnValue = await func();
  } on FirebaseException catch (e) {
    if (e.code == 'permission-denied') {
      status = 2;
    } else if (e.code == 'unavailable') {
      status = 3;
    } else {
      status = 1;
    }
    error = e;
  } catch (e) {
    status = 1;
    error = e;
  }
  return TryData(returnValue, status, error);
}

// Stores return value and status of tryQuery
class TryData {
  dynamic returnValue;
  int status;
  dynamic error;

  TryData(this.returnValue, this.status, this.error);
}

// Get unique id
String getUniqueId() {
  return Timestamp.now().millisecondsSinceEpoch.toString() +
      Random().nextInt(1000000000).toString();
}

// Capitalize string
String capitalize(String str) {
  return str[0].toUpperCase() + str.substring(1);
}

// Returns true if this ConnectivityResult represents an online state
bool isConnectivityResultOnline(ConnectivityResult result) {
  return (result == ConnectivityResult.mobile ||
      result == ConnectivityResult.wifi);
}

// Returns the newer of two maps using their 'timeUpdated' property
Map<String, dynamic> newerMap(
  Map<String, dynamic> map1,
  Map<String, dynamic> map2,
) {
  if (map1['timeUpdated'].compareTo(map2['timeUpdated']) > 0) {
    return map1;
  } else {
    return map2;
  }
}

// Timestamp rounded to the nearest millisecond (had issues with mobile using
// more precision, causing unnecessary updates)
Timestamp timestampNowRounded() {
  int milliseconds = Timestamp.now().millisecondsSinceEpoch;
  return Timestamp.fromMillisecondsSinceEpoch(milliseconds);
}

// Turns network access for Firestore on or off. If offline, always disable it.
// Force is used to override online state.
// TODO: delete force if not needed
Future<void> setFirestoreNetwork(bool isOnline, {bool force = false}) async {
  if (((noteData.isOnline && !force) || force) && isOnline) {
    await FirebaseFirestore.instance.enableNetwork();
  } else {
    await FirebaseFirestore.instance.disableNetwork();
  }
}

// Get a GetOptions object with a Source from which to get data. This forces
// Firestore to either use cache or server when necessary
GetOptions getOptions(bool fromOnline) {
  return GetOptions(source: fromOnline ? Source.server : Source.cache);
}
