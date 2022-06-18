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
  // Stores which NoteData this note belongs to
  @JsonKey(ignore: true)
  NoteData data = noteData;

  // Gets index from NoteData depending on whether filtering (only tempIndex is
  // used when filtering)
  int indexFilterBased(bool filter) {
    // If filtering by a label, return tempIndex, which is used when filtering
    if (filter) {
      return tempIndex;
    }
    // Otherwise, return index from metadata
    return index;
  }

  // Index of note represented in metadata so that note document does not need
  // to be updated when only move notes (same idea for other properties).
  int get index {
    return data.noteMeta[id]?['index'] ?? -1;
  }

  set index(int index) {
    data.noteMeta[id]?['index'] = index;
  }

  // Whether the note has pending writes, meaning it has been edited offline
  @JsonKey(ignore: true)
  bool get hasOfflineChanges {
    return data.noteMeta[id]?['hasOfflineChanges'] ?? false;
  }

  set hasOfflineChanges(bool hasOfflineChanges) {
    data.noteMeta[id]?['hasOfflineChanges'] = hasOfflineChanges;
  }

  // When the note has last been updated (content or labels)
  @JsonKey(ignore: true)
  Timestamp get timeUpdated {
    return data.noteMeta[id]?['timeUpdated'] ?? false;
  }

  set timeUpdated(Timestamp timeUpdated) {
    data.noteMeta[id]?['timeUpdated'] = timeUpdated;
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
  bool hasLabel(NoteData data, int labelId) {
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
    data.noteMeta[id]?['timeUpdated'] = Timestamp.now();
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

  Note(
    this.id,
    this.title,
    this.text, {
    required this.ownerId,
    this.drag = false,
    this.isNew = false,
    bool hasOfflineChanges = false,
  }) {
    this.hasOfflineChanges = hasOfflineChanges;
  }

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
  Map<String, dynamic> toJson() => _$NoteToJson(this);
}
