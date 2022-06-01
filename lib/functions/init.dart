import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:schema/data/noteData.dart';

void initApp(BuildContext context, User? user) async {
  if (user == null) {
    Navigator.of(context).pushNamed('/signIn');
    return;
  }

  noteData.ownerId = user.uid;
  bool failed = false;
  DocumentSnapshot<Map<String, dynamic>>? dataDoc;

  try {
    dataDoc = await FirebaseFirestore.instance
        .collection('notes-meta')
        .doc(noteData.ownerId)
        .get();
  } catch (e) {
    failed = true;
  }

  if (failed || !dataDoc!.exists) {
    await FirebaseFirestore.instance
        .collection('notes-meta')
        .doc(noteData.ownerId)
        .set(noteData.toJson());
  } else {
    noteData = NoteData.fromJson(dataDoc.data()!);
    print("hi);");
    await noteData.downloadAllNotes();
  }

  Navigator.of(context).pushNamed('/home');
}
