/// Predefined activity model for calorie calculations
class ActivityItemModel {
  final int activityId;
  final String name;
  final String category;
  final double caloriesPerMinute;
  final double caloriesPerKgPerKm;
  final bool supportsDuration;
  final bool supportsDistance;
  final String iconName;
  final String description;

  const ActivityItemModel({
    this.activityId = 0,
    this.name = '',
    this.category = '',
    this.caloriesPerMinute = 0.0,
    this.caloriesPerKgPerKm = 0.0,
    this.supportsDuration = true,
    this.supportsDistance = false,
    this.iconName = '',
    this.description = '',
  });

  factory ActivityItemModel.fromJson(Map<String, dynamic> json) {
    return ActivityItemModel(
      activityId: json['activity_id'] ?? 0,
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      caloriesPerMinute: (json['calories_per_minute'] ?? 0.0).toDouble(),
      caloriesPerKgPerKm: (json['calories_per_kg_per_km'] ?? 0.0).toDouble(),
      supportsDuration: json['supports_duration'] == 1,
      supportsDistance: json['supports_distance'] == 1,
      iconName: json['icon_name'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activity_id': activityId,
      'name': name,
      'category': category,
      'calories_per_minute': caloriesPerMinute,
      'calories_per_kg_per_km': caloriesPerKgPerKm,
      'supports_duration': supportsDuration ? 1 : 0,
      'supports_distance': supportsDistance ? 1 : 0,
      'icon_name': iconName,
      'description': description,
    };
  }
}

/// Extension for helper methods
extension ActivityItemModelExtension on ActivityItemModel {
  /// Calculate calories burned based on duration and user weight
  int calculateCaloriesForDuration(double minutes, double userWeightKg) {
    // Use base calories per minute, adjusted for user weight
    // Formula: base_rate * (user_weight / 70) * minutes
    // 70kg is assumed reference weight for the base rates
    final adjustedRate = caloriesPerMinute * (userWeightKg / 70.0);
    return (adjustedRate * minutes).round();
  }

  /// Calculate calories burned based on distance and user weight
  int calculateCaloriesForDistance(double km, double userWeightKg) {
    return (caloriesPerKgPerKm * userWeightKg * km).round();
  }

  /// Get appropriate calorie calculation based on input type
  int calculateCalories({
    required double value,
    required bool isDuration,
    required double userWeightKg,
  }) {
    if (isDuration) {
      return calculateCaloriesForDuration(value, userWeightKg);
    } else {
      return calculateCaloriesForDistance(value, userWeightKg);
    }
  }
} 