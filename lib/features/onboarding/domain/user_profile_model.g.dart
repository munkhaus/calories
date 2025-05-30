// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileModelImpl _$$UserProfileModelImplFromJson(
  Map<String, dynamic> json,
) => _$UserProfileModelImpl(
  id: json['id'] as String? ?? '',
  email: json['email'] as String? ?? '',
  name: json['name'] as String? ?? '',
  dateOfBirth: json['dateOfBirth'] == null
      ? null
      : DateTime.parse(json['dateOfBirth'] as String),
  gender: $enumDecodeNullable(_$GenderEnumMap, json['gender']),
  heightCm: (json['heightCm'] as num?)?.toDouble() ?? 0.0,
  currentWeightKg: (json['currentWeightKg'] as num?)?.toDouble() ?? 0.0,
  targetWeightKg: (json['targetWeightKg'] as num?)?.toDouble() ?? 0.0,
  goalType: $enumDecodeNullable(_$GoalTypeEnumMap, json['goalType']),
  workActivityLevel: $enumDecodeNullable(
    _$WorkActivityLevelEnumMap,
    json['workActivityLevel'],
  ),
  leisureActivityLevel: $enumDecodeNullable(
    _$LeisureActivityLevelEnumMap,
    json['leisureActivityLevel'],
  ),
  activityTrackingPreference:
      $enumDecodeNullable(
        _$ActivityTrackingPreferenceEnumMap,
        json['activityTrackingPreference'],
      ) ??
      ActivityTrackingPreference.automatic,
  useAutomaticWeekdayDetection:
      json['useAutomaticWeekdayDetection'] as bool? ?? true,
  isCurrentlyWorkDay: json['isCurrentlyWorkDay'] as bool? ?? false,
  isLeisureActivityEnabledToday:
      json['isLeisureActivityEnabledToday'] as bool? ?? true,
  activityLevel: $enumDecodeNullable(
    _$ActivityLevelEnumMap,
    json['activityLevel'],
  ),
  weeklyGoalKg: (json['weeklyGoalKg'] as num?)?.toDouble() ?? 0.0,
  targetCalories: (json['targetCalories'] as num?)?.toInt() ?? 0,
  targetProteinG: (json['targetProteinG'] as num?)?.toDouble() ?? 0.0,
  targetFatG: (json['targetFatG'] as num?)?.toDouble() ?? 0.0,
  targetCarbsG: (json['targetCarbsG'] as num?)?.toDouble() ?? 0.0,
  isOnboardingCompleted: json['isOnboardingCompleted'] as bool? ?? false,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$UserProfileModelImplToJson(
  _$UserProfileModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'name': instance.name,
  'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
  'gender': _$GenderEnumMap[instance.gender],
  'heightCm': instance.heightCm,
  'currentWeightKg': instance.currentWeightKg,
  'targetWeightKg': instance.targetWeightKg,
  'goalType': _$GoalTypeEnumMap[instance.goalType],
  'workActivityLevel': _$WorkActivityLevelEnumMap[instance.workActivityLevel],
  'leisureActivityLevel':
      _$LeisureActivityLevelEnumMap[instance.leisureActivityLevel],
  'activityTrackingPreference':
      _$ActivityTrackingPreferenceEnumMap[instance.activityTrackingPreference]!,
  'useAutomaticWeekdayDetection': instance.useAutomaticWeekdayDetection,
  'isCurrentlyWorkDay': instance.isCurrentlyWorkDay,
  'isLeisureActivityEnabledToday': instance.isLeisureActivityEnabledToday,
  'activityLevel': _$ActivityLevelEnumMap[instance.activityLevel],
  'weeklyGoalKg': instance.weeklyGoalKg,
  'targetCalories': instance.targetCalories,
  'targetProteinG': instance.targetProteinG,
  'targetFatG': instance.targetFatG,
  'targetCarbsG': instance.targetCarbsG,
  'isOnboardingCompleted': instance.isOnboardingCompleted,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

const _$GenderEnumMap = {Gender.male: 'male', Gender.female: 'female'};

const _$GoalTypeEnumMap = {
  GoalType.weightLoss: 'weightLoss',
  GoalType.weightGain: 'weightGain',
  GoalType.muscleGain: 'muscleGain',
  GoalType.weightMaintenance: 'weightMaintenance',
};

const _$WorkActivityLevelEnumMap = {
  WorkActivityLevel.sedentary: 'sedentary',
  WorkActivityLevel.light: 'light',
  WorkActivityLevel.moderate: 'moderate',
  WorkActivityLevel.heavy: 'heavy',
  WorkActivityLevel.veryHeavy: 'veryHeavy',
};

const _$LeisureActivityLevelEnumMap = {
  LeisureActivityLevel.sedentary: 'sedentary',
  LeisureActivityLevel.lightlyActive: 'lightlyActive',
  LeisureActivityLevel.moderatelyActive: 'moderatelyActive',
  LeisureActivityLevel.veryActive: 'veryActive',
  LeisureActivityLevel.extraActive: 'extraActive',
};

const _$ActivityTrackingPreferenceEnumMap = {
  ActivityTrackingPreference.automatic: 'automatic',
  ActivityTrackingPreference.manual: 'manual',
  ActivityTrackingPreference.hybrid: 'hybrid',
};

const _$ActivityLevelEnumMap = {
  ActivityLevel.sedentary: 'sedentary',
  ActivityLevel.lightlyActive: 'lightlyActive',
  ActivityLevel.moderatelyActive: 'moderatelyActive',
  ActivityLevel.veryActive: 'veryActive',
  ActivityLevel.extraActive: 'extraActive',
};
