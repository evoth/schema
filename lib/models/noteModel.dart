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
  // Whether the note has pending writes, meaning it has been edited offline
  @JsonKey(ignore: true)
  bool hasOfflineChanges;

  // Gets index from NoteData
  int index(NoteData data, {bool filter = false}) {
    // If filtering by a label, return tempIndex, which is used when filtering
    if (filter) {
      return tempIndex;
    }
    // Otherwise, return index from metadata
    return data.noteMeta[id]?['index'];
  }

  // Sets index in NoteData
  void setIndex(NoteData data, index) {
    data.noteMeta[id]?['index'] = index;
  }

  // Gets list of label ids
  List<int> getLabels(NoteData data) {
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

  // Returns whether the given label is possesed by the note
  bool hasLabel(NoteData data, int labelId) {
    return data.noteMeta[id]?['labels'].containsKey(labelId.toString()) ??
        false;
  }

  Note(
    this.id,
    this.title,
    this.text, {
    required this.ownerId,
    this.drag = false,
    this.isNew = false,
    this.hasOfflineChanges = false,
  });

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
  Map<String, dynamic> toJson() => _$NoteToJson(this);
}
