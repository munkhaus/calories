// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Goal _$GoalFromJson(Map<String, dynamic> json) => Goal(
  id: json['id'] as String,
  startDate: DateTime.parse(json['startDate'] as String),
  mode: $enumDecode(_$GoalModeEnumMap, json['mode']),
  targetCalories: (json['targetCalories'] as num).toInt(),
  carbPercent: (json['carbPercent'] as num?)?.toInt() ?? 40,
  proteinPercent: (json['proteinPercent'] as num?)?.toInt() ?? 30,
  fatPercent: (json['fatPercent'] as num?)?.toInt() ?? 30,
  paceKcalPerDay: (json['paceKcalPerDay'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$GoalToJson(Goal instance) => <String, dynamic>{
  'id': instance.id,
  'startDate': instance.startDate.toIso8601String(),
  'mode': _$GoalModeEnumMap[instance.mode]!,
  'targetCalories': instance.targetCalories,
  'carbPercent': instance.carbPercent,
  'proteinPercent': instance.proteinPercent,
  'fatPercent': instance.fatPercent,
  'paceKcalPerDay': instance.paceKcalPerDay,
};

const _$GoalModeEnumMap = {
  GoalMode.lose: 'lose',
  GoalMode.maintain: 'maintain',
  GoalMode.gain: 'gain',
};
