// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
  id: json['id'] as String,
  metricUnits: json['metricUnits'] as bool,
  ageYears: (json['ageYears'] as num).toInt(),
  sex: $enumDecode(_$SexEnumMap, json['sex']),
  heightCm: (json['heightCm'] as num).toDouble(),
  weightKg: (json['weightKg'] as num).toDouble(),
  activityLevel: $enumDecode(_$ActivityLevelEnumMap, json['activityLevel']),
);

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'metricUnits': instance.metricUnits,
      'ageYears': instance.ageYears,
      'sex': _$SexEnumMap[instance.sex]!,
      'heightCm': instance.heightCm,
      'weightKg': instance.weightKg,
      'activityLevel': _$ActivityLevelEnumMap[instance.activityLevel]!,
    };

const _$SexEnumMap = {
  Sex.male: 'male',
  Sex.female: 'female',
};

const _$ActivityLevelEnumMap = {
  ActivityLevel.sedentary: 'sedentary',
  ActivityLevel.light: 'light',
  ActivityLevel.moderate: 'moderate',
  ActivityLevel.active: 'active',
  ActivityLevel.veryActive: 'veryActive',
};
