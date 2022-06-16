import 'dart:io' show Platform;
import 'dart:math';
import 'package:alert_dialog/alert_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:schema/models/noteModel.dart';
import 'package:timeago/timeago.dart' as timeago;

// Unfocuses text fields and dismisses keyboard
void unfocus(BuildContext context) {
  FocusScopeNode currentFocus = FocusScope.of(context);

  if (!currentFocus.hasPrimaryFocus) {
    currentFocus.unfocus();
  }
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
  dynamic error;
  try {
    returnValue = await func();
  } on FirebaseException catch (e) {
    status = (e.code == 'permission-denied') ? 2 : 1;
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
int getUniqueId() {
  return int.parse(Timestamp.now().millisecondsSinceEpoch.toString() +
      Random().nextInt(1000).toString());
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

// Customized time ago text (capitalized and sans the word "about")
String customTimeAgo(DateTime dateTime) {
  String timeAgoText = timeago.format(dateTime);
  if (timeAgoText.substring(0, 6) == 'about ') {
    timeAgoText = timeAgoText.substring(6);
  }
  return capitalize(timeAgoText);
}
