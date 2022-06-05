import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:schema/functions/constants.dart';
import 'package:schema/functions/general.dart';
import 'package:schema/models/noteModel.dart';
import 'package:schema/models/noteWidgetModel.dart';
import 'package:schema/routes/noteEditPage.dart';
import 'package:schema/widgets/noteAddLabelWidget.dart';
part 'noteData.g.dart';

// Keeps track of notes and metadata
@JsonSerializable()
class NoteData {
  @JsonKey(ignore: true)
  List<Note> notes = [];
  int noteIdCounter = 0;
  int labelIdCounter = 0;
  int numNotes = 0;
  Map<int, Map<String, dynamic>> labels = {};
  Map<int, Map<String, dynamic>> noteMeta = {};
  @JsonKey(fromJson: _rawTimeStamp, toJson: _rawTimeStamp)
  Timestamp timeRegistered = Timestamp.now();
  String? ownerId;
  bool isAnonymous = true;
  String? email;

  static Timestamp _rawTimeStamp(t) => t as Timestamp;

  // Adds a specified note
  void addNote(Note note) {
    // Adds note object to notes list
    notes.add(note);
    notes.last.tempIndex = notes.last.index();
  }

  // Adds a new (empty) note
  void newNote() {
    // Updates note metadata
    noteMeta[noteIdCounter] = {
      'index': notes.length,
      'timeCreated': Timestamp.now(),
      'timeUpdated': Timestamp.now(),
      'isDeleted': false,
      'labels': {},
    };
    // Adds the note to the list
    addNote(
      Note(
        noteIdCounter,
        '',
        '',
        isNew: true,
        ownerId: ownerId,
      ),
    );
    // Update counters
    noteIdCounter++;
    numNotes++;
  }

  // Removes note and shifts indices
  Future<void> deleteNote(
      BuildContext context, int index, Function refreshNotes) async {
    // Marks note as deleted
    notes[index].isDeleted = true;
    noteMeta[notes[index].id]?['isDeleted'] = true;
    await updateNote(notes[index]);
    // Decreases respective label counters
    for (String labelId in noteMeta[notes[index].id]?['labels'].keys) {
      labels[int.parse(labelId)]?['numNotes']--;
    }
    // Removes note and shifts other notes
    notes.removeAt(index);
    for (int i = index; i < notes.length; i++) {
      notes[i].setIndex(notes[i].index() - 1);
      notes[i].tempIndex--;
    }
    // Updates metadata
    numNotes--;
    updateData();
    showAlert(context, Constants.deleteMessage, useSnackbar: true);
    refreshNotes();
  }

  // Pushes edit screen and calls note edit function
  Future<void> editNote(
    BuildContext context,
    NoteWidgetData noteWidgetData,
    Function refreshNotes,
  ) async {
    Note note = noteWidgetData.note;
    // Store text and title before editing
    note.previousTitle = note.title;
    note.previousText = note.text;
    // Navigate to the second screen using a named route.
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => NoteEditPage(noteWidgetData),
      ),
    );
    note.isNew = false;
    // Updates notes on home screen
    refreshNotes();
    // Updates note in database if anything has changed
    if (note.previousTitle != note.title || note.previousText != note.text) {
      noteMeta[note.id]?['timeUpdated'] = Timestamp.now();
      updateNote(note);
    }
  }

  // Adds new label with the specified name
  int newLabel(String name) {
    labels[labelIdCounter] = {
      'name': name,
      'numNotes': 0,
      'isDeleted': false,
    };
    labelIdCounter++;
    updateData();
    return labelIdCounter - 1;
  }

  // Marks a label as deleted
  void deleteLabel(int labelId) {
    labels[labelId]?['isDeleted'] = true;
    updateData();
  }

  // Adds a label to a note (we use a map instead of a list for access speed)
  void addLabel(Note note, int labelId) {
    // Convert label id to string because of strange error
    noteMeta[note.id]?['labels'][labelId.toString()] = true;
    labels[labelId]?['numNotes']++;
    updateData();
  }

  // Removes a label from a note
  void removeLabel(Note note, int labelId) {
    noteMeta[note.id]?['labels'].remove(labelId.toString());
    labels[labelId]?['numNotes']--;
    updateData();
  }

  // Edit label name
  void editLabelName(BuildContext context, int labelId, String name) async {
    String? checkedName = await checkLabelName(context, name);
    if (checkedName == null || checkedName == labels[labelId]?['name']) {
      return;
    }
    labels[labelId]?['name'] = checkedName;
    updateData();
  }

  // Gets name of label
  String labelName(int labelId) {
    return labels[labelId]?['name'];
  }

  // TODO
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

  // Gets list of all label ids
  List<int> getLabels() {
    return labels.keys
        .where((labelId) => !labels[labelId]?['isDeleted'])
        .toList();
  }

  // Returns whether a label with the given name exists and is not deleted
  bool labelExists(String name) {
    for (Map<String, dynamic> label in labels.values) {
      if (label['name'].toLowerCase() == name.toLowerCase() &&
          !label['isDeleted']) {
        return true;
      }
    }
    return false;
  }

  /*
  Future<void> downloadNote(int id) async {
    DocumentSnapshot<Map<String, dynamic>> noteDoc = await FirebaseFirestore
        .instance
        .collection('notes')
        .doc(ownerId! + '-' + id.toString())
        .get();

    addNote(Note.fromJson(noteDoc.data()!));
  }
  */

  // Overrides contents of note document with updated note
  Future<void> updateNote(Note note) async {
    await updateData();
    await FirebaseFirestore.instance
        .collection('notes')
        .doc(ownerId! + '-' + note.id.toString())
        .set(note.toJson());
  }

  // Updates note metadata document for the user
  Future<void> updateData() async {
    await FirebaseFirestore.instance
        .collection('notes-meta')
        .doc(ownerId)
        .set(toJson());
  }

  NoteData({required this.ownerId});

  factory NoteData.fromJson(Map<String, dynamic> json) =>
      _$NoteDataFromJson(json);
  Map<String, dynamic> toJson() => _$NoteDataToJson(this);
}

NoteData noteData = NoteData(ownerId: null);
