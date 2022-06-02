import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:schema/data/noteData.dart';

// Ensures user is signed in, then refreshes notes before navigating to homepage
void initApp(BuildContext context, User? user) async {
  // If user is not signed in, navigate to sign in page
  if (user == null) {
    Navigator.of(context).pushNamed('/sign-in');
    return;
  }

  // Attempt to get metadata document
  noteData.ownerId = user.uid;
  bool failed = false;
  DocumentSnapshot<Map<String, dynamic>>? dataDoc;
  try {
    dataDoc = await FirebaseFirestore.instance
        .collection('notes-meta')
        .doc(noteData.ownerId)
        .get();
  } on FirebaseException catch (e) {
    // My security rules block attempts to get a document that doesn't exist
    failed = e.code == 'permission-denied';
  }

  // If the document doesn't exist create a new one with the empty NoteData
  if (failed || !dataDoc!.exists) {
    await FirebaseFirestore.instance
        .collection('notes-meta')
        .doc(noteData.ownerId)
        .set(noteData.toJson());
  } else {
    // Import metadata and download notes
    noteData = NoteData.fromJson(dataDoc.data()!);
    await noteData.downloadAllNotes();
  }

  // Go to homepage
  Navigator.of(context).pushNamed('/home');
}
