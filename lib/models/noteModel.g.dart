// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'noteModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Note _$NoteFromJson(Map<String, dynamic> json) => Note(
      json['id'] as int,
      json['title'] as String,
      json['text'] as String,
      ownerId: json['ownerId'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );

Map<String, dynamic> _$NoteToJson(Note instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'text': instance.text,
      'ownerId': instance.ownerId,
      'isDeleted': instance.isDeleted,
    };
