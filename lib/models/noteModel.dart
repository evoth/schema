import 'package:json_annotation/json_annotation.dart';
import 'package:schema/data/noteData.dart';
part 'noteModel.g.dart';

// Note class (other data about note is stored in NoteData to make things more
// efficient). JsonSerializable so that we can go to and from Firebase
@JsonSerializable()
class Note {
  int id;
  String title;
  String text;
  String? ownerId;
  bool isDeleted;
  @JsonKey(ignore: true)
  int tempIndex = -1;
  @JsonKey(ignore: true)
  bool drag;
  @JsonKey(ignore: true)
  double dragX = 0;
  @JsonKey(ignore: true)
  double dragY = 0;
  @JsonKey(ignore: true)
  bool isNew;
  @JsonKey(ignore: true)
  String? previousTitle;
  @JsonKey(ignore: true)
  String? previousText;

  // Gets index from NoteData
  int index() {
    return noteData.noteMeta[id]?['index'];
  }

  // Sets index in NoteData
  void setIndex(index) {
    noteData.noteMeta[id]?['index'] = index;
  }

  // Gets list of label ids
  List<int> getLabels() {
    List<int> labelIds = noteData.noteMeta[id]?['labels'].keys
        .map<int>((labelId) => int.parse(labelId))
        .toList();
    return labelIds
        .where((int labelId) => !noteData.labels[labelId]?['isDeleted'])
        .toList();
  }

  // Returns whether the given label is possesed by the note
  bool hasLabel(int labelId) {
    return noteData.noteMeta[id]?['labels'].containsKey(labelId.toString()) &&
        !noteData.labels[labelId]?['isDeleted'];
  }

  Note(
    this.id,
    this.title,
    this.text, {
    required this.ownerId,
    this.drag = false,
    this.isDeleted = false,
    this.isNew = false,
  });

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
  Map<String, dynamic> toJson() => _$NoteToJson(this);
}
