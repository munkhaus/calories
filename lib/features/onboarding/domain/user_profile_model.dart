import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile_model.freezed.dart';
part 'user_profile_model.g.dart';

/// Gender enum
enum Gender {
  @JsonValue('male')
  male,
  @JsonValue('female')
  female,
}

/// Goal type enum
enum GoalType {
  @JsonValue('weightLoss')
  weightLoss,
  @JsonValue('weightGain')
  weightGain,
  @JsonValue('muscleGain')
  muscleGain,
  @JsonValue('weightMaintenance')
  weightMaintenance,
}

/// Activity level enum
enum ActivityLevel {
  @JsonValue('sedentary')
  sedentary,
  @JsonValue('lightlyActive')
  lightlyActive,
  @JsonValue('moderatelyActive')
  moderatelyActive,
  @JsonValue('veryActive')
  veryActive,
  @JsonValue('extraActive')
  extraActive,
}

/// User profile model
@freezed
class UserProfileModel with _$UserProfileModel {
  const UserProfileModel._();

  const factory UserProfileModel({
    @Default('') String id,
    @Default('') String email,
    @Default('') String name,
    DateTime? dateOfBirth,
    Gender? gender,
    @Default(0.0) double heightCm,
    @Default(0.0) double currentWeightKg,
    @Default(0.0) double targetWeightKg,
    GoalType? goalType,
    ActivityLevel? activityLevel,
    @Default(0.0) double weeklyGoalKg,
    @Default(0) int targetCalories,
    @Default(0.0) double targetProteinG,
    @Default(0.0) double targetFatG,
    @Default(0.0) double targetCarbsG,
    @Default(false) bool isOnboardingCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _UserProfileModel;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      _$UserProfileModelFromJson(json);

  /// Calculate age from date of birth
  int get age {
    if (dateOfBirth == null) return 0;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  /// Calculate BMI
  double get bmi {
    if (heightCm <= 0 || currentWeightKg <= 0) return 0.0;
    final heightM = heightCm / 100;
    return currentWeightKg / (heightM * heightM);
  }

  /// Get BMI category
  String get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue == 0.0) return 'Ukendt';
    if (bmiValue < 18.5) return 'Undervægt';
    if (bmiValue < 25.0) return 'Normal';
    if (bmiValue < 30.0) return 'Overvægt';
    return 'Fedme';
  }

  /// Calculate BMR (Basal Metabolic Rate) using Mifflin-St Jeor equation
  double get bmr {
    if (!isCompleteForCalculations) return 0.0;
    
    // Calculate BMR using Mifflin-St Jeor equation
    double bmr;
    if (gender == Gender.male) {
      bmr = (10.0 * currentWeightKg) + (6.25 * heightCm) - (5.0 * age) + 5.0;
    } else {
      bmr = (10.0 * currentWeightKg) + (6.25 * heightCm) - (5.0 * age) - 161.0;
    }
    
    return bmr.clamp(800.0, 3000.0); // Safety bounds
  }

  /// Calculate TDEE (Total Daily Energy Expenditure)
  double get tdee {
    if (!isCompleteForCalculations) return 0.0;
    
    final activityMultiplier = switch (activityLevel!) {
      ActivityLevel.sedentary => 1.2,
      ActivityLevel.lightlyActive => 1.375,
      ActivityLevel.moderatelyActive => 1.55,
      ActivityLevel.veryActive => 1.725,
      ActivityLevel.extraActive => 1.9,
    };
    
    return bmr * activityMultiplier;
  }

  /// Check if profile is complete enough for calculations
  bool get isCompleteForCalculations {
    return dateOfBirth != null &&
        gender != null &&
        heightCm > 0 &&
        currentWeightKg > 0 &&
        activityLevel != null &&
        goalType != null;
  }

  /// Get display name or fallback
  String get displayName {
    return name.trim().isEmpty ? 'Bruger' : name.trim();
  }

  /// Check if user has weight goal
  bool get hasWeightGoal {
    return targetWeightKg > 0 && targetWeightKg != currentWeightKg;
  }

  /// Calculate weight difference to goal
  double get weightDifference {
    return targetWeightKg - currentWeightKg;
  }

  /// Check if goal is weight loss
  bool get isWeightLossGoal {
    return goalType == GoalType.weightLoss || weightDifference < 0;
  }

  /// Check if goal is weight gain
  bool get isWeightGainGoal {
    return goalType == GoalType.weightGain || 
           goalType == GoalType.muscleGain || 
           weightDifference > 0;
  }
} 