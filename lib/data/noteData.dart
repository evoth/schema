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
// TODO: more useful return values for functions (see newNote)
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

  // Sets note data except for ignored fields
  // TODO: find a better way
  void setNoteData(NoteData data) {
    NoteData copyData = NoteData.fromJson(data.toJson());
    this.noteIdCounter = copyData.noteIdCounter;
    this.labelIdCounter = copyData.labelIdCounter;
    this.numNotes = copyData.numNotes;
    this.labels = copyData.labels;
    this.noteMeta = copyData.noteMeta;
    this.timeRegistered = copyData.timeRegistered;
    this.ownerId = copyData.ownerId;
    this.isAnonymous = copyData.isAnonymous;
    this.email = copyData.email;
  }

  // Shifts indices by the given amount, starting at a certain index (default 0)
  // If onlyTemp is true, only change temp indices
  void shiftNoteIndices(int amount, {int index = 0, bool onlyTemp = false}) {
    for (Note note in notes) {
      if (note.index() >= index) {
        note.tempIndex += amount;
      }
    }
    if (!onlyTemp) {
      for (int id in noteMeta.keys) {
        if (noteMeta[id]?['index'] >= index) {
          noteMeta[id]?['index'] += amount;
        }
      }
    }
  }

  // Adds a specified note at a certain index, or at the end by default
  // (returns new note)
  Note addNote(Note note, {int? index}) {
    // Adds note object to notes list
    index = index ?? notes.length;
    notes.insert(index, note);
    notes[index].tempIndex = notes[index].index();
    return note;
  }

  // Adds a new (empty) note and inserts at index 0 (returns new note)
  Note newNote(int? filterLabelId) {
    // Shifts other notes forward
    shiftNoteIndices(1);
    // Updates note metadata
    noteMeta[noteIdCounter] = {
      'index': 0,
      'timeCreated': Timestamp.now(),
      'timeUpdated': Timestamp.now(),
      'labels': {},
    };
    // Adds the note to the list
    Note newNote = addNote(
      Note(
        noteIdCounter,
        '',
        '',
        isNew: true,
        ownerId: ownerId,
      ),
      index: 0,
    );
    // Update counters
    noteIdCounter++;
    numNotes++;
    // Updates note data and returns new note. If filtering by label, add this
    // label to new note (which will update data). Otherwise, only update data.
    if (filterLabelId != null) {
      noteData.addLabel(newNote, filterLabelId);
    } else {
      updateData();
    }
    return newNote;
  }

  // Remove note from current view
  void removeNote(int tempIndex) {
    notes.removeAt(tempIndex);
    shiftNoteIndices(-1, index: tempIndex, onlyTemp: true);
  }

  // Deletes note and shifts indices
  Future<void> deleteNote(
      BuildContext context, int index, Function refreshNotes,
      {String? message}) async {
    // Deletes from database
    tryQuery(
      () => FirebaseFirestore.instance
          .collection('notes')
          .doc(ownerId! + '-' + notes[index].id.toString())
          .delete(),
    );
    // Decreases respective label counters
    for (String labelId in noteMeta[notes[index].id]?['labels'].keys) {
      labels[int.parse(labelId)]?['numNotes']--;
    }
    // Removes note and shifts other notes
    noteMeta.remove(notes[index].id);
    notes.removeAt(index);
    shiftNoteIndices(-1, index: index);
    // Updates metadata
    numNotes--;
    updateData();
    showAlert(context, message ?? Constants.deleteMessage, useSnackbar: true);
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
    // If note does not have label currently being filtered, remove from view
    if (noteWidgetData.filterLabelId != null &&
        !note.hasLabel(noteWidgetData.filterLabelId!)) {
      noteData.removeNote(note.tempIndex);
    }
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
    };
    labelIdCounter++;
    updateData();
    return labelIdCounter - 1;
  }

  // Deletes label
  void deleteLabel(int labelId) {
    // Removes from any notes that may have this label
    for (int noteId in noteMeta.keys) {
      noteMeta[noteId]?.remove(labelId.toString());
    }
    labels.remove(labelId);
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

  // Downloads all notes as one query from database
  Future<void> downloadAllNotes() async {
    notes = [];

    QuerySnapshot<Map<String, dynamic>> noteDocs = await FirebaseFirestore
        .instance
        .collection('notes')
        .where('ownerId', isEqualTo: ownerId)
        .get();

    for (var element in noteDocs.docs) {
      addNote(Note.fromJson(element.data()));
    }

    notes.sort(
      (a, b) => a.index().compareTo(b.index()),
    );
  }

  // Downloads metadata (creating new if necessary) and downloads notes that fit
  // the query and have been newly updated, keeping any already up-to-date notes
  // TODO: create variables for each type of query
  Future<void> updateNotes(BuildContext context, int? filterLabelId) async {
    // Attempts to get user data already stored in cache
    await FirebaseFirestore.instance.disableNetwork();

    TryData tryData = await tryQuery(
      () async => await FirebaseFirestore.instance
          .collection('notes-meta')
          .doc(ownerId)
          .get(),
    );
    bool failed = tryData.status != 0;
    DocumentSnapshot<Map<String, dynamic>>? dataDoc = tryData.returnValue;

    // Update local noteData from cache
    if (!failed && dataDoc!.exists) {
      setNoteData(NoteData.fromJson(dataDoc.data()!));
    }

    await FirebaseFirestore.instance.enableNetwork();

    // Attempts to get user data
    tryData = await tryQuery(
      () async => await FirebaseFirestore.instance
          .collection('notes-meta')
          .doc(ownerId)
          .get(),
    );
    failed = tryData.status == 2;
    dataDoc = tryData.returnValue;

    // If the document doesn't exist, create a new one with the empty NoteData
    if (failed || !dataDoc!.exists) {
      await FirebaseFirestore.instance
          .collection('notes-meta')
          .doc(ownerId)
          .set(toJson());
      return;
    }

    // Import metadata
    NoteData newNoteData = NoteData.fromJson(dataDoc.data()!);

    // Disable network access so that we can check notes that are cached
    await FirebaseFirestore.instance.disableNetwork();

    // If the user has changed, download all notes before continuing
    bool isSameUser = ownerId == newNoteData.ownerId;
    if (!isSameUser) {
      downloadAllNotes();
    }

    // Stores current note indices in a map for easy checking and accessing
    Map<int, int> noteIndices = {};
    for (int i = 0; i < notes.length; i++) {
      noteIndices[notes[i].id] = i;
    }

    // Adds all note ids that fit the current label or lack of thereof to a list
    List<int> newNoteIds = [];
    for (int noteId in newNoteData.noteMeta.keys) {
      if (filterLabelId == null ||
          newNoteData.noteMeta[noteId]?['labels']
              .containsKey(filterLabelId.toString())) {
        newNoteIds.add(noteId);
      }
    }

    List<Note> newNotes = [];

    // Attempts to retrieve up-to-date notes that are already on device
    if (isSameUser) {
      for (int i = 0; i < newNoteIds.length; i++) {
        int noteId = newNoteIds[i];
        // Check if note is out of date
        if (noteMeta[noteId]?['timeUpdated'] ==
            newNoteData.noteMeta[noteId]?['timeUpdated']) {
          // Note already exists in notes[] list
          if (noteIndices.containsKey(noteId)) {
            newNotes.add(notes[noteIndices[noteId]!]);
            newNoteIds.removeAt(i);
            i--;
          } else {
            // Attempts to get note document from cache
            tryData = await tryQuery(
              () async => await FirebaseFirestore.instance
                  .collection('notes')
                  .doc(ownerId! + '-' + noteId.toString())
                  .get(),
            );
            failed = tryData.status != 0;
            DocumentSnapshot<Map<String, dynamic>>? noteDoc =
                tryData.returnValue;

            // Note was in our Firestore cache
            if (!failed && noteDoc!.exists) {
              newNotes.add(Note.fromJson(noteDoc.data()!));
              newNoteIds.removeAt(i);
              i--;
            }
          }
        }
      }
    }

    // Enable network access so that we can get remaining notes from the cloud
    await FirebaseFirestore.instance.enableNetwork();

    bool error = false;
    for (int noteId in newNoteIds) {
      // Attempts to get note document from database
      tryData = await tryQuery(
        () async => await FirebaseFirestore.instance
            .collection('notes')
            .doc(ownerId! + '-' + noteId.toString())
            .get(),
      );
      failed = tryData.status != 0;
      DocumentSnapshot<Map<String, dynamic>>? noteDoc = tryData.returnValue;

      // Removes note that doesn't exist in database
      if (tryData.status == 2) {
        noteMeta.remove(noteId);
        updateData();
      } else if (tryData.status == 1) {
        error = true;
      }

      // Adds note from database
      if (!failed && noteDoc!.exists) {
        newNotes.add(Note.fromJson(noteDoc.data()!));
      }
    }

    // Errors in other methods will result in getting from database. If there is
    // an error here, something has gone wrong.
    if (error) {
      showAlert(context, Constants.updateNotesErrorMessage, useSnackbar: true);
    }

    // Sorts notes according to index
    newNotes.sort(
      (a, b) => newNoteData.noteMeta[a.id]?['index']
          .compareTo(newNoteData.noteMeta[b.id]?['index']),
    );

    // Sets tempIndex, which is used to order notes in the grid
    for (int i = 0; i < newNotes.length; i++) {
      newNotes[i].tempIndex = i;
    }

    // Updates data
    updateData(resetNums: true);
    setNoteData(newNoteData);
    notes = newNotes;
  }

  // Gets list of all label ids
  List<int> getLabels() {
    return labels.keys.toList();
  }

  // Returns whether a label with the given name exists and is not deleted
  bool labelExists(String name) {
    for (Map<String, dynamic> label in labels.values) {
      if (label['name'].toLowerCase() == name.toLowerCase()) {
        return true;
      }
    }
    return false;
  }

  // Overrides contents of note document with updated note
  void updateNote(Note note) {
    Map<String, dynamic> noteJson = note.toJson();
    updateData();
    FirebaseFirestore.instance
        .collection('notes')
        .doc(ownerId! + '-' + note.id.toString())
        .set(noteJson);
  }

  // Updates note metadata document for the user
  Future<void> updateData({bool resetNums = false}) async {
    // Resets note counts (in case of desync)
    if (resetNums) {
      numNotes = 0;
      for (int labelId in labels.keys) {
        labels[labelId]?['numNotes'] = 0;
      }
      for (int noteId in noteMeta.keys) {
        numNotes++;
        for (String labelId in noteMeta[noteId]?['labels'].keys) {
          labels[int.parse(labelId)]?['numNotes']++;
        }
      }
    }
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
