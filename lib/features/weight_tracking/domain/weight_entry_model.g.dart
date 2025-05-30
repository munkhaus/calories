// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_entry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WeightEntryModelImpl _$$WeightEntryModelImplFromJson(
  Map<String, dynamic> json,
) => _$WeightEntryModelImpl(
  entryId: (json['entryId'] as num?)?.toInt() ?? 0,
  userId: (json['userId'] as num?)?.toInt() ?? 0,
  weightKg: (json['weightKg'] as num?)?.toDouble() ?? 0.0,
  recordedAt: DateTime.parse(json['recordedAt'] as String),
  notes: json['notes'] as String? ?? '',
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$WeightEntryModelImplToJson(
  _$WeightEntryModelImpl instance,
) => <String, dynamic>{
  'entryId': instance.entryId,
  'userId': instance.userId,
  'weightKg': instance.weightKg,
  'recordedAt': instance.recordedAt.toIso8601String(),
  'notes': instance.notes,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
