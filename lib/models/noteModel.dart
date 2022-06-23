import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:schema/data/noteData.dart';
import 'package:schema/functions/general.dart';
part 'noteModel.g.dart';

// Note class (other data about note is stored in NoteData to make things more
// efficient). JsonSerializable so that we can go to and from Firebase
@JsonSerializable()
class Note {
  // Basic note properties
  String id;
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
  @JsonKey(ignore: true)
  int get index {
    return data.noteMeta[id]?['index'] ?? -1;
  }

  set index(int index) {
    data.noteMeta[id]?['index'] = index;
  }

  // Whether the note has pending writes, meaning it has been edited offline
  @JsonKey(ignore: true)
  bool get hasOfflineChanges {
    return !data.isOnline && timeUpdated.compareTo(data.timeOffline) > 0;
  }

  // When the note has last been updated (content or labels)
  @JsonKey(ignore: true)
  Timestamp get timeUpdated {
    return data.noteMeta[id]?['timeUpdated'] ?? timestampNowRounded();
  }

  set timeUpdated(Timestamp timeUpdated) {
    data.noteMeta[id]?['timeUpdated'] = timeUpdated;
  }

  // Gets list of label ids
  @JsonKey(ignore: true)
  List<String> get labelIds {
    List<String> labelIds = data.noteMeta[id]?['labels'].keys
            .map<String>((labelId) => labelId.toString())
            .toList() ??
        [];
    // Excludes and removes deleted labels in case of desync
    for (int i = 0; i < labelIds.length; i++) {
      if (!data.labels.containsKey(labelIds[i])) {
        data.noteMeta[id]?['labels'].remove(labelIds[i]);
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
  bool hasLabel(String labelId) {
    return data.noteMeta[id]?['labels'].containsKey(labelId) ?? false;
  }

  // Adds a label to a note (we use a map instead of a list for access speed)
  void addLabel(String labelId, {bool update = true}) {
    // Mark note as unsaved
    isSavedNotifier.value = false;
    // Add label and update data
    data.noteMeta[id]?['labels'][labelId] = true;
    data.labels[labelId]?['numNotes']++;
    data.labels[labelId]?['timeUpdated'] = timestampNowRounded();
    timeUpdated = timestampNowRounded();
    // Updates this note if we are offline, so that a new note document will be
    // created in the case that the note was deleted online and the only change
    // we made offline was to add/remove a label
    if (!data.isOnline) {
      data.updateNote(this, update: false);
    }
    // Updates noteData so that other devices will update
    if (update) {
      data.updateData();
    }
    // Mark note as saved if other content is already saved
    isSavedNotifier.value = editTicker == 0;
  }

  // Removes a label from a note
  void removeLabel(String labelId) {
    // Mark note as unsaved
    isSavedNotifier.value = false;
    // Remove label and update data
    data.noteMeta[id]?['labels'].remove(labelId);
    data.labels[labelId]?['numNotes']--;
    timeUpdated = timestampNowRounded();
    // See note in addLabel()
    if (!data.isOnline) {
      data.updateNote(this, update: false);
    }
    // Updates noteData so that other devices will update
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
  });

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
  Map<String, dynamic> toJson() => _$NoteToJson(this);
}
