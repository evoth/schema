import 'package:json_annotation/json_annotation.dart';
import 'package:schema/data/noteData.dart';
part 'noteModel.g.dart';

// TODO: add comments
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

  int index() {
    return noteData.noteMeta[id]?['index'];
  }

  void setIndex(index) {
    noteData.noteMeta[id]?['index'] = index;
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
