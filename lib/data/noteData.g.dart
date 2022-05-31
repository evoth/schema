// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'noteData.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NoteData _$NoteDataFromJson(Map<String, dynamic> json) => NoteData()
  ..idCounter = json['idCounter'] as int
  ..noteMeta = (json['noteMeta'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(int.parse(k), e as Map<String, dynamic>),
  )
  ..timeRegistered = DateTime.parse(json['timeRegistered'] as String);

Map<String, dynamic> _$NoteDataToJson(NoteData instance) => <String, dynamic>{
      'idCounter': instance.idCounter,
      'noteMeta': instance.noteMeta.map((k, e) => MapEntry(k.toString(), e)),
      'timeRegistered': instance.timeRegistered.toIso8601String(),
    };
