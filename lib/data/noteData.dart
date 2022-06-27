import 'dart:async';
import 'dart:math';

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
import 'package:schema/models/noteModel.dart';
import 'package:schema/models/noteWidgetModel.dart';
import 'package:schema/routes/homePage.dart';
import 'package:schema/routes/loadingPage.dart';
import 'package:schema/routes/noteEditPage.dart';
import 'package:schema/widgets/heroDialogRoute.dart';
import 'package:schema/widgets/noteAddLabelWidget.dart';
part 'noteData.g.dart';

// Keeps track of notes and metadata
@JsonSerializable()
class NoteData {
  // List of Note objects used to display and edit
  @JsonKey(ignore: true)
  List<Note> notes = [];
  // Total number of notes
  int numNotes = 0;
  // Map of label ids and their details
  Map<String, Map<String, dynamic>> labels = {};
  // Map of note ids and their details
  Map<String, Map<String, dynamic>> noteMeta = {};
  // Relatively self-explanatory
  @JsonKey(fromJson: _rawTimeStamp, toJson: _rawTimeStamp)
  Timestamp timeRegistered = timestampNowRounded();
  String? ownerId;
  bool isAnonymous = true;
  String? email;
  // Whether we are currently transferring notes
  @JsonKey(ignore: true)
  bool isTransferring = false;
  // Whether we are currently deleting notes (and thus should not update)
  @JsonKey(ignore: true)
  bool isDeleting = false;
  // Whether we have just gone online (and should therefore update notes)
  @JsonKey(ignore: true)
  bool isBackOnline = false;
  // Theme data
  int themeColorId = Constants.themeDefaultColorId;
  bool themeIsDark = Constants.themeDefaultIsDark;
  bool themeIsMonochrome = Constants.themeDefaultIsMonochrome;
  // Time that the theme was most recently updated (used in offline merge)
  @JsonKey(fromJson: _rawTimeStamp, toJson: _rawTimeStamp)
  Timestamp themeTimeUpdated = timestampNowRounded();
  // Layout data
  int layoutDimensionId = 0;
  // Time that the layout was most recently updated (used in offline merge)
  @JsonKey(fromJson: _rawTimeStamp, toJson: _rawTimeStamp)
  Timestamp layoutTimeUpdated = timestampNowRounded();
  // Time that we most recently went offline
  @JsonKey(fromJson: _rawTimeStamp, toJson: _rawTimeStamp)
  Timestamp timeOffline = timestampNowRounded();
  // Whether we are online
  bool isOnline = true;

  static Timestamp _rawTimeStamp(t) => t as Timestamp;

  // Sets note data except for ignored fields
  // TODO: find a better way
  void setNoteData(NoteData data) {
    NoteData copyData = NoteData.fromJson(data.toJson());
    this.numNotes = copyData.numNotes;
    this.labels = copyData.labels;
    this.noteMeta = copyData.noteMeta;
    this.timeRegistered = copyData.timeRegistered;
    this.ownerId = copyData.ownerId;
    this.isAnonymous = copyData.isAnonymous;
    this.email = copyData.email;
    this.themeColorId = copyData.themeColorId;
    this.themeIsDark = copyData.themeIsDark;
    this.themeIsMonochrome = copyData.themeIsMonochrome;
    this.themeTimeUpdated = copyData.themeTimeUpdated;
    this.layoutDimensionId = copyData.layoutDimensionId;
    this.layoutTimeUpdated = copyData.layoutTimeUpdated;
    this.timeOffline = copyData.timeOffline;
    this.isOnline = copyData.isOnline;
  }

  // Shifts indices by the given amount, starting at a certain index (default 0)
  // If onlyTemp is true, only change temp indices
  void shiftNoteIndices(int amount, {int index = 0, bool onlyTemp = false}) {
    for (Note note in notes) {
      if (note.index >= index) {
        note.tempIndex += amount;
      }
    }
    if (!onlyTemp) {
      for (String id in noteMeta.keys) {
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
    // Actually insert note and populate tempIndex
    notes.insert(index, note);
    notes[index].tempIndex = notes[index].index;
    notes[index].data = this;
    return note;
  }

  // Adds a new (empty) note and inserts at index 0 (returns new note)
  Note newNote(String? filterLabelId, {Note? note, bool update = true}) {
    // Shifts other notes forward
    shiftNoteIndices(1);
    // New note id is the current time in milliseconds
    Timestamp timeCreated = timestampNowRounded();
    String newNoteId = getUniqueId();
    // Updates note metadata
    noteMeta[newNoteId] = {
      'index': 0,
      'timeCreated': timeCreated,
      'timeUpdated': timeCreated,
      'labels': {},
    };

    // Adds the note to the list
    Note newNote = addNote(
      Note(
        newNoteId,
        note != null ? note.title : '',
        note != null ? note.text : '',
        isNew: note == null,
        ownerId: ownerId,
      ),
      index: 0,
    );

    // Update counter
    numNotes++;
    // Updates note data and returns new note. If filtering by label, add this
    // label to new note. Don't update because we already update on next line.
    if (filterLabelId != null) {
      newNote.addLabel(filterLabelId, update: false);
    }
    updateNote(newNote, update: update);
    return newNote;
  }

  // Remove note from current view if it still exists there
  void removeNote(Note note) {
    if (notes[note.tempIndex].id == note.id) {
      notes.removeAt(note.tempIndex);
      shiftNoteIndices(-1, index: note.tempIndex, onlyTemp: true);
    }
  }

  // Deletes note and shifts indices if the note still exists
  void deleteNote(BuildContext context, Note note, Function refreshNotes,
      {String? message}) {
    if (notes[note.tempIndex].id == note.id) {
      // Deletes from database if we are online. Otherwise, we will wait until
      // we are online to decide whether the document should be deleted
      if (isOnline) {
        tryQuery(
          () => noteDocRef(note.id).delete(),
        );
      }

      // Decreases respective label counters
      for (String labelId in noteMeta[note.id]?['labels'].keys) {
        labels[labelId]?['numNotes']--;
      }
      // Removes note and shifts other notes
      noteMeta.remove(note.id);
      notes.removeAt(note.tempIndex);
      shiftNoteIndices(-1, index: note.tempIndex);
      // Updates metadata
      numNotes--;
      updateData();
      showAlert(context, message ?? Constants.deleteMessage, useSnackbar: true);
      refreshNotes();
    }
  }

  // Saves note after 3 seconds of inactivity. Set wait to false to save
  // immediately.
  Future<void> saveNote(Note note, {bool wait = true}) async {
    note.editTicker++;
    note.isSavedNotifier.value = false;
    int currentTicker = note.editTicker;

    if (wait) {
      await Future.delayed(Duration(seconds: Constants.saveInactivityDuration));
    }

    // If this function has not run in the last 3 seconds, update note
    if (note.editTicker == currentTicker) {
      // Updates note in database if anything has changed
      if (note.previousTitle != note.title || note.previousText != note.text) {
        note.timeUpdated = timestampNowRounded();
        updateNote(note);
      }
      // Updates edit state
      note.previousTitle = note.title;
      note.previousText = note.text;
      note.isSavedNotifier.value = true;
      note.editTicker = 0;
    }
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
    // Reset edit state
    note.isSavedNotifier.value = true;
    note.editTicker = 0;

    // Navigate to the second screen and wait until it is popped. If we are on
    // mobile, navigate to edit screen as usual. Otherwise, display as modal for
    // a more user friendly reading/editing experience
    if (isMobileDevice()) {
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => NoteEditPage(noteWidgetData),
        ),
      );
    } else {
      // Dialog with the note edit page
      /*await showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          // Constrained to a reasonable size for easier reading
          content: SizedBox(
            width: Constants.editWidth,
            height: Constants.editHeight,
            child: NoteEditPage(
              noteWidgetData,
              isDialog: true,
            ),
          ),
          // Equal padding except bottom to compensate for padding in EditPage
          contentPadding: EdgeInsets.fromLTRB(
            Constants.editDialogPadding,
            Constants.editDialogPadding,
            Constants.editDialogPadding,
            Constants.editDialogPadding + Constants.editPadding,
          ),
          // Simulates overlaying note color onto canvas color
          backgroundColor: Color.alphaBlend(
            Theme.of(context)
                .backgroundColor
                .withOpacity(Constants.noteOpacity),
            Theme.of(context).canvasColor,
          ),
        ),
      );*/

      await Navigator.of(context).push(
        HeroDialogRoute(
          duration: Constants.noteHeroDuration,
          builder: (BuildContext context) {
            return Center(
              // Constrained to a reasonable size for easier reading
              child: SizedBox(
                width: Constants.editWidth,
                height: Constants.editHeight,
                // Hero transition to and from note in grid
                child: Hero(
                  tag: note.id,
                  child: AlertDialog(
                    // Constrained again because Hero was being strange
                    content: SizedBox(
                      width: Constants.editWidth,
                      height: Constants.editHeight,
                      child: NoteEditPage(
                        noteWidgetData,
                        isDialog: true,
                      ),
                    ),
                    // Equal padding except bottom to compensate for padding in EditPage
                    contentPadding: EdgeInsets.fromLTRB(
                      Constants.editDialogPadding,
                      Constants.editDialogPadding,
                      Constants.editDialogPadding,
                      Constants.editDialogPadding + Constants.editPadding,
                    ),
                    // Simulates overlaying note color onto canvas color
                    backgroundColor: Color.alphaBlend(
                      Theme.of(context)
                          .backgroundColor
                          .withOpacity(Constants.noteOpacity),
                      Theme.of(context).canvasColor,
                    ),
                    insetPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    // Removes note if new and empty
    if (note.isNew && note.title == '' && note.text == '') {
      deleteNote(context, note, refreshNotes,
          message: Constants.discardMessage);
    }
    note.isNew = false;

    // If note does not have label currently being filtered, remove from view
    if (noteWidgetData.filterLabelId != null &&
        !note.hasLabel(noteWidgetData.filterLabelId!)) {
      removeNote(note);
    }
    // Updates notes on home screen
    refreshNotes();
    // Saves note
    await saveNote(note, wait: false);
  }

  // Adds new label with the specified name
  String newLabel(String name, {bool update = true}) {
    // New label id is the current time in milliseconds
    Timestamp timeCreated = timestampNowRounded();
    String newLabelId = getUniqueId();
    labels[newLabelId] = {
      'name': name,
      'numNotes': 0,
      'timeCreated': timeCreated,
      'timeUpdated': timeCreated,
    };
    if (update) {
      updateData();
    }
    return newLabelId;
  }

  // Deletes label
  void deleteLabel(String labelId) {
    // Removes from any notes that may have this label
    for (String noteId in noteMeta.keys) {
      noteMeta[noteId]?.remove(labelId);
    }
    labels.remove(labelId);
    updateData();
  }

  // Edit label name
  void editLabelName(BuildContext context, String labelId, String name) async {
    String? checkedName = await checkLabelName(context, name);
    if (checkedName == null || checkedName == labels[labelId]?['name']) {
      return;
    }
    labels[labelId]?['name'] = checkedName;
    labels[labelId]?['timeUpdated'] = timestampNowRounded();
    updateData();
  }

  // Gets name of label
  String getLabelName(String labelId) {
    return labels[labelId]?['name'] ?? '';
  }

  // Gets list of all label ids
  @JsonKey(ignore: true)
  List<String> get labelIds {
    List<String> labelIds = labels.keys.toList();
    // Sorts labels alphabetically
    labelIds.sort(
      (a, b) => getLabelName(a).compareTo(getLabelName(b)),
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
  String getLabelId(String name) {
    for (String labelId in labels.keys) {
      if (getLabelName(labelId).toLowerCase() == name.toLowerCase()) {
        return labelId;
      }
    }
    return '';
  }

  // Returns DocumentReference to the note with the given id
  DocumentReference noteDocRef(String noteId) {
    return FirebaseFirestore.instance
        .collection('notes')
        .doc(ownerId! + '-' + noteId);
  }

  // Returns DocumentReference to the metadata for the current user. If
  // forceOnline is true, then get the online document regardless of onlineness
  DocumentReference noteDataDocRef({bool forceOnline = false}) {
    if (isOnline || forceOnline) {
      return FirebaseFirestore.instance.collection('notes-meta').doc(ownerId);
    } else {
      return FirebaseFirestore.instance.collection('notes-meta-offline').doc(
          (ownerId!) + '-' + timeOffline.millisecondsSinceEpoch.toString());
    }
  }

  // Sets online status and time offline if necessary. Kicks back online
  // procedure into motion if we're just getting back online
  void setIsOnline(bool newIsOnline) async {
    if (isOnline && !newIsOnline) {
      timeOffline = timestampNowRounded();
    } else if (!isOnline && newIsOnline) {
      // Lets HomePage and updateData know what's going on
      isBackOnline = true;
      // Waits for any pending offline writes
      await updateData();
      // Preeminently sets online status to true for aforementioned functions
      isOnline = true;
      // Triggers metadata document listener in HomePage, without notifying
      // other devices that may be listening so that we can complete the back
      // online process undisturbed
      await noteDataDocRef().update({'denyRequest': true});
    }
    isOnline = newIsOnline;
  }

  // Deletes all online data for specified user (will only work if signed in)
  Future<void> deleteUser() async {
    // Creates local copy of ownerId in case it changes
    String? deleteOwnerId = ownerId;
    // Deletes all note documents in batches to avoid out of memory errors
    QuerySnapshot<Map<String, dynamic>> noteDocs;
    do {
      noteDocs = await FirebaseFirestore.instance
          .collection('notes')
          .where('ownerId', isEqualTo: deleteOwnerId)
          .limit(Constants.deleteBatchSize)
          .get();

      for (var element in noteDocs.docs) {
        await element.reference.delete();
      }
    } while (noteDocs.docs.isNotEmpty);

    // Deletes any metadata in offline collection
    noteDocs = await FirebaseFirestore.instance
        .collection('notes-meta-offline')
        .where('ownerId', isEqualTo: deleteOwnerId)
        .get();

    for (var element in noteDocs.docs) {
      await element.reference.delete();
    }

    // Deletes main metadata document
    await FirebaseFirestore.instance
        .collection('notes-meta')
        .doc(deleteOwnerId)
        .delete();

    // Finally, deletes the actual user from the database
    await FirebaseAuth.instance.currentUser?.delete();
  }

  // Overrides contents of note document with updated note
  void updateNote(Note note, {bool update = true}) {
    Map<String, dynamic> noteJson = note.toJson();
    if (update) {
      updateData();
    }
    noteDocRef(note.id).set(noteJson);
  }

  // Updates note metadata document for the user
  Future<void> updateData({bool resetNums = false}) async {
    // Resets note counts (in case of desync)
    if (resetNums) {
      numNotes = 0;
      for (String labelId in labels.keys) {
        labels[labelId]?['numNotes'] = 0;
      }
      for (String noteId in noteMeta.keys) {
        numNotes++;
        for (String labelId in noteMeta[noteId]?['labels'].keys) {
          labels[labelId]?['numNotes']++;
        }
      }
    }
    // If we are offline, update data as normal. Otherwise, use a special
    // document in the offline collection to store offline session changes
    await tryQuery(() => noteDataDocRef().set(toJson()));
  }

  // Merges data with NoteData representing an offline session
  void mergeOfflineData(NoteData offlineData) {
    // First, iterates through labels in current data
    for (String labelId in labels.keys.toList()) {
      // If label is contained in both, the newer label takes precedent.
      // Otherwise, the label is deleted as long as it was last updated before
      // the device went offline, and thus before it was deleted
      if (offlineData.labels.containsKey(labelId)) {
        labels[labelId] = newerMap(
          labels[labelId]!,
          offlineData.labels[labelId]!,
        );
      } else if (offlineData.timeOffline
              .compareTo(labels[labelId]!['timeUpdated']) >
          0) {
        labels.remove(labelId);
      }
    }
    // Then, iterates through labels in offline data, adding any labels that
    // have been created or updated since we went offline, even if they were
    // deleted before
    for (String labelId in offlineData.labels.keys) {
      if (!labels.containsKey(labelId) &&
          offlineData.timeOffline
                  .compareTo(offlineData.labels[labelId]!['timeUpdated']) <
              0) {
        labels[labelId] = offlineData.labels[labelId]!;
      }
    }

    // Iterates through notes in current data
    for (String noteId in noteMeta.keys.toList()) {
      // Same as above, but for notes. Additionally, we delete the online
      // document if we end up deleting the note, because we wouldn't have done
      // so while offline
      if (offlineData.noteMeta.containsKey(noteId)) {
        noteMeta[noteId] = newerMap(
          noteMeta[noteId]!,
          offlineData.noteMeta[noteId]!,
        );
      } else if (offlineData.timeOffline
              .compareTo(noteMeta[noteId]!['timeUpdated']) >
          0) {
        // Deletes note and its document
        shiftNoteIndices(-1, index: noteMeta[noteId]!['index']);
        noteMeta.remove(noteId);
        tryQuery(
          () => noteDocRef(noteId).delete(),
        );
      }
    }
    // Iterates through notes in offline data, adding any notes that
    // have been created or updated since we went offline, even if they were
    // deleted before
    for (String noteId in offlineData.noteMeta.keys) {
      if (!noteMeta.containsKey(noteId) &&
          offlineData.timeOffline
                  .compareTo(offlineData.noteMeta[noteId]!['timeUpdated']) <
              0) {
        shiftNoteIndices(1);
        noteMeta[noteId] = offlineData.noteMeta[noteId]!;
        noteMeta[noteId]!['index'] = 0;
      }
    }

    // Uses the theme from offline if it was updated more recently
    // TODO: Fix theme reversal behavior
    if (themeTimeUpdated.compareTo(offlineData.themeTimeUpdated) < 0) {
      themeColorId = offlineData.themeColorId;
      themeIsDark = offlineData.themeIsDark;
      themeIsMonochrome = offlineData.themeIsMonochrome;
      themeTimeUpdated = offlineData.themeTimeUpdated;
    }

    // Updates the layout from offline if it was updated more recently
    // TODO: Fix theme reversal behavior
    if (layoutTimeUpdated.compareTo(offlineData.layoutTimeUpdated) < 0) {
      layoutDimensionId = offlineData.layoutDimensionId;
    }
  }

  // Downloads all notes as one query from database
  Future<void> downloadAllNotes() async {
    notes = [];

    QuerySnapshot<Map<String, dynamic>> noteDocs = await FirebaseFirestore
        .instance
        .collection('notes')
        .where('ownerId', isEqualTo: ownerId)
        .get();

    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in noteDocs.docs) {
      addNote(Note.fromJson(doc.data()));
    }

    notes.sort(
      (a, b) => a.index.compareTo(b.index),
    );
  }

  // Downloads metadata (creating new if necessary) and downloads notes that fit
  // the query and have been newly updated, keeping any already up-to-date notes
  Future<void> updateNotes(
    BuildContext context,
    String? filterLabelId,
  ) async {
    // Sets isBackOnline to false so that we don't have duplicate updates
    if (isBackOnline) {
      isBackOnline = false;
    }

    // Variables used to update data
    NoteData? newNoteData;
    TryData tryData;
    bool failed;
    DocumentSnapshot<Map<String, dynamic>>? dataDoc;

    // Attempts to get user data already stored in cache if metadata is empty
    if (noteMeta.isEmpty) {
      await FirebaseFirestore.instance.disableNetwork();

      tryData = await tryQuery(
        () async => await noteDataDocRef().get(),
      );
      failed = tryData.status != 0;
      dataDoc = tryData.returnValue;

      // Update local noteData from cache
      if (!failed && dataDoc!.exists) {
        NoteData newLocalNoteData = NoteData.fromJson(dataDoc.data()!);
        if (newLocalNoteData.ownerId == ownerId) {
          setNoteData(newLocalNoteData);
        }
      }

      await FirebaseFirestore.instance.enableNetwork();
    }

    // When we get back offline, the online status isn't immediately updated so
    // that we don't overwrite the online data. Here we update the status.
    if (isBackOnline) {
      isOnline = true;
    }

    // Attempts to get user data
    tryData = await tryQuery(
      () async => await noteDataDocRef().get(),
    );
    failed = tryData.status != 0;
    dataDoc = tryData.returnValue;

    // If the document doesn't exist, create a new one with the empty NoteData
    if (!failed && !dataDoc!.exists) {
      await noteDataDocRef(forceOnline: true).set(toJson());
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

    // Merges any offline sessions that haven't been merged yet
    if (isOnline) {
      // Gets all of our offline documents
      QuerySnapshot<Map<String, dynamic>> offlineDocs = await FirebaseFirestore
          .instance
          .collection('notes-meta-offline')
          .where('ownerId', isEqualTo: ownerId)
          .get();

      // For each document, merge it with our data
      for (QueryDocumentSnapshot<Map<String, dynamic>> doc
          in offlineDocs.docs) {
        newNoteData.mergeOfflineData(NoteData.fromJson(doc.data()));
        doc.reference.delete();
      }
    }

    // Disable network access so that we can check notes that are cached
    await FirebaseFirestore.instance.disableNetwork();

    // If the user has changed, download all notes before continuing
    bool isSameUser = ownerId == newNoteData.ownerId;
    if (!isSameUser) {
      downloadAllNotes();
    }

    // Stores current note indices in a map for easy checking and accessing
    Map<String, int> noteIndices = {};
    for (int i = 0; i < notes.length; i++) {
      noteIndices[notes[i].id] = i;
    }

    // Adds all note ids that fit the current label or lack of thereof to a list
    List<String> newNoteIds = [];
    for (String noteId in newNoteData.noteMeta.keys) {
      if (filterLabelId == null ||
          newNoteData.noteMeta[noteId]?['labels'].containsKey(filterLabelId)) {
        newNoteIds.add(noteId);
      }
    }

    List<Note> newNotes = [];

    // Attempts to retrieve up-to-date notes that are already on device
    if (isSameUser) {
      for (int i = 0; i < newNoteIds.length; i++) {
        String noteId = newNoteIds[i];
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
              () async => await noteDocRef(noteId).get(),
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
    for (String noteId in newNoteIds) {
      // Attempts to get note document from database
      tryData = await tryQuery(
        () async => await noteDocRef(noteId).get(),
      );
      failed = tryData.status != 0;
      DocumentSnapshot<Map<String, dynamic>>? noteDoc = tryData.returnValue;

      // Removes note that doesn't exist in database
      if (!failed && !noteDoc!.exists) {
        noteMeta.remove(noteId);
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

    // Updates metadata
    setNoteData(newNoteData);

    // Sorts notes according to index
    newNotes.sort(
      (a, b) => a.index.compareTo(b.index),
    );

    // Sets tempIndex, which is used to order notes in the grid
    for (int i = 0; i < newNotes.length; i++) {
      newNotes[i].tempIndex = i;
    }

    // Updates other data
    themeData.updateTheme();
    updateData(resetNums: true);
    notes = newNotes;
  }

  // Transfers all notes from one account (anonymous) to another (Google), upon
  // user's sign in and prompting for transfer options (use cloud function in
  // future so there's no possibility of deleting someone's notes)
  Future<void> transferNotes(
    BuildContext context,
  ) async {
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
        // Push loading screen with deleting text
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => LoadingPage(
              text: Constants.deleteLoading,
            ),
          ),
        );

        // Deletes anonymous user data
        isDeleting = true;
        await deleteUser();

        // Attempts to sign in with the new AuthCredential
        User? newUser;
        try {
          newUser =
              (await FirebaseAuth.instance.signInWithCredential(credential))
                  .user;
          if (newUser == null) {
            signInError(context);
            return;
          }
        } catch (e) {
          signInError(context);
          return;
        }

        // Gets all of the note data for the new user
        setNoteData(
          NoteData(
            ownerId: newUser.uid,
            isAnonymous: newUser.isAnonymous,
            email: newUser.email,
          ),
        );

        await updateNotes(context, null);

        // Go to homepage
        Navigator.of(context).pushAndRemoveUntil<void>(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => HomePage(),
          ),
          (route) => route.isFirst,
        );
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

    // Marks data as transferred and delete account data from database
    isTransferring = true;
    isDeleting = true;
    await deleteUser();

    // Attempts to sign in with the new AuthCredential
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
    String newLabelId;
    for (String labelId in labels.keys) {
      if (newNoteData.labelExists(getLabelName(labelId))) {
        newLabelId = newNoteData.getLabelId(getLabelName(labelId));
      } else {
        newLabelId = newNoteData.newLabel(getLabelName(labelId), update: false);
      }
      labels[labelId]?['newId'] = newLabelId;
    }

    // Transfers notes over, adding them to the new noteData and translating
    // the ids of their labels to the new ones (reversed because each note gets
    // inserted at the beginning)
    Note newNote;
    for (Note note in notes.reversed) {
      newNote = newNoteData.newNote(null, note: note, update: false);
      for (String labelId in note.labelIds) {
        newNote.addLabel(labels[labelId]?['newId'], update: false);
      }
    }

    // Transfers remaining data
    newNoteData.updateData(resetNums: true);
    setNoteData(newNoteData);
    notes = newNoteData.notes;

    // Updates theme
    themeData.updateTheme();

    // Go to homepage
    Navigator.of(context).pushAndRemoveUntil<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => HomePage(),
      ),
      (route) => route.isFirst,
    );
  }

  NoteData({required this.ownerId, this.isAnonymous = true, this.email});

  factory NoteData.fromJson(Map<String, dynamic> json) =>
      _$NoteDataFromJson(json);
  Map<String, dynamic> toJson() => _$NoteDataToJson(this);
}

NoteData noteData = NoteData(ownerId: null);
