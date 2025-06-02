import 'user_activity_log_model.dart';
import '../infrastructure/activity_calorie_data.dart';

/// Model for favorite activity items that can be quickly selected for logging
class FavoriteActivityModel {
  final String id;
  final String activityName;
  final ActivityInputType inputType;
  final double durationMinutes;
  final double distanceKm;
  final ActivityIntensity intensity; // Legacy field
  final ActivityCategory activityCategory; // New field for category
  final ActivityIntensityLevel intensityLevel; // New field for 4-level intensity
  final int caloriesBurned;
  final String notes;
  final DateTime createdAt;
  final DateTime lastUsed;
  final int usageCount;

  const FavoriteActivityModel({
    this.id = '',
    this.activityName = '',
    this.inputType = ActivityInputType.varighed,
    this.durationMinutes = 0.0,
    this.distanceKm = 0.0,
    this.intensity = ActivityIntensity.moderat, // Legacy default
    this.activityCategory = ActivityCategory.anden,
    this.intensityLevel = ActivityIntensityLevel.moderat,
    this.caloriesBurned = 0,
    this.notes = '',
    required this.createdAt,
    required this.lastUsed,
    this.usageCount = 0,
  });

  /// Create from JSON
  factory FavoriteActivityModel.fromJson(Map<String, dynamic> json) {
    return FavoriteActivityModel(
      id: json['id'] ?? '',
      activityName: json['activityName'] ?? '',
      inputType: _inputTypeFromString(json['inputType'] ?? 'varighed'),
      durationMinutes: (json['durationMinutes'] ?? 0.0).toDouble(),
      distanceKm: (json['distanceKm'] ?? 0.0).toDouble(),
      intensity: _intensityFromString(json['intensity'] ?? 'moderat'),
      activityCategory: _categoryFromString(json['activityCategory'] ?? 'anden'),
      intensityLevel: _intensityLevelFromString(json['intensityLevel'] ?? 'moderat'),
      caloriesBurned: json['caloriesBurned'] ?? 0,
      notes: json['notes'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      lastUsed: DateTime.tryParse(json['lastUsed'] ?? '') ?? DateTime.now(),
      usageCount: json['usageCount'] ?? 0,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activityName': activityName,
      'inputType': _inputTypeToString(inputType),
      'durationMinutes': durationMinutes,
      'distanceKm': distanceKm,
      'intensity': _intensityToString(intensity),
      'activityCategory': _categoryToString(activityCategory),
      'intensityLevel': _intensityLevelToString(intensityLevel),
      'caloriesBurned': caloriesBurned,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'lastUsed': lastUsed.toIso8601String(),
      'usageCount': usageCount,
    };
  }

  /// Copy with new values
  FavoriteActivityModel copyWith({
    String? id,
    String? activityName,
    ActivityInputType? inputType,
    double? durationMinutes,
    double? distanceKm,
    ActivityIntensity? intensity,
    ActivityCategory? activityCategory,
    ActivityIntensityLevel? intensityLevel,
    int? caloriesBurned,
    String? notes,
    DateTime? createdAt,
    DateTime? lastUsed,
    int? usageCount,
  }) {
    return FavoriteActivityModel(
      id: id ?? this.id,
      activityName: activityName ?? this.activityName,
      inputType: inputType ?? this.inputType,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      distanceKm: distanceKm ?? this.distanceKm,
      intensity: intensity ?? this.intensity,
      activityCategory: activityCategory ?? this.activityCategory,
      intensityLevel: intensityLevel ?? this.intensityLevel,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      lastUsed: lastUsed ?? this.lastUsed,
      usageCount: usageCount ?? this.usageCount,
    );
  }

  /// Create favorite from UserActivityLogModel
  factory FavoriteActivityModel.fromUserActivityLog(UserActivityLogModel activityLog) {
    return FavoriteActivityModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      activityName: activityLog.activityName,
      inputType: activityLog.inputType,
      durationMinutes: activityLog.durationMinutes,
      distanceKm: activityLog.distanceKm,
      intensity: activityLog.intensity,
      activityCategory: activityLog.activityCategory,
      intensityLevel: activityLog.intensityLevel,
      caloriesBurned: activityLog.caloriesBurned,
      notes: activityLog.notes,
      createdAt: DateTime.now(),
      lastUsed: DateTime.now(),
      usageCount: 1,
    );
  }

  /// Convert to UserActivityLogModel for logging
  UserActivityLogModel toUserActivityLog() {
    return UserActivityLogModel(
      userId: 1, // TODO: Get real user ID
      activityName: activityName,
      inputType: inputType,
      durationMinutes: durationMinutes,
      distanceKm: distanceKm,
      intensity: intensity,
      activityCategory: activityCategory,
      intensityLevel: intensityLevel,
      caloriesBurned: caloriesBurned,
      notes: notes,
      loggedAt: DateTime.now().toIso8601String(),
    );
  }

  /// Update usage statistics
  FavoriteActivityModel withUpdatedUsage() {
    return copyWith(
      lastUsed: DateTime.now(),
      usageCount: usageCount + 1,
    );
  }

  /// Get display text for the activity
  String get displayText {
    final buffer = StringBuffer('${activityCategory.emoji} $activityName');
    
    if (inputType == ActivityInputType.varighed && durationMinutes > 0) {
      buffer.write(' (${durationMinutes.round()} min)');
    } else if (inputType == ActivityInputType.distance && distanceKm > 0) {
      buffer.write(' (${distanceKm} km)');
    }
    
    buffer.write(' - ${caloriesBurned} kcal');
    buffer.write(' • ${intensityLevel.displayName}');
    
    return buffer.toString();
  }

  // Helper methods for JSON conversion (maintain legacy support)
  static ActivityInputType _inputTypeFromString(String value) {
    switch (value.toLowerCase()) {
      case 'distance':
        return ActivityInputType.distance;
      default:
        return ActivityInputType.varighed;
    }
  }

  static String _inputTypeToString(ActivityInputType type) {
    switch (type) {
      case ActivityInputType.varighed:
        return 'varighed';
      case ActivityInputType.distance:
        return 'distance';
    }
  }

  static ActivityIntensity _intensityFromString(String value) {
    switch (value.toLowerCase()) {
      case 'let':
        return ActivityIntensity.let;
      case 'haardt':
        return ActivityIntensity.haardt;
      default:
        return ActivityIntensity.moderat;
    }
  }

  static String _intensityToString(ActivityIntensity intensity) {
    switch (intensity) {
      case ActivityIntensity.let:
        return 'let';
      case ActivityIntensity.moderat:
        return 'moderat';
      case ActivityIntensity.haardt:
        return 'haardt';
    }
  }

  static ActivityCategory _categoryFromString(String value) {
    for (final category in ActivityCategory.values) {
      if (category.name.toLowerCase() == value.toLowerCase()) {
        return category;
      }
    }
    return ActivityCategory.anden;
  }

  static String _categoryToString(ActivityCategory category) {
    return category.name;
  }

  static ActivityIntensityLevel _intensityLevelFromString(String value) {
    for (final level in ActivityIntensityLevel.values) {
      if (level.name.toLowerCase() == value.toLowerCase()) {
        return level;
      }
    }
    return ActivityIntensityLevel.moderat;
  }

  static String _intensityLevelToString(ActivityIntensityLevel level) {
    return level.name;
  }
} 