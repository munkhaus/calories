import 'package:flutter_test/flutter_test.dart';
import 'package:your_project_name/features/activity/domain/user_activity_log_model.dart'; // Replace with your actual path

// Assuming ActivityInputType and ActivityIntensity are enums (can reuse from other test file or define here)

void main() {
  group('UserActivityLogModel', () {
    final testTime = DateTime.now();
    const mockJson = {
      'id': 'logEntry1',
      'user_id': 'user123',
      'activity_id': 'run001',
      'activity_name': 'Morning Jog',
      'activity_emoji': '🏃',
      'input_type': 'varighed',
      'duration_minutes': 30,
      'distance_km': null,
      'calories_burned': 300,
      'intensity': 'moderat',
      'notes': 'Felt great',
      'logged_at': '2023-10-26T10:00:00.000Z',
      'source': 'manual_entry',
      'is_manual_entry': 1,
      'is_calories_adjusted': 0,
      'activity_met_value': 7.0,
      'user_weight_kg': 70.5,
      'device_id': 'watch123',
      'external_id': 'garmin_activity_12345',
      'synced_at': '2023-10-26T10:05:00.000Z',
    };

    final mockModel = UserActivityLogModel(
      id: 'logEntry1',
      userId: 'user123',
      activityId: 'run001',
      activityName: 'Morning Jog',
      activityEmoji: '🏃',
      inputType: ActivityInputType.duration,
      durationMinutes: 30,
      distanceKm: null,
      caloriesBurned: 300,
      intensity: ActivityIntensity.moderate,
      notes: 'Felt great',
      loggedAt: DateTime.parse('2023-10-26T10:00:00.000Z'),
      source: 'manual_entry',
      isManualEntry: true,
      isCaloriesAdjusted: false,
      activityMetValue: 7.0,
      userWeightKg: 70.5,
      deviceId: 'watch123',
      externalId: 'garmin_activity_12345',
      syncedAt: DateTime.parse('2023-10-26T10:05:00.000Z'),
    );

    group('fromJson factory', () {
      test('should correctly parse complete and valid JSON', () {
        final model = UserActivityLogModel.fromJson(mockJson);
        expect(model.id, mockModel.id);
        expect(model.userId, mockModel.userId);
        expect(model.activityId, mockModel.activityId);
        expect(model.activityName, mockModel.activityName);
        expect(model.activityEmoji, mockModel.activityEmoji);
        expect(model.inputType, mockModel.inputType);
        expect(model.durationMinutes, mockModel.durationMinutes);
        expect(model.distanceKm, mockModel.distanceKm);
        expect(model.caloriesBurned, mockModel.caloriesBurned);
        expect(model.intensity, mockModel.intensity);
        expect(model.notes, mockModel.notes);
        expect(model.loggedAt, mockModel.loggedAt);
        expect(model.source, mockModel.source);
        expect(model.isManualEntry, mockModel.isManualEntry);
        expect(model.isCaloriesAdjusted, mockModel.isCaloriesAdjusted);
        expect(model.activityMetValue, mockModel.activityMetValue);
        expect(model.userWeightKg, mockModel.userWeightKg);
        expect(model.deviceId, mockModel.deviceId);
        expect(model.externalId, mockModel.externalId);
        expect(model.syncedAt, mockModel.syncedAt);
      });

      test('should handle missing/null values with defaults', () {
        final incompleteJson = {
          'activity_id': 'walk002',
          'activity_name': 'Evening Stroll',
          'calories_burned': 150,
          // Most fields missing
        };
        final model = UserActivityLogModel.fromJson(incompleteJson);
        expect(model.id, isEmpty); // Default
        expect(model.userId, isEmpty); // Default
        expect(model.activityId, 'walk002');
        expect(model.activityName, 'Evening Stroll');
        expect(model.activityEmoji, isNull); // Default
        expect(model.inputType, ActivityInputType.duration); // Default
        expect(model.durationMinutes, isNull); // Default
        expect(model.caloriesBurned, 150);
        expect(model.intensity, ActivityIntensity.moderate); // Default
        expect(model.loggedAt, isA<DateTime>()); // Default (e.g. now)
        expect(model.isManualEntry, isTrue); // Default
        expect(model.isCaloriesAdjusted, isFalse); // Default
        expect(model.activityMetValue, 0.0); // Default
      });

      test('should correctly convert enums', () {
        expect(UserActivityLogModel.fromJson({'input_type': 'distance'}).inputType, ActivityInputType.distance);
        expect(UserActivityLogModel.fromJson({'intensity': 'intens'}).intensity, ActivityIntensity.vigorous);
      });

      test('should correctly convert booleans from 1/0 and boolean', () {
        expect(UserActivityLogModel.fromJson({'is_manual_entry': 1}).isManualEntry, isTrue);
        expect(UserActivityLogModel.fromJson({'is_manual_entry': 0}).isManualEntry, isFalse);
        expect(UserActivityLogModel.fromJson({'is_manual_entry': true}).isManualEntry, isTrue);
        expect(UserActivityLogModel.fromJson({'is_manual_entry': false}).isManualEntry, isFalse);
        expect(UserActivityLogModel.fromJson({'is_calories_adjusted': 1}).isCaloriesAdjusted, isTrue);
      });
    });

    group('toJson method', () {
      test('should correctly serialize all fields', () {
        final json = mockModel.toJson();
        expect(json['id'], mockModel.id);
        expect(json['user_id'], mockModel.userId);
        expect(json['activity_id'], mockModel.activityId);
        // ... (check all other fields similar to fromJson)
        expect(json['input_type'], 'varighed');
        expect(json['intensity'], 'moderat');
        expect(json['logged_at'], mockModel.loggedAt.toIso8601String());
        expect(json['is_manual_entry'], 1);
        expect(json['is_calories_adjusted'], 0);
        expect(json['activity_met_value'], mockModel.activityMetValue);
        expect(json['user_weight_kg'], mockModel.userWeightKg);
        expect(json['device_id'], mockModel.deviceId);
        expect(json['external_id'], mockModel.externalId);
        expect(json['synced_at'], mockModel.syncedAt?.toIso8601String());
      });
    });

    group('copyWith method', () {
      test('should update individual fields', () {
        final updated = mockModel.copyWith(notes: 'Very tiring');
        expect(updated.notes, 'Very tiring');
        expect(updated.caloriesBurned, mockModel.caloriesBurned);
      });
      test('should update multiple fields', () {
        final newTime = testTime.add(Duration(hours:1));
        final updated = mockModel.copyWith(caloriesBurned: 350, loggedAt: newTime, isCaloriesAdjusted: true);
        expect(updated.caloriesBurned, 350);
        expect(updated.loggedAt, newTime);
        expect(updated.isCaloriesAdjusted, isTrue);
      });
    });

    group('Getters', () {
      test('intensityDisplayName', () {
        expect(UserActivityLogModel(intensity: ActivityIntensity.light).intensityDisplayName, 'Let');
        expect(UserActivityLogModel(intensity: ActivityIntensity.moderate).intensityDisplayName, 'Moderat');
        expect(UserActivityLogModel(intensity: ActivityIntensity.vigorous).intensityDisplayName, 'Intens');
      });

      test('inputTypeDisplayName', () {
        expect(UserActivityLogModel(inputType: ActivityInputType.duration).inputTypeDisplayName, 'Varighed');
        expect(UserActivityLogModel(inputType: ActivityInputType.distance).inputTypeDisplayName, 'Distance');
      });

      test('primaryValue', () {
        expect(UserActivityLogModel(inputType: ActivityInputType.duration, durationMinutes: 45).primaryValue, 45);
        expect(UserActivityLogModel(inputType: ActivityInputType.distance, distanceKm: 5.5).primaryValue, 5.5);
      });

      test('primaryUnit', () {
        expect(UserActivityLogModel(inputType: ActivityInputType.duration).primaryUnit, 'min');
        expect(UserActivityLogModel(inputType: ActivityInputType.distance).primaryUnit, 'km');
      });

      group('formattedDuration', () {
        test('less than 60 minutes', () {
          expect(UserActivityLogModel(durationMinutes: 45).formattedDuration, '45 min');
          expect(UserActivityLogModel(durationMinutes: 30.5).formattedDuration, '31 min'); // Assumes rounding or specific formatting
        });
        test('exactly 60 minutes', () {
          expect(UserActivityLogModel(durationMinutes: 60).formattedDuration, '1 t');
        });
        test('more than 60 minutes, no fractional hours', () {
          expect(UserActivityLogModel(durationMinutes: 120).formattedDuration, '2 t');
        });
        test('more than 60 minutes, with fractional hours (showing minutes)', () {
          expect(UserActivityLogModel(durationMinutes: 75).formattedDuration, '1 t 15 min');
          expect(UserActivityLogModel(durationMinutes: 90.75).formattedDuration, '1 t 31 min'); // Assumes rounding of minutes
        });
         test('zero minutes', () {
          expect(UserActivityLogModel(durationMinutes: 0).formattedDuration, '0 min');
        });
        test('null minutes', () {
          expect(UserActivityLogModel(durationMinutes: null).formattedDuration, '0 min');
        });
      });

      group('formattedDistance', () {
        test('less than 1 km (shows in meters)', () {
          expect(UserActivityLogModel(distanceKm: 0.5).formattedDistance, '500 m');
          expect(UserActivityLogModel(distanceKm: 0.755).formattedDistance, '755 m'); // Assumes rounding
        });
        test('exactly 1 km', () {
          expect(UserActivityLogModel(distanceKm: 1.0).formattedDistance, '1.0 km');
        });
        test('more than 1 km', () {
          expect(UserActivityLogModel(distanceKm: 5.3).formattedDistance, '5.3 km');
          expect(UserActivityLogModel(distanceKm: 5.34).formattedDistance, '5.3 km'); // One decimal
          expect(UserActivityLogModel(distanceKm: 5.37).formattedDistance, '5.4 km'); // Rounding for one decimal
        });
        test('zero km', () {
          expect(UserActivityLogModel(distanceKm: 0).formattedDistance, '0 m');
        });
        test('null km', () {
          expect(UserActivityLogModel(distanceKm: null).formattedDistance, '0 m');
        });
      });
    });
  });
}


// --- Mock/Placeholder definitions ---
// Replace with your actual model and enum imports if they are not in the same file or already imported.
// These are simplified versions. Your actual enums might have more properties or methods.

enum ActivityInputType {
  duration,
  distance;

  static ActivityInputType fromString(String? type) {
    if (type == 'distance') return ActivityInputType.distance;
    if (type == 'varighed') return ActivityInputType.duration;
    return ActivityInputType.duration; // Default
  }

  String toJson() {
    return this == ActivityInputType.distance ? 'distance' : 'varighed';
  }

  String toDisplayString() {
    switch (this) {
      case ActivityInputType.duration: return 'Varighed';
      case ActivityInputType.distance: return 'Distance';
    }
  }
   String get unitLabel => this == ActivityInputType.duration ? 'min' : 'km';
}

enum ActivityIntensity {
  light,
  moderate,
  vigorous;

  static ActivityIntensity fromString(String? intensity) {
    switch (intensity?.toLowerCase()) {
      case 'let': return ActivityIntensity.light;
      case 'intens': return ActivityIntensity.vigorous;
      case 'moderat':
      default:
        return ActivityIntensity.moderate;
    }
  }

  String toJson() {
    switch (this) {
      case ActivityIntensity.light: return 'let';
      case ActivityIntensity.moderate: return 'moderat';
      case ActivityIntensity.vigorous: return 'intens';
    }
  }
  String toDisplayString() {
    switch (this) {
      case ActivityIntensity.light: return 'Let';
      case ActivityIntensity.moderate: return 'Moderat';
      case ActivityIntensity.vigorous: return 'Intens';
    }
  }
}

class UserActivityLogModel {
  final String id;
  final String userId;
  final String activityId;
  final String activityName;
  final String? activityEmoji;
  final ActivityInputType inputType;
  final double? durationMinutes; // Changed to double to support partial minutes from formatting tests
  final double? distanceKm;
  final int caloriesBurned;
  final ActivityIntensity intensity;
  final String? notes;
  final DateTime loggedAt;
  final String source;
  final bool isManualEntry;
  final bool isCaloriesAdjusted;
  final double activityMetValue;
  final double? userWeightKg;
  final String? deviceId;
  final String? externalId;
  final DateTime? syncedAt;


  UserActivityLogModel({
    this.id = '',
    this.userId = '',
    required this.activityId,
    required this.activityName,
    this.activityEmoji,
    this.inputType = ActivityInputType.duration,
    this.durationMinutes,
    this.distanceKm,
    required this.caloriesBurned,
    this.intensity = ActivityIntensity.moderate,
    this.notes,
    DateTime? loggedAt,
    this.source = 'manual',
    this.isManualEntry = true,
    this.isCaloriesAdjusted = false,
    this.activityMetValue = 0.0,
    this.userWeightKg,
    this.deviceId,
    this.externalId,
    this.syncedAt,
  }) : this.loggedAt = loggedAt ?? DateTime.now();

  factory UserActivityLogModel.fromJson(Map<String, dynamic> json) {
    return UserActivityLogModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      activityId: json['activity_id'] as String? ?? '',
      activityName: json['activity_name'] as String? ?? '',
      activityEmoji: json['activity_emoji'] as String?,
      inputType: ActivityInputType.fromString(json['input_type'] as String?),
      durationMinutes: (json['duration_minutes'] as num?)?.toDouble(),
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      caloriesBurned: (json['calories_burned'] as num?)?.toInt() ?? 0,
      intensity: ActivityIntensity.fromString(json['intensity'] as String?),
      notes: json['notes'] as String?,
      loggedAt: json['logged_at'] != null ? DateTime.tryParse(json['logged_at']) ?? DateTime.now() : DateTime.now(),
      source: json['source'] as String? ?? 'manual',
      isManualEntry: json['is_manual_entry'] == 1 || json['is_manual_entry'] == true,
      isCaloriesAdjusted: json['is_calories_adjusted'] == 1 || json['is_calories_adjusted'] == true,
      activityMetValue: (json['activity_met_value'] as num?)?.toDouble() ?? 0.0,
      userWeightKg: (json['user_weight_kg'] as num?)?.toDouble(),
      deviceId: json['device_id'] as String?,
      externalId: json['external_id'] as String?,
      syncedAt: json['synced_at'] != null ? DateTime.tryParse(json['synced_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'activity_id': activityId,
      'activity_name': activityName,
      'activity_emoji': activityEmoji,
      'input_type': inputType.toJson(),
      'duration_minutes': durationMinutes,
      'distance_km': distanceKm,
      'calories_burned': caloriesBurned,
      'intensity': intensity.toJson(),
      'notes': notes,
      'logged_at': loggedAt.toIso8601String(),
      'source': source,
      'is_manual_entry': isManualEntry ? 1 : 0,
      'is_calories_adjusted': isCaloriesAdjusted ? 1 : 0,
      'activity_met_value': activityMetValue,
      'user_weight_kg': userWeightKg,
      'device_id': deviceId,
      'external_id': externalId,
      'synced_at': syncedAt?.toIso8601String(),
    };
  }

  UserActivityLogModel copyWith({
    String? id,
    String? userId,
    String? activityId,
    String? activityName,
    String? activityEmoji,
    ActivityInputType? inputType,
    double? durationMinutes,
    bool clearDurationMinutes = false,
    double? distanceKm,
    bool clearDistanceKm = false,
    int? caloriesBurned,
    ActivityIntensity? intensity,
    String? notes,
    bool clearNotes = false,
    DateTime? loggedAt,
    String? source,
    bool? isManualEntry,
    bool? isCaloriesAdjusted,
    double? activityMetValue,
    double? userWeightKg,
    bool clearUserWeightKg = false,
    String? deviceId,
    bool clearDeviceId = false,
    String? externalId,
    bool clearExternalId = false,
    DateTime? syncedAt,
    bool clearSyncedAt = false,
  }) {
    return UserActivityLogModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      activityId: activityId ?? this.activityId,
      activityName: activityName ?? this.activityName,
      activityEmoji: activityEmoji ?? this.activityEmoji,
      inputType: inputType ?? this.inputType,
      durationMinutes: clearDurationMinutes ? null : durationMinutes ?? this.durationMinutes,
      distanceKm: clearDistanceKm ? null : distanceKm ?? this.distanceKm,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      intensity: intensity ?? this.intensity,
      notes: clearNotes? null : notes ?? this.notes,
      loggedAt: loggedAt ?? this.loggedAt,
      source: source ?? this.source,
      isManualEntry: isManualEntry ?? this.isManualEntry,
      isCaloriesAdjusted: isCaloriesAdjusted ?? this.isCaloriesAdjusted,
      activityMetValue: activityMetValue ?? this.activityMetValue,
      userWeightKg: clearUserWeightKg? null : userWeightKg ?? this.userWeightKg,
      deviceId: clearDeviceId? null : deviceId ?? this.deviceId,
      externalId: clearExternalId? null : externalId ?? this.externalId,
      syncedAt: clearSyncedAt? null : syncedAt ?? this.syncedAt,
    );
  }

  String get intensityDisplayName => intensity.toDisplayString();
  String get inputTypeDisplayName => inputType.toDisplayString();
  num get primaryValue => inputType == ActivityInputType.duration ? (durationMinutes ?? 0) : (distanceKm ?? 0);
  String get primaryUnit => inputType.unitLabel;

  String get formattedDuration {
    final dur = durationMinutes ?? 0;
    if (dur <= 0) return '0 min';
    final totalMinutes = dur.round();
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours == 0) return '$minutes min';
    if (minutes == 0) return '$hours t';
    return '$hours t $minutes min';
  }

  String get formattedDistance {
    final dist = distanceKm ?? 0;
    if (dist <= 0) return '0 m';
    if (dist < 1.0) {
      return '${(dist * 1000).round()} m';
    }
    return '${dist.toStringAsFixed(1)} km';
  }
}
