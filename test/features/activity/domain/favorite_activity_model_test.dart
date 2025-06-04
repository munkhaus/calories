import 'package:flutter_test/flutter_test.dart';
import 'package:your_project_name/features/activity/domain/favorite_activity_model.dart'; // Replace with your actual path
import 'package:your_project_name/features/activity/domain/user_activity_log_model.dart'; // Replace with your actual path
// Assuming ActivityInputType and ActivityIntensity are enums

void main() {
  group('FavoriteActivityModel', () {
    final baseTime = DateTime.now();
    final mockJson = {
      'id': 'fav1',
      'activity_id': 'act123',
      'activity_name': 'Morning Run',
      'emoji': '☀️',
      'input_type': 'varighed', // Danish for duration
      'duration_minutes': 30,
      'distance_km': null,
      'calories': 250,
      'intensity': 'moderat', // Danish for moderate
      'notes': 'Felt good',
      'created_at': baseTime.toIso8601String(),
      'last_used': baseTime.subtract(Duration(days: 1)).toIso8601String(),
      'usage_count': 5,
      'activity_met_value': 8.0,
    };

    final mockModel = FavoriteActivityModel(
      id: 'fav1',
      activityId: 'act123',
      activityName: 'Morning Run',
      emoji: '☀️',
      inputType: ActivityInputType.duration,
      durationMinutes: 30,
      distanceKm: null,
      calories: 250,
      intensity: ActivityIntensity.moderate,
      notes: 'Felt good',
      createdAt: baseTime,
      lastUsed: baseTime.subtract(Duration(days: 1)),
      usageCount: 5,
      activityMetValue: 8.0,
    );

    group('fromJson factory', () {
      test('should correctly parse valid JSON', () {
        final model = FavoriteActivityModel.fromJson(mockJson);
        expect(model.id, mockModel.id);
        expect(model.activityId, mockModel.activityId);
        expect(model.activityName, mockModel.activityName);
        expect(model.emoji, mockModel.emoji);
        expect(model.inputType, mockModel.inputType);
        expect(model.durationMinutes, mockModel.durationMinutes);
        expect(model.distanceKm, mockModel.distanceKm);
        expect(model.calories, mockModel.calories);
        expect(model.intensity, mockModel.intensity);
        expect(model.notes, mockModel.notes);
        expect(model.createdAt.toIso8601String(), mockModel.createdAt.toIso8601String());
        expect(model.lastUsed.toIso8601String(), mockModel.lastUsed.toIso8601String());
        expect(model.usageCount, mockModel.usageCount);
        expect(model.activityMetValue, mockModel.activityMetValue);
      });

      test('should handle missing/null values and use defaults', () {
        final incompleteJson = {
          'id': 'fav2',
          'activity_id': 'act456',
          'activity_name': 'Quick Walk',
          // Other fields missing
        };
        final model = FavoriteActivityModel.fromJson(incompleteJson);
        expect(model.id, 'fav2');
        expect(model.activityId, 'act456');
        expect(model.activityName, 'Quick Walk');
        expect(model.emoji, isEmpty);
        expect(model.inputType, ActivityInputType.duration); // Default
        expect(model.durationMinutes, 0);
        expect(model.distanceKm, isNull);
        expect(model.calories, 0);
        expect(model.intensity, ActivityIntensity.moderate); // Default
        expect(model.notes, isEmpty);
        expect(model.createdAt, isA<DateTime>()); // Should be set to a default, e.g. now
        expect(model.lastUsed, isA<DateTime>());
        expect(model.usageCount, 0);
        expect(model.activityMetValue, 0.0);
      });

      test('should correctly parse enum types', () {
        expect(FavoriteActivityModel.fromJson({'input_type': 'varighed'}).inputType, ActivityInputType.duration);
        expect(FavoriteActivityModel.fromJson({'input_type': 'distance'}).inputType, ActivityInputType.distance);
        expect(FavoriteActivityModel.fromJson({'input_type': 'andet'}).inputType, ActivityInputType.duration); // Default or other

        expect(FavoriteActivityModel.fromJson({'intensity': 'let'}).intensity, ActivityIntensity.light);
        expect(FavoriteActivityModel.fromJson({'intensity': 'moderat'}).intensity, ActivityIntensity.moderate);
        expect(FavoriteActivityModel.fromJson({'intensity': 'intens'}).intensity, ActivityIntensity.vigorous);
        expect(FavoriteActivityModel.fromJson({'intensity': 'andet'}).intensity, ActivityIntensity.moderate); // Default or other
      });
    });

    group('toJson method', () {
      test('should correctly serialize a complete model', () {
        final json = mockModel.toJson();
        expect(json['id'], mockModel.id);
        expect(json['activity_id'], mockModel.activityId);
        expect(json['activity_name'], mockModel.activityName);
        expect(json['emoji'], mockModel.emoji);
        expect(json['input_type'], 'varighed');
        expect(json['duration_minutes'], mockModel.durationMinutes);
        expect(json['distance_km'], mockModel.distanceKm);
        expect(json['calories'], mockModel.calories);
        expect(json['intensity'], 'moderat');
        expect(json['notes'], mockModel.notes);
        expect(json['created_at'], mockModel.createdAt.toIso8601String());
        expect(json['last_used'], mockModel.lastUsed.toIso8601String());
        expect(json['usage_count'], mockModel.usageCount);
        expect(json['activity_met_value'], mockModel.activityMetValue);
      });
    });

    group('copyWith method', () {
      test('should update individual fields', () {
        final updatedNotes = mockModel.copyWith(notes: 'New notes');
        expect(updatedNotes.notes, 'New notes');
        expect(updatedNotes.activityName, mockModel.activityName); // Unchanged

        final updatedCalories = mockModel.copyWith(calories: 300);
        expect(updatedCalories.calories, 300);
      });

      test('should update multiple fields', () {
        final newTime = DateTime.now().add(Duration(hours: 1));
        final updatedModel = mockModel.copyWith(
          durationMinutes: 45,
          intensity: ActivityIntensity.vigorous,
          lastUsed: newTime,
        );
        expect(updatedModel.durationMinutes, 45);
        expect(updatedModel.intensity, ActivityIntensity.vigorous);
        expect(updatedModel.lastUsed, newTime);
      });

      test('non-updated fields should retain original values', () {
        final copiedModel = mockModel.copyWith(); // No changes
        expect(copiedModel.id, mockModel.id);
        expect(copiedModel.activityName, mockModel.activityName);
        // ... check all fields
      });
    });

    group('fromUserActivityLog factory', () {
      final userLog = UserActivityLogModel(
        id: 'log789',
        activityId: 'actABC',
        activityName: 'Cycling',
        activityEmoji: '🚴',
        inputType: ActivityInputType.distance,
        durationMinutes: null,
        distanceKm: 10.5,
        caloriesBurned: 400,
        intensity: ActivityIntensity.vigorous,
        notes: 'Windy ride',
        loggedAt: DateTime(2023, 5, 10),
        activityMetValue: 7.5,
      );

      test('should correctly map fields from UserActivityLogModel', () {
        final before = DateTime.now();
        final fav = FavoriteActivityModel.fromUserActivityLog(userLog);
        final after = DateTime.now();

        expect(fav.activityId, userLog.activityId);
        expect(fav.activityName, userLog.activityName);
        expect(fav.emoji, userLog.activityEmoji);
        expect(fav.inputType, userLog.inputType);
        expect(fav.durationMinutes, userLog.durationMinutes);
        expect(fav.distanceKm, userLog.distanceKm);
        expect(fav.calories, userLog.caloriesBurned);
        expect(fav.intensity, userLog.intensity);
        expect(fav.notes, userLog.notes);
        expect(fav.activityMetValue, userLog.activityMetValue);

        expect(fav.id.isNotEmpty, isTrue); // ID is generated
        expect(fav.createdAt.isAtSameMomentAs(fav.lastUsed), isTrue);
        expect(fav.createdAt.isAfter(before.subtract(Duration(microseconds: 1))) && fav.createdAt.isBefore(after.add(Duration(microseconds: 1))), isTrue, reason: "createdAt should be current time");

        expect(fav.usageCount, 1);
      });
    });

    group('toUserActivityLog method', () {
      test('should correctly map to UserActivityLogModel', () {
        final fav = FavoriteActivityModel(
          activityId: 'actXYZ',
          activityName: 'Yoga',
          emoji: '🧘',
          inputType: ActivityInputType.duration,
          durationMinutes: 60,
          calories: 180,
          intensity: ActivityIntensity.light,
          notes: 'Relaxing session',
          activityMetValue: 3.0,
        );
        final before = DateTime.now();
        final userLog = fav.toUserActivityLog();
        final after = DateTime.now();

        expect(userLog.activityId, fav.activityId);
        expect(userLog.activityName, fav.activityName);
        expect(userLog.activityEmoji, fav.emoji);
        expect(userLog.inputType, fav.inputType);
        expect(userLog.durationMinutes, fav.durationMinutes);
        expect(userLog.distanceKm, fav.distanceKm);
        expect(userLog.caloriesBurned, fav.calories);
        expect(userLog.intensity, fav.intensity);
        expect(userLog.notes, fav.notes);
        expect(userLog.activityMetValue, fav.activityMetValue);

        expect(userLog.userId, '1'); // Hardcoded as per note
        expect(userLog.loggedAt.isAfter(before.subtract(Duration(microseconds: 1))) && userLog.loggedAt.isBefore(after.add(Duration(microseconds: 1))), isTrue, reason: "loggedAt should be current time");
        // id, source, etc. would be defaults for UserActivityLogModel or set by its constructor
      });
    });

    group('withUpdatedUsage method', () {
      test('should update lastUsed and increment usageCount', () {
        final originalTime = DateTime(2023, 1, 1);
        final fav = FavoriteActivityModel(lastUsed: originalTime, usageCount: 3);

        final beforeUpdate = DateTime.now();
        final updatedFav = fav.withUpdatedUsage();
        final afterUpdate = DateTime.now();

        expect(updatedFav.usageCount, 4);
        expect(updatedFav.lastUsed.isAfter(beforeUpdate.subtract(Duration(microseconds: 1))) && updatedFav.lastUsed.isBefore(afterUpdate.add(Duration(microseconds: 1))), isTrue);
        expect(updatedFav.lastUsed.isAfter(originalTime), isTrue);
      });
    });

    group('displayText getter', () {
      test('for duration type', () {
        final fav = FavoriteActivityModel(
            emoji: '🏃', activityName: 'Run', inputType: ActivityInputType.duration,
            durationMinutes: 30, calories: 250, intensity: ActivityIntensity.moderate);
        // Example: "🏃 Run: 30 min, 250 kcal (Moderat)"
        // The exact format depends on your implementation, so adjust the expected string.
        expect(fav.displayText, contains('🏃'));
        expect(fav.displayText, contains('Run'));
        expect(fav.displayText, contains('30 min'));
        expect(fav.displayText, contains('250 kcal'));
        expect(fav.displayText, contains('(Moderat)')); // Assuming Danish from intensityToString
      });

      test('for distance type', () {
        final fav = FavoriteActivityModel(
            emoji: '🚴', activityName: 'Bike Ride', inputType: ActivityInputType.distance,
            distanceKm: 10.5, calories: 400, intensity: ActivityIntensity.vigorous);
        // Example: "🚴 Bike Ride: 10.5 km, 400 kcal (Intens)"
        expect(fav.displayText, contains('🚴'));
        expect(fav.displayText, contains('Bike Ride'));
        expect(fav.displayText, contains('10.5 km'));
        expect(fav.displayText, contains('400 kcal'));
        expect(fav.displayText, contains('(Intens)'));
      });
       test('for duration type with zero minutes (should still display)', () {
        final fav = FavoriteActivityModel(
            emoji: '🧘', activityName: 'Meditation', inputType: ActivityInputType.duration,
            durationMinutes: 0, calories: 50, intensity: ActivityIntensity.light);
        expect(fav.displayText, contains('0 min'));
      });
    });
  });
}

// --- Mock/Placeholder definitions ---
// Replace with your actual model and enum imports

enum ActivityInputType {
  duration,
  distance;

  static ActivityInputType fromString(String? type) {
    if (type == 'distance') return ActivityInputType.distance;
    return ActivityInputType.duration; // Default
  }

  String toJson() {
    return this == ActivityInputType.duration ? 'varighed' : 'distance';
  }
   String toDisplayString() { // Example for displayText
    return this == ActivityInputType.duration ? 'min' : 'km';
  }
}

enum ActivityIntensity {
  light,
  moderate,
  vigorous;

  static ActivityIntensity fromString(String? intensity) {
    switch (intensity) {
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
   String toDisplayString() { // Example for displayText
    switch (this) {
      case ActivityIntensity.light: return 'Let';
      case ActivityIntensity.moderate: return 'Moderat';
      case ActivityIntensity.vigorous: return 'Intens';
    }
  }
}

class FavoriteActivityModel {
  final String id;
  final String activityId;
  final String activityName;
  final String emoji;
  final ActivityInputType inputType;
  final int? durationMinutes;
  final double? distanceKm;
  final int calories;
  final ActivityIntensity intensity;
  final String notes;
  final DateTime createdAt;
  final DateTime lastUsed;
  final int usageCount;
  final double activityMetValue; // New field

  FavoriteActivityModel({
    this.id = '',
    this.activityId = '',
    this.activityName = '',
    this.emoji = '',
    this.inputType = ActivityInputType.duration,
    this.durationMinutes,
    this.distanceKm,
    this.calories = 0,
    this.intensity = ActivityIntensity.moderate,
    this.notes = '',
    DateTime? createdAt,
    DateTime? lastUsed,
    this.usageCount = 0,
    this.activityMetValue = 0.0,
  })  : this.createdAt = createdAt ?? DateTime.now(),
        this.lastUsed = lastUsed ?? DateTime.now();

  factory FavoriteActivityModel.fromJson(Map<String, dynamic> json) {
    return FavoriteActivityModel(
      id: json['id'] as String? ?? '',
      activityId: json['activity_id'] as String? ?? '',
      activityName: json['activity_name'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '',
      inputType: ActivityInputType.fromString(json['input_type'] as String?),
      durationMinutes: (json['duration_minutes'] as num?)?.toInt(),
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      intensity: ActivityIntensity.fromString(json['intensity'] as String?),
      notes: json['notes'] as String? ?? '',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) ?? DateTime.now() : DateTime.now(),
      lastUsed: json['last_used'] != null ? DateTime.tryParse(json['last_used']) ?? DateTime.now() : DateTime.now(),
      usageCount: (json['usage_count'] as num?)?.toInt() ?? 0,
      activityMetValue: (json['activity_met_value'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activity_id': activityId,
      'activity_name': activityName,
      'emoji': emoji,
      'input_type': inputType.toJson(),
      'duration_minutes': durationMinutes,
      'distance_km': distanceKm,
      'calories': calories,
      'intensity': intensity.toJson(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'last_used': lastUsed.toIso8601String(),
      'usage_count': usageCount,
      'activity_met_value': activityMetValue,
    };
  }

  FavoriteActivityModel copyWith({
    String? id,
    String? activityId,
    String? activityName,
    String? emoji,
    ActivityInputType? inputType,
    int? durationMinutes,
    bool clearDurationMinutes = false,
    double? distanceKm,
    bool clearDistanceKm = false,
    int? calories,
    ActivityIntensity? intensity,
    String? notes,
    DateTime? createdAt,
    DateTime? lastUsed,
    int? usageCount,
    double? activityMetValue,
  }) {
    return FavoriteActivityModel(
      id: id ?? this.id,
      activityId: activityId ?? this.activityId,
      activityName: activityName ?? this.activityName,
      emoji: emoji ?? this.emoji,
      inputType: inputType ?? this.inputType,
      durationMinutes: clearDurationMinutes ? null : durationMinutes ?? this.durationMinutes,
      distanceKm: clearDistanceKm ? null : distanceKm ?? this.distanceKm,
      calories: calories ?? this.calories,
      intensity: intensity ?? this.intensity,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      lastUsed: lastUsed ?? this.lastUsed,
      usageCount: usageCount ?? this.usageCount,
      activityMetValue: activityMetValue ?? this.activityMetValue,
    );
  }

  factory FavoriteActivityModel.fromUserActivityLog(UserActivityLogModel log) {
    final now = DateTime.now();
    return FavoriteActivityModel(
      // Generate a unique ID, e.g., based on timestamp or UUID
      id: 'fav_${now.millisecondsSinceEpoch}_${log.activityId.hashCode}',
      activityId: log.activityId,
      activityName: log.activityName,
      emoji: log.activityEmoji ?? '',
      inputType: log.inputType,
      durationMinutes: log.durationMinutes,
      distanceKm: log.distanceKm,
      calories: log.caloriesBurned,
      intensity: log.intensity,
      notes: log.notes ?? '',
      createdAt: now,
      lastUsed: now,
      usageCount: 1,
      activityMetValue: log.activityMetValue,
    );
  }

  UserActivityLogModel toUserActivityLog() {
    return UserActivityLogModel(
      // id will be generated by backend or UserActivityLogModel constructor if new
      activityId: activityId,
      activityName: activityName,
      activityEmoji: emoji,
      inputType: inputType,
      durationMinutes: durationMinutes,
      distanceKm: distanceKm,
      caloriesBurned: calories,
      intensity: intensity,
      notes: notes,
      loggedAt: DateTime.now(), // Logged at current time
      userId: '1', // TODO: As per note, this is hardcoded
      source: 'favorite', // Indicate it came from a favorite
      activityMetValue: activityMetValue,
    );
  }

  FavoriteActivityModel withUpdatedUsage() {
    return copyWith(
      lastUsed: DateTime.now(),
      usageCount: usageCount + 1,
    );
  }

  String get displayText {
    String valueDisplay;
    if (inputType == ActivityInputType.duration) {
      valueDisplay = "${durationMinutes ?? 0} ${inputType.toDisplayString()}";
    } else {
      valueDisplay = "${distanceKm ?? 0} ${inputType.toDisplayString()}";
    }
    return "$emoji $activityName: $valueDisplay, $calories kcal (${intensity.toDisplayString()})";
  }
}

// Mock UserActivityLogModel for FavoriteActivityModel.fromUserActivityLog and .toUserActivityLog
class UserActivityLogModel {
  final String id;
  final String userId;
  final String activityId;
  final String activityName;
  final String? activityEmoji;
  final ActivityInputType inputType;
  final int? durationMinutes;
  final double? distanceKm;
  final int caloriesBurned;
  final ActivityIntensity intensity;
  final String? notes;
  final DateTime loggedAt;
  final String source; // e.g., 'manual', 'favorite', 'external'
  final double activityMetValue; // Added for consistency

  UserActivityLogModel({
    this.id = '',
    this.userId = '1', // Default or passed in
    required this.activityId,
    required this.activityName,
    this.activityEmoji,
    required this.inputType,
    this.durationMinutes,
    this.distanceKm,
    required this.caloriesBurned,
    this.intensity = ActivityIntensity.moderate,
    this.notes,
    DateTime? loggedAt,
    this.source = 'manual',
    this.activityMetValue = 0.0, // Added
  }) : this.loggedAt = loggedAt ?? DateTime.now();
}
