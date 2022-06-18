// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'noteData.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NoteData _$NoteDataFromJson(Map<String, dynamic> json) => NoteData(
      ownerId: json['ownerId'] as String?,
      isAnonymous: json['isAnonymous'] as bool? ?? true,
      email: json['email'] as String?,
    )
      ..numNotes = json['numNotes'] as int
      ..labels = (json['labels'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(int.parse(k), e as Map<String, dynamic>),
      )
      ..noteMeta = (json['noteMeta'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(int.parse(k), e as Map<String, dynamic>),
      )
      ..timeRegistered = NoteData._rawTimeStamp(json['timeRegistered'])
      ..themeColorId = json['themeColorId'] as int
      ..themeIsDark = json['themeIsDark'] as bool
      ..themeIsMonochrome = json['themeIsMonochrome'] as bool
      ..timeOffline = NoteData._rawTimeStamp(json['timeOffline']);

Map<String, dynamic> _$NoteDataToJson(NoteData instance) => <String, dynamic>{
      'numNotes': instance.numNotes,
      'labels': instance.labels.map((k, e) => MapEntry(k.toString(), e)),
      'noteMeta': instance.noteMeta.map((k, e) => MapEntry(k.toString(), e)),
      'timeRegistered': NoteData._rawTimeStamp(instance.timeRegistered),
      'ownerId': instance.ownerId,
      'isAnonymous': instance.isAnonymous,
      'email': instance.email,
      'themeColorId': instance.themeColorId,
      'themeIsDark': instance.themeIsDark,
      'themeIsMonochrome': instance.themeIsMonochrome,
      'timeOffline': NoteData._rawTimeStamp(instance.timeOffline),
    };
