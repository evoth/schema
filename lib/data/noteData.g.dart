// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'noteData.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NoteData _$NoteDataFromJson(Map<String, dynamic> json) => NoteData(
      ownerId: json['ownerId'] as String?,
      isAnonymous: json['isAnonymous'] as bool? ?? true,
    )
      ..numNotes = json['numNotes'] as int
      ..labels = (json['labels'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, e as Map<String, dynamic>),
      )
      ..noteMeta = (json['noteMeta'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, e as Map<String, dynamic>),
      )
      ..timeRegistered = NoteData._rawTimeStamp(json['timeRegistered'])
      ..themeColorId = json['themeColorId'] as int
      ..themeIsDark = json['themeIsDark'] as bool
      ..themeIsMonochrome = json['themeIsMonochrome'] as bool
      ..themeTimeUpdated = NoteData._rawTimeStamp(json['themeTimeUpdated'])
      ..layoutDimensionId = json['layoutDimensionId'] as int
      ..layoutTimeUpdated = NoteData._rawTimeStamp(json['layoutTimeUpdated'])
      ..timeOffline = NoteData._rawTimeStamp(json['timeOffline'])
      ..isOnline = json['isOnline'] as bool
      ..timeUpdated = NoteData._rawTimeStamp(json['timeUpdated']);

Map<String, dynamic> _$NoteDataToJson(NoteData instance) => <String, dynamic>{
      'numNotes': instance.numNotes,
      'labels': instance.labels,
      'noteMeta': instance.noteMeta,
      'timeRegistered': NoteData._rawTimeStamp(instance.timeRegistered),
      'ownerId': instance.ownerId,
      'isAnonymous': instance.isAnonymous,
      'themeColorId': instance.themeColorId,
      'themeIsDark': instance.themeIsDark,
      'themeIsMonochrome': instance.themeIsMonochrome,
      'themeTimeUpdated': NoteData._rawTimeStamp(instance.themeTimeUpdated),
      'layoutDimensionId': instance.layoutDimensionId,
      'layoutTimeUpdated': NoteData._rawTimeStamp(instance.layoutTimeUpdated),
      'timeOffline': NoteData._rawTimeStamp(instance.timeOffline),
      'isOnline': instance.isOnline,
      'timeUpdated': NoteData._rawTimeStamp(instance.timeUpdated),
    };
