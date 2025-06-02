import 'package:shared_preferences/shared_preferences.dart';
import 'activity_calorie_data.dart';

/// Service for calculating activity calories using MET values
class ActivityCalorieCalculator {
  static const String _userWeightKey = 'user_weight';
  static const double _defaultWeightKg = 70.0; // Default weight if not set

  /// Calculate calories for time-based activity
  static Future<int> calculateTimeBasedCalories({
    required ActivityCategory category,
    required ActivityIntensityLevel intensity,
    required double durationMinutes,
    double? userWeightKg,
  }) async {
    final weightKg = userWeightKg ?? await getUserWeight();
    
    return ActivityCalorieDatabase.calculateCalories(
      category: category,
      intensity: intensity,
      weightKg: weightKg,
      durationMinutes: durationMinutes,
    );
  }

  /// Calculate calories for distance-based activity
  static Future<int> calculateDistanceBasedCalories({
    required ActivityCategory category,
    required ActivityIntensityLevel intensity,
    required double distanceKm,
    double? userWeightKg,
    double? averageSpeedKmh,
  }) async {
    final weightKg = userWeightKg ?? await getUserWeight();
    
    return ActivityCalorieDatabase.calculateCaloriesFromDistance(
      category: category,
      intensity: intensity,
      weightKg: weightKg,
      distanceKm: distanceKm,
      averageSpeedKmh: averageSpeedKmh,
    );
  }

  /// Calculate estimated duration from distance (useful for UI feedback)
  static double calculateEstimatedDuration({
    required ActivityCategory category,
    required ActivityIntensityLevel intensity,
    required double distanceKm,
    double? averageSpeedKmh,
  }) {
    // Use provided speed or default speed from database
    double speedKmh;
    if (averageSpeedKmh != null) {
      speedKmh = averageSpeedKmh;
    } else {
      speedKmh = ActivityCalorieDatabase.getDefaultSpeed(category, intensity);
    }
    
    // Duration in minutes = (distance / speed) * 60
    return (distanceKm / speedKmh) * 60;
  }

  /// Get stored user weight or default
  static Future<double> getUserWeight() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getDouble(_userWeightKey) ?? _defaultWeightKg;
    } catch (e) {
      return _defaultWeightKg;
    }
  }

  /// Store user weight
  static Future<void> setUserWeight(double weightKg) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_userWeightKey, weightKg);
    } catch (e) {
      // Silently fail - not critical
    }
  }

  /// Get MET value for activity (for display purposes)
  static double getMetValue(ActivityCategory category, ActivityIntensityLevel intensity) {
    return ActivityCalorieDatabase.getMetValue(category, intensity) ?? 5.0;
  }

  /// Get activity description (for display purposes)
  static String getActivityDescription(ActivityCategory category, ActivityIntensityLevel intensity) {
    return ActivityCalorieDatabase.getDescription(category, intensity);
  }

  /// Get all categories (for UI selection)
  static List<ActivityCategory> getAllCategories() {
    return ActivityCategory.values;
  }

  /// Get all intensity levels (for UI selection)
  static List<ActivityIntensityLevel> getAllIntensityLevels() {
    return ActivityIntensityLevel.values;
  }

  /// Check if activity category supports distance-based input
  static bool supportsDistanceInput(ActivityCategory category) {
    return [
      ActivityCategory.loeb,
      ActivityCategory.gang,
      ActivityCategory.cykling,
      ActivityCategory.svoemning, // Can be distance-based for pool swimming
      ActivityCategory.roning,
      ActivityCategory.skating,
    ].contains(category);
  }

  /// Get suggested input type for activity category
  static String getSuggestedInputType(ActivityCategory category) {
    if (supportsDistanceInput(category)) {
      return 'Tid eller distance';
    } else {
      return 'Tid';
    }
  }

  /// Get default unit for activity
  static String getDefaultUnit(ActivityCategory category, bool isDistanceBased) {
    if (isDistanceBased && supportsDistanceInput(category)) {
      if (category == ActivityCategory.svoemning) {
        return 'meter'; // Swimming is usually measured in meters
      }
      return 'km';
    }
    return 'minutter';
  }

  /// Estimate calories with activity details for preview
  static Future<ActivityCalorieEstimate> estimateCalories({
    required ActivityCategory category,
    required ActivityIntensityLevel intensity,
    double? durationMinutes,
    double? distanceKm,
    double? userWeightKg,
  }) async {
    final weightKg = userWeightKg ?? await getUserWeight();
    final metValue = getMetValue(category, intensity);
    final description = getActivityDescription(category, intensity);

    int estimatedCalories;
    double estimatedDuration;

    if (distanceKm != null && distanceKm > 0) {
      // Distance-based calculation
      estimatedCalories = await calculateDistanceBasedCalories(
        category: category,
        intensity: intensity,
        distanceKm: distanceKm,
        userWeightKg: weightKg,
      );
      estimatedDuration = calculateEstimatedDuration(
        category: category,
        intensity: intensity,
        distanceKm: distanceKm,
      );
    } else if (durationMinutes != null && durationMinutes > 0) {
      // Time-based calculation
      estimatedCalories = await calculateTimeBasedCalories(
        category: category,
        intensity: intensity,
        durationMinutes: durationMinutes,
        userWeightKg: weightKg,
      );
      estimatedDuration = durationMinutes;
    } else {
      // No input provided - use defaults for 30 minutes
      estimatedCalories = await calculateTimeBasedCalories(
        category: category,
        intensity: intensity,
        durationMinutes: 30.0,
        userWeightKg: weightKg,
      );
      estimatedDuration = 30.0;
    }

    return ActivityCalorieEstimate(
      category: category,
      intensity: intensity,
      estimatedCalories: estimatedCalories,
      estimatedDuration: estimatedDuration,
      metValue: metValue,
      description: description,
      weightUsed: weightKg,
      distanceUsed: distanceKm,
    );
  }
}

/// Calorie estimate result
class ActivityCalorieEstimate {
  final ActivityCategory category;
  final ActivityIntensityLevel intensity;
  final int estimatedCalories;
  final double estimatedDuration;
  final double metValue;
  final String description;
  final double weightUsed;
  final double? distanceUsed;

  const ActivityCalorieEstimate({
    required this.category,
    required this.intensity,
    required this.estimatedCalories,
    required this.estimatedDuration,
    required this.metValue,
    required this.description,
    required this.weightUsed,
    this.distanceUsed,
  });

  /// Get formatted estimate text for display
  String get formattedEstimate {
    final buffer = StringBuffer();
    buffer.write('${estimatedCalories} kcal');
    
    if (distanceUsed != null && distanceUsed! > 0) {
      buffer.write(' • ${distanceUsed!.toStringAsFixed(1)} km');
    }
    
    buffer.write(' • ${estimatedDuration.round()} min');
    buffer.write(' • MET: ${metValue.toStringAsFixed(1)}');
    
    return buffer.toString();
  }

  /// Get detailed breakdown for display
  String get detailedBreakdown {
    final buffer = StringBuffer();
    buffer.writeln('Aktivitet: ${category.displayName}');
    buffer.writeln('Intensitet: ${intensity.displayName}');
    buffer.writeln('Beskrivelse: $description');
    buffer.writeln('Vægt brugt: ${weightUsed.toStringAsFixed(1)} kg');
    buffer.writeln('MET værdi: ${metValue.toStringAsFixed(1)}');
    buffer.writeln('Varighed: ${estimatedDuration.round()} minutter');
    if (distanceUsed != null && distanceUsed! > 0) {
      buffer.writeln('Distance: ${distanceUsed!.toStringAsFixed(1)} km');
    }
    buffer.writeln('Forbrændte kalorier: $estimatedCalories kcal');
    
    return buffer.toString();
  }
} 