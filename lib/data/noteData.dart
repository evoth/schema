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

  void incId() {
    idCounter++;
  }

  // Adds a specified note
  void addNote(Note note) {
    // Adds note object to notes list
    notes.add(note);
    // Updates note metadata
    noteMeta[notes.last.id] = {
      'index': notes.length - 1,
      'timeUpdated': DateTime.now(),
    };
    notes.last.tempIndex = notes.last.index();
    // Increases id counter by 1
    incId();
  }

  // Adds a new (empty) note
  void newNote() {
    addNote(
      Note(
        noteData.idCounter,
        '',
        '',
        isNew: true,
      ),
    );
  }

  // Removes note and shifts indices
  void deleteNote(int index) {
    notes[index].isDeleted = true;
    notes.removeAt(index);
    for (int i = index; i < notes.length; i++) {
      notes[i].setIndex(notes[i].index() - 1);
      notes[i].tempIndex--;
    }
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
      // TODO: Update note
    }
  }

  NoteData();

  factory NoteData.fromJson(Map<String, dynamic> json) =>
      _$NoteDataFromJson(json);
  Map<String, dynamic> toJson() => _$NoteDataToJson(this);
}

NoteData noteData = NoteData();
