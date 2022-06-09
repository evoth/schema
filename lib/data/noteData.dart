import 'package:alert_dialog/alert_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:schema/data/themeData.dart';
import 'package:schema/functions/auth.dart';
import 'package:schema/functions/constants.dart';
import 'package:schema/functions/general.dart';
import 'package:schema/functions/init.dart';
import 'package:schema/models/noteModel.dart';
import 'package:schema/models/noteWidgetModel.dart';
import 'package:schema/routes/homePage.dart';
import 'package:schema/routes/loadingPage.dart';
import 'package:schema/routes/noteEditPage.dart';
import 'package:schema/widgets/noteAddLabelWidget.dart';
part 'noteData.g.dart';

// Keeps track of notes and metadata
@JsonSerializable()
class NoteData {
  // List of Note objects used to display and edit
  @JsonKey(ignore: true)
  List<Note> notes = [];
  // Various counters
  int noteIdCounter = 0;
  int labelIdCounter = 0;
  int numNotes = 0;
  // Map of label ids and their details
  Map<int, Map<String, dynamic>> labels = {};
  // Map of note ids and their details
  Map<int, Map<String, dynamic>> noteMeta = {};
  // Relatively self-explanatory
  @JsonKey(fromJson: _rawTimeStamp, toJson: _rawTimeStamp)
  Timestamp timeRegistered = Timestamp.now();
  String? ownerId;
  bool isAnonymous = true;
  String? email;
  bool transferred = false;
  // Theme data
  int themeColorId = Constants.themeDefaultColorId;
  bool themeIsDark = Constants.themeDefaultIsDark;
  bool themeIsMonochrome = Constants.themeDefaultIsMonochrome;

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
    this.transferred = copyData.transferred;
    this.themeColorId = copyData.themeColorId;
    this.themeIsDark = copyData.themeIsDark;
    this.themeIsMonochrome = copyData.themeIsMonochrome;
  }

  // Shifts indices by the given amount, starting at a certain index (default 0)
  // If onlyTemp is true, only change temp indices
  void shiftNoteIndices(int amount, {int index = 0, bool onlyTemp = false}) {
    for (Note note in notes) {
      if (note.index(this) >= index) {
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
    notes[index].tempIndex = notes[index].index(this);
    return note;
  }

  // Adds a new (empty) note and inserts at index 0 (returns new note)
  Note newNote(int? filterLabelId, {Note? note}) {
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
        note != null ? note.title : '',
        note != null ? note.text : '',
        isNew: note == null,
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
      addLabel(newNote, filterLabelId);
    } else {
      updateData();
    }
    updateNote(newNote);
    return newNote;
  }

  // Remove note from current view
  void removeNote(int tempIndex) {
    notes.removeAt(tempIndex);
    shiftNoteIndices(-1, index: tempIndex, onlyTemp: true);
  }

  // Deletes note and shifts indices
  void deleteNote(BuildContext context, int index, Function refreshNotes,
      {String? message}) {
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

    // Navigate to the second screen.
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => NoteEditPage(noteWidgetData),
      ),
    );

    // Note is now done being edited
    note.isNew = false;
    // If note does not have label currently being filtered, remove from view
    if (noteWidgetData.filterLabelId != null &&
        !note.hasLabel(this, noteWidgetData.filterLabelId!)) {
      removeNote(note.tempIndex);
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
      (a, b) => a.index(this).compareTo(b.index(this)),
    );
  }

  // Downloads metadata (creating new if necessary) and downloads notes that fit
  // the query and have been newly updated, keeping any already up-to-date notes
  // TODO: create variables for each type of query
  Future<void> updateNotes(BuildContext context, int? filterLabelId) async {
    NoteData? newNoteData;

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
      newNoteData = NoteData.fromJson(dataDoc.data()!);
      if (newNoteData.ownerId == ownerId) {
        setNoteData(newNoteData);
      }
    }

    await FirebaseFirestore.instance.enableNetwork();

    // Attempts to get user data
    tryData = await tryQuery(
      () async => await FirebaseFirestore.instance
          .collection('notes-meta')
          .doc(ownerId)
          .get(),
    );
    failed = tryData.status != 0;
    dataDoc = tryData.returnValue;

    // If the document doesn't exist, create a new one with the empty NoteData
    if (!failed && !dataDoc!.exists) {
      await FirebaseFirestore.instance
          .collection('notes-meta')
          .doc(ownerId)
          .set(toJson());
      noteData = NoteData(
        ownerId: ownerId,
        isAnonymous: isAnonymous,
        email: email,
      );
      return;
    } else if (!failed && dataDoc!.exists) {
      // Import metadata
      newNoteData = NoteData.fromJson(dataDoc.data()!);
    }

    // We couldn't get metadata from cache or online, so something is wrong
    if (newNoteData == null) {
      showAlert(context, Constants.updateNotesErrorMessage, useSnackbar: true);
      return;
    }

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
      if (!failed && !noteDoc!.exists) {
        noteMeta.remove(noteId);
        updateData();
      } else if (!failed && noteDoc!.exists) {
        // Adds note from database
        newNotes.add(Note.fromJson(noteDoc.data()!));
      } else if (failed) {
        error = true;
      }
    }

    // Errors in other methods will result in getting from database. If there is
    // an error here, something has gone wrong.
    if (error) {
      showAlert(context, Constants.updateNotesErrorMessage, useSnackbar: true);
    }

    // Sorts notes according to index
    newNotes.sort(
      (a, b) => newNoteData!.noteMeta[a.id]?['index']
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

  // Transfers all notes from one account (anonymous) to another (Google), upon
  // user's sign in and prompting for transfer options (use cloud function in
  // future so there's no possibility of deleting someone's notes)
  Future<void> transferNotes(BuildContext context) async {
    // Gets all notes for current user to prepare for transfer
    await updateNotes(context, null);

    // Gets Google credential first, so that we can still access this account
    // during the transfer or in case of an error
    final AuthCredential? credential = await getGoogleCredential(context);

    if (credential == null) {
      return;
    }

    // Asks user whether to transfer data
    bool transfer = await confirm(
      context,
      title: Text(Constants.transferTitle),
      content: Text(Constants.transferMessage),
      textCancel: Text(Constants.transferCancel),
      textOK: Text(Constants.transferOK),
    );

    // If no, confirms again to make sure, canceling if not sure
    if (!transfer) {
      transfer = !(await confirm(
        context,
        title: Text(Constants.transferDeleteTitle),
        content: Text(Constants.transferDeleteMessage),
        textOK: Text(Constants.transferDeleteOK),
      ));
      if (!transfer) {
        // Sign in with the new AuthCredential without transferring
        FirebaseAuth.instance.signInWithCredential(credential);
      }
      return;
    }

    // Push loading screen with transferring text
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => LoadingPage(
          text: Constants.transferLoading,
        ),
      ),
    );

    // Marks account as transferred and updates data one last time
    transferred = true;
    await updateData();

    // Attemps to sign in with the new AuthCredential
    User? newUser;
    try {
      newUser =
          (await FirebaseAuth.instance.signInWithCredential(credential)).user;
      if (newUser == null) {
        signInError(context);
        return;
      }
    } catch (e) {
      signInError(context);
      return;
    }

    // Gets all of the note data for the new user
    NoteData newNoteData = NoteData(
      ownerId: newUser.uid,
      isAnonymous: newUser.isAnonymous,
      email: newUser.email,
    );
    await newNoteData.updateNotes(context, null);

    // Add labels from old user, merging any that share the same name and
    // storing which new ids go with which old ones (to be used when
    // transferring notes)
    int newLabelId;
    for (int labelId in labels.keys) {
      if (newNoteData.labelExists(labelName(labelId))) {
        newLabelId = newNoteData.getLabelId(labelName(labelId));
      } else {
        newLabelId = newNoteData.newLabel(labelName(labelId));
      }
      labels[labelId]?['newId'] = newLabelId;
    }

    // Transfers notes over, adding them to the new noteData and translating
    // the ids of their labels to the new ones (reversed because each note gets
    // inserted at the beginning)
    Note newNote;
    for (Note note in notes.reversed) {
      newNote = newNoteData.newNote(null, note: note);
      for (int labelId in note.getLabels(this)) {
        newNoteData.addLabel(newNote, labels[labelId]?['newId']);
      }
    }

    // Transfers remaining data
    newNoteData.updateData(resetNums: true);
    setNoteData(newNoteData);
    notes = newNoteData.notes;

    // Updates theme
    themeData.updateTheme();

    // Go to homepage
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => HomePage(),
      ),
    );

    // Shows transfer complete message
    showAlert(context, Constants.transferCompleteMessage);
  }

  // Gets list of all label ids
  List<int> getLabels() {
    List<int> labelIds = labels.keys.toList();
    // Sorts labels alphabetically
    labelIds.sort(
      (a, b) => labelName(a).compareTo(labelName(b)),
    );
    return labelIds;
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

  // Returns the id of the label with the given name
  int getLabelId(String name) {
    for (int labelId in labels.keys) {
      if (labelName(labelId).toLowerCase() == name.toLowerCase()) {
        return labelId;
      }
    }
    return -1;
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

  NoteData({required this.ownerId, this.isAnonymous = true, this.email});

  factory NoteData.fromJson(Map<String, dynamic> json) =>
      _$NoteDataFromJson(json);
  Map<String, dynamic> toJson() => _$NoteDataToJson(this);
}

NoteData noteData = NoteData(ownerId: null);
