import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:schema/models/noteModel.dart';
import 'package:schema/models/noteWidgetModel.dart';
part 'noteData.g.dart';

// Keeps track of notes and counts id
@JsonSerializable()
class NoteData {
  @JsonKey(ignore: true)
  List<Note> notes = [];
  int idCounter = 0;
  Map<int, Map> noteMeta = {};
  DateTime timeRegistered = DateTime.now();
  String? ownerId;

  void incId() {
    idCounter++;
  }

  // Adds a specified note
  void addNote(Note note) {
    // Adds note object to notes list
    notes.add(note);
    notes.last.tempIndex = notes.last.index();
    // Increases id counter by 1
    incId();
  }

  // Adds a new (empty) note
  void newNote() {
    // Updates note metadata
    noteMeta[noteData.idCounter] = {
      'index': notes.length,
      'timeUpdated': DateTime.now(),
      'deleted': false,
    };
    addNote(
      Note(
        noteData.idCounter,
        '',
        '',
        isNew: true,
        ownerId: noteData.ownerId,
      ),
    );
  }

  // Removes note and shifts indices
  Future<void> deleteNote(int index) async {
    notes[index].isDeleted = true;
    noteMeta[notes[index].id]?['deleted'] = true;
    await noteData.updateNote(notes[index]);
    notes.removeAt(index);
    for (int i = index; i < notes.length; i++) {
      notes[i].setIndex(notes[i].index() - 1);
      notes[i].tempIndex--;
    }
    await noteData.updateData();
  }

  // Pushes edit screen and calls note edit function
  Future<void> editNote(
    BuildContext context,
    NoteWidgetData noteWidgetData,
  ) async {
    Note note = noteWidgetData.note;
    // Store text and title before editing
    note.previousTitle = note.title;
    note.previousText = note.text;
    // Navigate to the second screen using a named route.
    await Navigator.pushNamed(
      context,
      '/edit',
      arguments: noteWidgetData,
    );
    note.isNew = false;
    // Updates notes on home screen
    noteWidgetData.edit(note.index());
    // Updates note in database if anything has changed
    if (note.previousTitle != note.title || note.previousText != note.text) {
      noteData.noteMeta[note.id]?['timeUpdated'] = DateTime.now();
      noteData.updateNote(note);
    }
  }

  Future<void> downloadAllNotes() async {
    notes = [];

    QuerySnapshot<Map<String, dynamic>> noteDocs = await FirebaseFirestore
        .instance
        .collection('notes')
        .where('ownerId', isEqualTo: ownerId)
        .where('isDeleted', isEqualTo: false)
        .get();

    for (var element in noteDocs.docs) {
      addNote(Note.fromJson(element.data()));
    }

    notes.sort(
      (a, b) => a.index().compareTo(b.index()),
    );
  }

  Future<void> downloadNote(int id) async {
    DocumentSnapshot<Map<String, dynamic>> noteDoc = await FirebaseFirestore
        .instance
        .collection('notes')
        .doc(noteData.ownerId! + '-' + id.toString())
        .get();

    addNote(Note.fromJson(noteDoc.data()!));
  }

  Future<void> updateNote(Note note) async {
    await updateData();
    await FirebaseFirestore.instance
        .collection('notes')
        .doc(noteData.ownerId! + '-' + note.id.toString())
        .set(note.toJson());
  }

  Future<void> updateData() async {
    await FirebaseFirestore.instance
        .collection('notes-meta')
        .doc(noteData.ownerId)
        .set(noteData.toJson());
  }

  NoteData({required this.ownerId});

  factory NoteData.fromJson(Map<String, dynamic> json) =>
      _$NoteDataFromJson(json);
  Map<String, dynamic> toJson() => _$NoteDataToJson(this);
}

NoteData noteData = NoteData(ownerId: null);
