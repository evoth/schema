// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'noteData.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NoteData _$NoteDataFromJson(Map<String, dynamic> json) => NoteData(
      ownerId: json['ownerId'] as String?,
    )
      ..noteIdCounter = json['noteIdCounter'] as int
      ..labelIdCounter = json['labelIdCounter'] as int
      ..numNotes = json['numNotes'] as int
      ..labels = (json['labels'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(int.parse(k), e as Map<String, dynamic>),
      )
      ..noteMeta = (json['noteMeta'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(int.parse(k), e as Map<String, dynamic>),
      )
      ..timeRegistered = NoteData._rawTimeStamp(json['timeRegistered'])
      ..isAnonymous = json['isAnonymous'] as bool
      ..email = json['email'] as String?;

Map<String, dynamic> _$NoteDataToJson(NoteData instance) => <String, dynamic>{
      'noteIdCounter': instance.noteIdCounter,
      'labelIdCounter': instance.labelIdCounter,
      'numNotes': instance.numNotes,
      'labels': instance.labels.map((k, e) => MapEntry(k.toString(), e)),
      'noteMeta': instance.noteMeta.map((k, e) => MapEntry(k.toString(), e)),
      'timeRegistered': NoteData._rawTimeStamp(instance.timeRegistered),
      'ownerId': instance.ownerId,
      'isAnonymous': instance.isAnonymous,
      'email': instance.email,
    };
