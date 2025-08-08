import 'package:json_annotation/json_annotation.dart';
import 'enums.dart';

part 'user_profile.g.dart';

@JsonSerializable()
class UserProfile {
  const UserProfile({
    required this.id,
    required this.metricUnits,
    required this.ageYears,
    required this.sex,
    required this.heightCm,
    required this.weightKg,
    required this.activityLevel,
  });

  final String id;
  final bool metricUnits; // true: metric, false: imperial
  final int ageYears;
  final Sex sex;
  final double heightCm;
  final double weightKg;
  final ActivityLevel activityLevel;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
}
