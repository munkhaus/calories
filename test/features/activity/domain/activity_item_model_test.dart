import 'package:flutter_test/flutter_test.dart';
import 'package:your_project_name/features/activity/domain/activity_item_model.dart'; // Replace with your actual path
// Assuming METValue is a type alias or a simple double
// typedef METValue = double;

void main() {
  group('ActivityItemModel', () {
    const mockJson = {
      'id': '123',
      'name': 'Running',
      'met_value': 8.0,
      'emoji': '🏃',
      'supports_duration': 1,
      'supports_distance': 0,
      'met_formula_type': 'duration_based',
      'parent_id': 'group1',
      'sort_order': 1,
    };

    final mockModel = ActivityItemModel(
      id: '123',
      name: 'Running',
      metValue: 8.0,
      emoji: '🏃',
      supportsDuration: true,
      supportsDistance: false,
      metFormulaType: METFormulaType.durationBased,
      parentId: 'group1',
      sortOrder: 1,
    );

    group('fromJson factory', () {
      test('should correctly parse valid JSON', () {
        final model = ActivityItemModel.fromJson(mockJson);
        expect(model.id, mockModel.id);
        expect(model.name, mockModel.name);
        expect(model.metValue, mockModel.metValue);
        expect(model.emoji, mockModel.emoji);
        expect(model.supportsDuration, mockModel.supportsDuration);
        expect(model.supportsDistance, mockModel.supportsDistance);
        expect(model.metFormulaType, mockModel.metFormulaType);
        expect(model.parentId, mockModel.parentId);
        expect(model.sortOrder, mockModel.sortOrder);
      });

      test('should handle missing/null values with defaults', () {
        final jsonWithMissing = {
          'id': '456',
          'name': 'Walking',
          // met_value, emoji, supports_duration, etc. are missing
        };
        final model = ActivityItemModel.fromJson(jsonWithMissing);
        expect(model.id, '456');
        expect(model.name, 'Walking');
        expect(model.metValue, 0.0); // Assuming default
        expect(model.emoji, ''); // Assuming default
        expect(model.supportsDuration, true); // Assuming default
        expect(model.supportsDistance, false); // Assuming default
        expect(model.metFormulaType, METFormulaType.unknown); // Assuming default
        expect(model.parentId, isNull); // Assuming default
        expect(model.sortOrder, 0); // Assuming default
      });

      test('should correctly convert boolean from 1/0', () {
        final model1 = ActivityItemModel.fromJson({'supports_duration': 1, 'supports_distance': 0});
        expect(model1.supportsDuration, isTrue);
        expect(model1.supportsDistance, isFalse);

        final model2 = ActivityItemModel.fromJson({'supports_duration': 0, 'supports_distance': 1});
        expect(model2.supportsDuration, isFalse);
        expect(model2.supportsDistance, isTrue);
      });

       test('should correctly parse METFormulaType from string', () {
        expect(ActivityItemModel.fromJson({'met_formula_type': 'duration_based'}).metFormulaType, METFormulaType.durationBased);
        expect(ActivityItemModel.fromJson({'met_formula_type': 'distance_based'}).metFormulaType, METFormulaType.distanceBased);
        expect(ActivityItemModel.fromJson({'met_formula_type': 'other'}).metFormulaType, METFormulaType.unknown); // or specific 'other'
        expect(ActivityItemModel.fromJson({'met_formula_type': null}).metFormulaType, METFormulaType.unknown);
      });
    });

    group('toJson method', () {
      test('should correctly serialize a complete model', () {
        final json = mockModel.toJson();
        expect(json['id'], mockModel.id);
        expect(json['name'], mockModel.name);
        expect(json['met_value'], mockModel.metValue);
        expect(json['emoji'], mockModel.emoji);
        expect(json['supports_duration'], 1);
        expect(json['supports_distance'], 0);
        expect(json['met_formula_type'], 'duration_based');
        expect(json['parent_id'], mockModel.parentId);
        expect(json['sort_order'], mockModel.sortOrder);
      });

      test('should convert boolean to 1/0', () {
        final model1 = ActivityItemModel(supportsDuration: true, supportsDistance: false);
        final json1 = model1.toJson();
        expect(json1['supports_duration'], 1);
        expect(json1['supports_distance'], 0);

        final model2 = ActivityItemModel(supportsDuration: false, supportsDistance: true);
        final json2 = model2.toJson();
        expect(json2['supports_duration'], 0);
        expect(json2['supports_distance'], 1);
      });
    });

    group('ActivityCalculations extension', () {
      final activity = ActivityItemModel(name: 'Test Activity', metValue: 5.0); // MET value for duration
      final distanceActivity = ActivityItemModel(name: 'Test Distance Activity', metValue: 1.0); // MET value for distance (e.g. METs per km/h)

      group('calculateCaloriesForDuration', () {
        test('should calculate calories correctly for duration', () {
          // Formula: METs * weightKg * (minutes / 60)
          // Example: 5.0 * 70kg * (30 / 60) = 5.0 * 70 * 0.5 = 175
          expect(activity.calculateCaloriesForDuration(minutes: 30, userWeightKg: 70), closeTo(175.0, 0.1));
          expect(activity.calculateCaloriesForDuration(minutes: 60, userWeightKg: 70), closeTo(350.0, 0.1));
        });

        test('should return 0 for zero minutes or zero weight (duration)', () {
          expect(activity.calculateCaloriesForDuration(minutes: 0, userWeightKg: 70), 0);
          expect(activity.calculateCaloriesForDuration(minutes: 30, userWeightKg: 0), 0);
        });

        test('should handle rounding correctly (duration)', () {
          // 5.0 * 65.5kg * (33 / 60) = 5.0 * 65.5 * 0.55 = 180.125
          expect(activity.calculateCaloriesForDuration(minutes: 33, userWeightKg: 65.5), 180); // Assuming round to nearest int
        });
      });

      group('calculateCaloriesForDistance', () {
         // This formula is highly dependent on the specific model of METs for distance.
         // A common simplified one for running: Cals = km * weightKg
         // For cycling: Cals = km * weightKg * factor (e.g. 0.05 for moderate pace)
         // We'll assume a simple model: METs * weightKg * km (where METs is a factor per km)
        test('should calculate calories correctly for distance', () {
          // Example: 1.0 (MET factor) * 70kg * 5km = 350
          expect(distanceActivity.calculateCaloriesForDistance(km: 5, userWeightKg: 70), closeTo(350.0, 0.1));
          expect(distanceActivity.calculateCaloriesForDistance(km: 10, userWeightKg: 70), closeTo(700.0, 0.1));
        });

        test('should return 0 for zero km or zero weight (distance)', () {
          expect(distanceActivity.calculateCaloriesForDistance(km: 0, userWeightKg: 70), 0);
          expect(distanceActivity.calculateCaloriesForDistance(km: 5, userWeightKg: 0), 0);
        });

        test('should handle rounding correctly (distance)', () {
          // 1.0 * 65.5kg * 5.5km = 360.25
          expect(distanceActivity.calculateCaloriesForDistance(km: 5.5, userWeightKg: 65.5), 360); // Assuming round
        });
      });

      group('calculateCalories general method', () {
        final durationBasedActivity = ActivityItemModel(
          name: 'Duration Activity',
          metValue: 6.0,
          supportsDuration: true,
          supportsDistance: false,
          metFormulaType: METFormulaType.durationBased,
        );
        final distanceBasedActivity = ActivityItemModel(
          name: 'Distance Activity',
          metValue: 1.1, // Factor for distance based
          supportsDuration: false,
          supportsDistance: true,
          metFormulaType: METFormulaType.distanceBased,
        );

        test('should call calculateCaloriesForDuration when isDuration is true', () {
          // 6.0 * 70kg * (30/60) = 210
          final calories = durationBasedActivity.calculateCalories(
            inputValue: 30, // minutes
            userWeightKg: 70,
            isDuration: true,
          );
          expect(calories, closeTo(210.0, 0.1));
        });

        test('should call calculateCaloriesForDistance when isDuration is false', () {
          // 1.1 * 70kg * 5km = 385
          final calories = distanceBasedActivity.calculateCalories(
            inputValue: 5, // km
            userWeightKg: 70,
            isDuration: false,
          );
          expect(calories, closeTo(385.0, 0.1));
        });

        test('should use metFormulaType if isDuration is null (durationBased)', () {
          final calories = durationBasedActivity.calculateCalories(
            inputValue: 30, userWeightKg: 70
          );
          expect(calories, closeTo(210.0, 0.1));
        });

        test('should use metFormulaType if isDuration is null (distanceBased)', () {
          final calories = distanceBasedActivity.calculateCalories(
            inputValue: 5, userWeightKg: 70
          );
          expect(calories, closeTo(385.0, 0.1));
        });

         test('should return 0 if metFormulaType is unknown and isDuration is null', () {
          final unknownActivity = ActivityItemModel(metFormulaType: METFormulaType.unknown);
          final calories = unknownActivity.calculateCalories(inputValue: 10, userWeightKg: 70);
          expect(calories, 0);
        });
      });
    });
  });
}

// --- Mock/Placeholder definitions for ActivityItemModel and METFormulaType ---
// Replace these with your actual model imports

enum METFormulaType {
  durationBased,
  distanceBased,
  unknown;

  static METFormulaType fromString(String? type) {
    switch (type) {
      case 'duration_based':
        return METFormulaType.durationBased;
      case 'distance_based':
        return METFormulaType.distanceBased;
      default:
        return METFormulaType.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case METFormulaType.durationBased:
        return 'duration_based';
      case METFormulaType.distanceBased:
        return 'distance_based';
      default:
        return 'unknown';
    }
  }
}

class ActivityItemModel {
  final String id;
  final String name;
  final double metValue; // Can be METs for duration, or a factor for distance
  final String emoji;
  final bool supportsDuration;
  final bool supportsDistance;
  final METFormulaType metFormulaType;
  final String? parentId;
  final int sortOrder;

  ActivityItemModel({
    this.id = '',
    this.name = '',
    this.metValue = 0.0,
    this.emoji = '',
    this.supportsDuration = true,
    this.supportsDistance = false,
    this.metFormulaType = METFormulaType.unknown,
    this.parentId,
    this.sortOrder = 0,
  });

  factory ActivityItemModel.fromJson(Map<String, dynamic> json) {
    return ActivityItemModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      metValue: (json['met_value'] as num?)?.toDouble() ?? 0.0,
      emoji: json['emoji'] as String? ?? '',
      supportsDuration: json['supports_duration'] == 1 || json['supports_duration'] == true,
      supportsDistance: json['supports_distance'] == 1 || json['supports_distance'] == true,
      metFormulaType: METFormulaType.fromString(json['met_formula_type'] as String?),
      parentId: json['parent_id'] as String?,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'met_value': metValue,
      'emoji': emoji,
      'supports_duration': supportsDuration ? 1 : 0,
      'supports_distance': supportsDistance ? 1 : 0,
      'met_formula_type': metFormulaType.toJson(),
      'parent_id': parentId,
      'sort_order': sortOrder,
    };
  }
}

extension ActivityCalculations on ActivityItemModel {
  int calculateCaloriesForDuration({required double minutes, required double userWeightKg}) {
    if (minutes <= 0 || userWeightKg <= 0) return 0;
    // Standard MET formula: METs * bodyWeightKg * (durationMinutes / 60)
    double calories = metValue * userWeightKg * (minutes / 60.0);
    return calories.round();
  }

  int calculateCaloriesForDistance({required double km, required double userWeightKg}) {
    if (km <= 0 || userWeightKg <= 0) return 0;
    // This is a placeholder formula. Real formulas are more complex.
    // Example: metValue is a factor like "calories burned per km per kg"
    // Or, it might be METs at a certain speed, and you'd need to calculate duration from distance.
    // For this example, let's assume metValue is a simple factor: factor * weight * km
    double calories = metValue * userWeightKg * km;
    return calories.round();
  }

  int calculateCalories({
    required double inputValue, // minutes if isDuration, km if !isDuration
    required double userWeightKg,
    bool? isDuration, // If null, infer from metFormulaType
  }) {
    bool useDuration;
    if (isDuration != null) {
      useDuration = isDuration;
    } else {
      if (metFormulaType == METFormulaType.durationBased) {
        useDuration = true;
      } else if (metFormulaType == METFormulaType.distanceBased) {
        useDuration = false;
      } else {
        return 0; // Cannot determine calculation type
      }
    }

    if (useDuration) {
      return calculateCaloriesForDuration(minutes: inputValue, userWeightKg: userWeightKg);
    } else {
      return calculateCaloriesForDistance(km: inputValue, userWeightKg: userWeightKg);
    }
  }
}
