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

/// Work activity level enum - represents physical intensity of job
enum WorkActivityLevel {
  @JsonValue('sedentary')
  sedentary, // Desk job, office work
  @JsonValue('light')
  light, // Standing, light walking
  @JsonValue('moderate') 
  moderate, // Walking, lifting, some physical work
  @JsonValue('heavy')
  heavy, // Construction, manual labor, physical demanding job
  @JsonValue('veryHeavy')
  veryHeavy, // Heavy construction, farming, very demanding physical work
}

/// Leisure activity level enum - represents exercise/sports activity outside of work
enum LeisureActivityLevel {
  @JsonValue('sedentary')
  sedentary, // No regular exercise
  @JsonValue('lightlyActive')
  lightlyActive, // 1-3 days exercise per week
  @JsonValue('moderatelyActive')
  moderatelyActive, // 3-5 days exercise per week
  @JsonValue('veryActive')
  veryActive, // 6-7 days exercise per week
  @JsonValue('extraActive')
  extraActive, // Daily intense exercise
}

/// Activity tracking preference enum
enum ActivityTrackingPreference {
  @JsonValue('automatic')
  automatic, // Use automatic calculation based on work/leisure levels
  @JsonValue('manual')
  manual, // User will manually log all activities
  @JsonValue('hybrid')
  hybrid, // Automatic base + manual additional activities
}

/// Activity level enum (kept for backwards compatibility)
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
    
    // New activity system
    WorkActivityLevel? workActivityLevel,
    LeisureActivityLevel? leisureActivityLevel,
    @Default(ActivityTrackingPreference.automatic) ActivityTrackingPreference activityTrackingPreference,
    @Default(true) bool useAutomaticWeekdayDetection,
    @Default(false) bool isCurrentlyWorkDay, // Manual override for today
    @Default(true) bool isLeisureActivityEnabledToday, // Manual toggle for leisure activity today
    
    // Legacy activity level (for backwards compatibility)
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
    return age < 0 ? 0 : age; // Ensure age is not negative
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
    // BMR requires age, gender, weight, and height. Age must be positive.
    if (dateOfBirth == null || gender == null || heightCm <= 0 || currentWeightKg <= 0 || age <= 0) return 0.0;
    
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
    
    // Use new activity system if available, otherwise fall back to legacy
    if (workActivityLevel != null && leisureActivityLevel != null) {
      return _calculateTdeeWithNewSystem();
    }
    
    // Legacy calculation
    if (activityLevel == null) return bmr * 1.2; // Default to sedentary if no level set
    
    final activityMultiplier = switch (activityLevel!) {
      ActivityLevel.sedentary => 1.2,
      ActivityLevel.lightlyActive => 1.375,
      ActivityLevel.moderatelyActive => 1.55,
      ActivityLevel.veryActive => 1.725,
      ActivityLevel.extraActive => 1.9,
    };
    
    return bmr * activityMultiplier;
  }

  /// Calculate TDEE using the new work/leisure activity system
  double _calculateTdeeWithNewSystem() {
    final workFactor = _getWorkActivityFactor();
    final leisureFactor = _getLeisureActivityFactor();
    final isWorkDay = _getIsWorkDay();
    
    // On work days: use work factor, on non-work days: use sedentary work factor
    final effectiveWorkFactor = isWorkDay ? workFactor : 1.2; // 1.2 = sedentary baseline for non-work days
    
    // CORRECTED LOGIC: For manual tracking, leisure activity is ALWAYS 0
    // For automatic tracking, it depends on isLeisureActivityEnabledToday
    final effectiveLeisureFactor = (activityTrackingPreference == ActivityTrackingPreference.manual)
        ? 0.0 // Manual tracking: no automatic leisure activity
        : (isLeisureActivityEnabledToday ? (leisureFactor - 1.0) : 0.0); // Automatic tracking: depends on toggle
    
    final totalFactor = effectiveWorkFactor + effectiveLeisureFactor;
    final result = bmr * totalFactor.clamp(1.0, 2.5);
    
    // Debug logging to verify the fix
    print('🔢 TDEE Calculation:');
    print('🔢 - BMR: ${bmr.toStringAsFixed(0)} kcal');
    print('🔢 - Activity tracking: ${activityTrackingPreference.toString().split('.').last}');
    print('🔢 - Is work day: $isWorkDay');
    print('🔢 - Work factor: ${effectiveWorkFactor.toStringAsFixed(2)}');
    print('🔢 - Leisure enabled today: $isLeisureActivityEnabledToday');
    print('🔢 - Leisure factor (raw): ${leisureFactor.toStringAsFixed(2)}');
    print('🔢 - Leisure factor (effective): ${effectiveLeisureFactor.toStringAsFixed(2)}');
    print('🔢 - Total factor: ${totalFactor.toStringAsFixed(2)}');
    print('🔢 - Final TDEE: ${result.toStringAsFixed(0)} kcal');
    
    return result;
  }

  /// Get work activity multiplier factor
  double _getWorkActivityFactor() {
    switch (workActivityLevel!) {
      case WorkActivityLevel.sedentary:
        return 1.2; // Office work
      case WorkActivityLevel.light:
        return 1.35; // Standing, light walking
      case WorkActivityLevel.moderate:
        return 1.5; // Walking, some lifting
      case WorkActivityLevel.heavy:
        return 1.7; // Construction, manual labor
      case WorkActivityLevel.veryHeavy:
        return 1.9; // Heavy construction, farming
    }
  }

  /// Get leisure activity multiplier factor
  double _getLeisureActivityFactor() {
    switch (leisureActivityLevel!) {
      case LeisureActivityLevel.sedentary:
        return 1.0; // No additional activity
      case LeisureActivityLevel.lightlyActive:
        return 1.1; // 1-3 days exercise
      case LeisureActivityLevel.moderatelyActive:
        return 1.2; // 3-5 days exercise
      case LeisureActivityLevel.veryActive:
        return 1.3; // 6-7 days exercise
      case LeisureActivityLevel.extraActive:
        return 1.4; // Daily intense exercise
    }
  }

  /// Determine if today is a work day
  bool _getIsWorkDay() {
    if (!useAutomaticWeekdayDetection) {
      return isCurrentlyWorkDay;
    }
    
    // Automatic detection: Monday-Friday are work days
    final today = DateTime.now();
    final weekday = today.weekday; // 1 = Monday, 7 = Sunday
    return weekday >= 1 && weekday <= 5; // Monday to Friday
  }

  /// Check if profile is complete enough for calculations
  bool get isCompleteForCalculations {
    // Basic fields needed for BMR and target calories calculation.
    // Activity level presence is handled by TDEE getter's own logic.
    return dateOfBirth != null &&
        gender != null &&
        heightCm > 0 &&
        currentWeightKg > 0 &&
        goalType != null &&
        targetWeightKg > 0 && // Added as it's used in target calcs often indirectly via goal
        isOnboardingCompleted; // Ensures user has gone through the flow
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