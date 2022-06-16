import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:schema/data/noteData.dart';
part 'noteModel.g.dart';

// Note class (other data about note is stored in NoteData to make things more
// efficient). JsonSerializable so that we can go to and from Firebase
@JsonSerializable()
class Note {
  // Basic note properties
  int id;
  String title;
  String text;
  String? ownerId;
  // Used to keep track of which NoteData this note belongs to
  @JsonKey(ignore: true)
  NoteData data;
  // Used for rearranging notes on home page
  @JsonKey(ignore: true)
  int tempIndex = -1;
  @JsonKey(ignore: true)
  bool drag;
  @JsonKey(ignore: true)
  double dragX = 0;
  @JsonKey(ignore: true)
  double dragY = 0;
  // Whether the note has just been created (false after first edit)
  @JsonKey(ignore: true)
  bool isNew;
  // Variables to store the current edit state of the note
  @JsonKey(ignore: true)
  String? previousTitle;
  @JsonKey(ignore: true)
  String? previousText;
  // (ValueNotifier used to update app bar in edit page)
  @JsonKey(ignore: true)
  ValueNotifier<bool> isSavedNotifier = ValueNotifier(true);
  @JsonKey(ignore: true)
  int editTicker = 0;

  // Gets and sets index in NoteData
  @JsonKey(ignore: true)
  int get index {
    return data.noteMeta[id]?['index'] ?? -1;
  }

  set index(int index) {
    data.noteMeta[id]?['index'] = index;
  }

  // Gets and sets timeUpdated in NoteData
  @JsonKey(ignore: true)
  Timestamp get timeUpdated {
    return data.noteMeta[id]?['timeUpdated'] ?? Timestamp.now();
  }

  set timeUpdated(Timestamp timeUpdated) {
    data.noteMeta[id]?['timeUpdated'] = timeUpdated;
  }

  // Gets and sets timeCreated in NoteData
  @JsonKey(ignore: true)
  Timestamp get timeCreated {
    return data.noteMeta[id]?['timeCreated'] ?? Timestamp.now();
  }

  set timeCreated(Timestamp timeCreated) {
    data.noteMeta[id]?['timeCreated'] = timeCreated;
  }

  // Gets and sets hasOfflineChanges in NoteData
  @JsonKey(ignore: true)
  bool get hasOfflineChanges {
    return data.noteMeta[id]?['hasOfflineChanges'] ?? false;
  }

  set hasOfflineChanges(bool hasOfflineChanges) {
    data.noteMeta[id]?['hasOfflineChanges'] = hasOfflineChanges;
  }

  // Gets index of note dependent on whether we are filtering
  int getFilterIndex(bool filter) {
    return filter ? tempIndex : index;
  }

  // Gets list of label ids
  @JsonKey(ignore: true)
  List<int> get labelIds {
    List<int> labelIds = data.noteMeta[id]?['labels'].keys
            .map<int>((labelId) => int.parse(labelId))
            .toList() ??
        [];
    // Excludes and removes deleted labels in case of desync
    for (int i = 0; i < labelIds.length; i++) {
      if (!data.labels.containsKey(labelIds[i])) {
        data.noteMeta[id]?['labels'].remove(labelIds[i].toString());
        labelIds.removeAt(i);
        i--;
      }
    }
    // Sorts labels alphabetically
    labelIds.sort(
      (a, b) => data.labels[a]?['name'].compareTo(data.labels[b]?['name']),
    );
    return labelIds;
  }

  // Returns whether the given label is possessed by the note
  bool hasLabel(int labelId) {
    return data.noteMeta[id]?['labels'].containsKey(labelId.toString()) ??
        false;
  }

  // Adds a label to a note (we use a map instead of a list for access speed)
  void addLabel(int labelId, {bool update = true}) {
    // Mark note as unsaved
    isSavedNotifier.value = false;
    // Convert label id to string because of strange error
    data.noteMeta[id]?['labels'][labelId.toString()] = true;
    data.labels[labelId]?['numNotes']++;
    timeUpdated = Timestamp.now();
    hasOfflineChanges = !data.isOnline;
    if (update) {
      data.updateData();
    }
    // Mark note as saved if other content is already saved
    isSavedNotifier.value = editTicker == 0;
  }

  // Removes a label from a note
  void removeLabel(int labelId) {
    // Mark note as unsaved
    isSavedNotifier.value = false;
    data.noteMeta[id]?['labels'].remove(labelId.toString());
    data.labels[labelId]?['numNotes']--;
    timeUpdated = Timestamp.now();
    hasOfflineChanges = !data.isOnline;
    data.updateData();
    // Mark note as saved if other content is already saved
    isSavedNotifier.value = editTicker == 0;
  }

  // Initializes respective fields in both Note and NoteData
  Note(
    this.id,
    this.title,
    this.text, {
    required this.ownerId,
    int? index,
    NoteData? data,
    this.drag = false,
    this.isNew = false,
    bool hasOfflineChanges = false,
    Timestamp? timeCreated,
    Timestamp? timeUpdated,
  }) : data = data ?? noteData {
    if (!this.data.noteMeta.containsKey(id)) {
      this.data.noteMeta[id] = {};
    }
    Timestamp timeNow = Timestamp.now();
    this.timeCreated = timeCreated ?? timeNow;
    this.timeUpdated = timeUpdated ?? timeNow;
    if (index != null) {
      this.index = index;
    }
    this.hasOfflineChanges = hasOfflineChanges;
    this.tempIndex = this.index;
    this.data.noteMeta[id]?['labels'] = {};
  }

  // Converts json to Note and sets data field manually
  factory Note.fromJson(Map<String, dynamic> json, NoteData data) {
    Note newNote = _$NoteFromJson(json);
    newNote.data = data;
    return newNote;
  }
  Map<String, dynamic> toJson() => _$NoteToJson(this);
}
