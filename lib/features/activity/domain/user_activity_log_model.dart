/// Enum for activity intensity levels
enum ActivityIntensity {
  let,
  moderat,
  haardt,
}

/// Enum for input type (duration or distance)
enum ActivityInputType {
  varighed,
  distance,
}

/// User activity log domain model
class UserActivityLogModel {
  final int logEntryId;
  final int userId;
  final String activityName;
  final String loggedAt;
  final ActivityInputType inputType;
  final double durationMinutes;
  final double distanceKm;
  final ActivityIntensity intensity;
  final int caloriesBurned;
  final bool isManualEntry;
  final bool isCaloriesAdjusted;
  final String notes;
  final String createdAt;
  final String updatedAt;

  const UserActivityLogModel({
    this.logEntryId = 0,
    this.userId = 0,
    this.activityName = '',
    this.loggedAt = '',
    this.inputType = ActivityInputType.varighed,
    this.durationMinutes = 0.0,
    this.distanceKm = 0.0,
    this.intensity = ActivityIntensity.moderat,
    this.caloriesBurned = 0,
    this.isManualEntry = false,
    this.isCaloriesAdjusted = false,
    this.notes = '',
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory UserActivityLogModel.fromJson(Map<String, dynamic> json) {
    return UserActivityLogModel(
      logEntryId: json['log_entry_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      activityName: json['activity_name'] ?? '',
      loggedAt: json['logged_at'] ?? '',
      inputType: _inputTypeFromString(json['input_type'] ?? 'varighed'),
      durationMinutes: (json['duration_minutes'] ?? 0.0).toDouble(),
      distanceKm: (json['distance_km'] ?? 0.0).toDouble(),
      intensity: _intensityFromString(json['intensity'] ?? 'moderat'),
      caloriesBurned: json['calories_burned'] ?? 0,
      isManualEntry: json['is_manual_entry'] == 1,
      isCaloriesAdjusted: json['is_calories_adjusted'] == 1,
      notes: json['notes'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'log_entry_id': logEntryId,
      'user_id': userId,
      'activity_name': activityName,
      'logged_at': loggedAt,
      'input_type': _inputTypeToString(inputType),
      'duration_minutes': durationMinutes,
      'distance_km': distanceKm,
      'intensity': _intensityToString(intensity),
      'calories_burned': caloriesBurned,
      'is_manual_entry': isManualEntry ? 1 : 0,
      'is_calories_adjusted': isCaloriesAdjusted ? 1 : 0,
      'notes': notes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

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

  UserActivityLogModel copyWith({
    int? logEntryId,
    int? userId,
    String? activityName,
    String? loggedAt,
    ActivityInputType? inputType,
    double? durationMinutes,
    double? distanceKm,
    ActivityIntensity? intensity,
    int? caloriesBurned,
    bool? isManualEntry,
    bool? isCaloriesAdjusted,
    String? notes,
    String? createdAt,
    String? updatedAt,
  }) {
    return UserActivityLogModel(
      logEntryId: logEntryId ?? this.logEntryId,
      userId: userId ?? this.userId,
      activityName: activityName ?? this.activityName,
      loggedAt: loggedAt ?? this.loggedAt,
      inputType: inputType ?? this.inputType,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      distanceKm: distanceKm ?? this.distanceKm,
      intensity: intensity ?? this.intensity,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      isManualEntry: isManualEntry ?? this.isManualEntry,
      isCaloriesAdjusted: isCaloriesAdjusted ?? this.isCaloriesAdjusted,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Extension for helper methods
extension UserActivityLogModelExtension on UserActivityLogModel {
  /// Get display name for intensity
  String get intensityDisplayName {
    switch (intensity) {
      case ActivityIntensity.let:
        return 'Let';
      case ActivityIntensity.moderat:
        return 'Moderat';
      case ActivityIntensity.haardt:
        return 'Hård';
    }
  }

  /// Get display name for input type
  String get inputTypeDisplayName {
    switch (inputType) {
      case ActivityInputType.varighed:
        return 'Varighed';
      case ActivityInputType.distance:
        return 'Distance';
    }
  }

  /// Get primary value based on input type
  double get primaryValue {
    switch (inputType) {
      case ActivityInputType.varighed:
        return durationMinutes;
      case ActivityInputType.distance:
        return distanceKm;
    }
  }

  /// Get unit for primary value
  String get primaryUnit {
    switch (inputType) {
      case ActivityInputType.varighed:
        return 'min';
      case ActivityInputType.distance:
        return 'km';
    }
  }

  /// Get formatted duration string
  String get formattedDuration {
    if (durationMinutes < 60) {
      // Show decimals only if needed, but nicely formatted
      if (durationMinutes % 1 == 0) {
        return '${durationMinutes.toInt()} min';
      } else {
        return '${durationMinutes.toStringAsFixed(1)} min';
      }
    } else {
      final hours = (durationMinutes / 60).floor();
      final remainingMinutes = durationMinutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}t';
      } else if (remainingMinutes % 1 == 0) {
        return '${hours}t ${remainingMinutes.toInt()}min';
      } else {
        return '${hours}t ${remainingMinutes.toStringAsFixed(1)}min';
      }
    }
  }

  /// Get formatted distance string
  String get formattedDistance {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).toInt()} m';
    } else {
      return '${distanceKm.toStringAsFixed(1)} km';
    }
  }
} 