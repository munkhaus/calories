import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_project_name/features/activity/infrastructure/activity_calorie_calculator.dart'; // Replace with your actual path
import 'package:your_project_name/features/activity/infrastructure/activity_calorie_data.dart'; // Assuming this is accessible

void main() {
  // Use the same placeholder enums as in activity_calorie_data_test.dart
  // If they were in the actual source, they would be imported.
  // For brevity, they are not repeated here but assumed to be available.

  group('ActivityCalorieCalculator', () {
    const String weightKey = 'user_weight_kg';
    const double defaultWeight = 70.0;
    late ActivityCalorieCalculator calculator;

    setUp(() {
      calculator = ActivityCalorieCalculator();
      // It's good practice to clear SharedPreferences mocks for each test
      // or ensure initial values are what you expect.
    });

    group('User Weight (SharedPreferences)', () {
      test('getUserWeight should return stored weight if available', () async {
        SharedPreferences.setMockInitialValues({weightKey: 75.5});
        final weight = await calculator.getUserWeight();
        expect(weight, 75.5);
      });

      test('getUserWeight should return default weight if none stored', () async {
        SharedPreferences.setMockInitialValues({}); // Empty prefs
        final weight = await calculator.getUserWeight();
        expect(weight, defaultWeight); // Assuming _defaultWeightKg is 70.0
      });

      test('setUserWeight should store the weight in SharedPreferences', () async {
        SharedPreferences.setMockInitialValues({});
        await calculator.setUserWeight(80.2);
        // Verify by reading it back or checking the mock values directly if possible
        // (SharedPreferences mock doesn't easily allow direct inspection of written values,
        // so reading back is a common pattern)
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getDouble(weightKey), 80.2);

        // Also check if getUserWeight now returns this new weight
        expect(await calculator.getUserWeight(), 80.2);
      });
    });

    group('calculateTimeBasedCalories()', () {
      test('should use provided userWeightKg and call ActivityCalorieDatabase', () async {
        // Example: Loeb, hoej (MET 11.0), 75kg, 30 mins
        // Expected: (11.0 * 75 * 0.5) = 412.5 -> 413
        final calories = await calculator.calculateTimeBasedCalories(
          ActivityCategory.loeb,
          ActivityIntensityLevel.hoej,
          30,
          userWeightKg: 75.0,
        );
        expect(calories, 413);
      });

      test('should use SharedPreferences weight if userWeightKg is null', () async {
        SharedPreferences.setMockInitialValues({weightKey: 65.0});
        // Example: Styrketraening, moderat (MET 4.5), 65kg, 60 mins
        // Expected: (4.5 * 65 * 1.0) = 292.5 -> 293
        final calories = await calculator.calculateTimeBasedCalories(
          ActivityCategory.styrketraening,
          ActivityIntensityLevel.moderat,
          60,
        );
        expect(calories, 293);
      });
    });

    group('calculateDistanceBasedCalories()', () {
      test('should use provided userWeightKg and call ActivityCalorieDatabase', () async {
        // Gang, hoej (MET 5.0), speed 6.5kmh, 80kg, 5km. Duration = 5/6.5 = ~0.769 hrs
        // Expected: (5.0 * 80 * (5/6.5)) = ~307.69 -> 308
        final calories = await calculator.calculateDistanceBasedCalories(
          ActivityCategory.gang,
          ActivityIntensityLevel.hoej,
          5, // distanceKm
          userWeightKg: 80.0,
          averageSpeedKmh: 6.5,
        );
        expect(calories, 308);
      });

      test('should use SharedPreferences weight if userWeightKg is null', () async {
        SharedPreferences.setMockInitialValues({weightKey: 72.0});
        // Cykling, moderat (MET 8.0), speed 20kmh, 72kg, 10km. Duration = 10/20 = 0.5 hrs
        // Expected: (8.0 * 72 * 0.5) = 288
        final calories = await calculator.calculateDistanceBasedCalories(
          ActivityCategory.cykling,
          ActivityIntensityLevel.moderat,
          10, // distanceKm
          // averageSpeedKmh will use default from ActivityCalorieDatabase
        );
        expect(calories, 288);
      });
    });

    group('calculateEstimatedDuration()', () {
      test('should calculate duration with provided averageSpeedKmh', () {
        // 10km / 12kmh = 0.8333... hours * 60 = 50 minutes
        final duration = calculator.calculateEstimatedDuration(ActivityCategory.loeb, ActivityIntensityLevel.hoej, 10, averageSpeedKmh: 12);
        expect(duration, 50);
      });

      test('should use default speed if averageSpeedKmh is null', () {
        // Gang, lav (default speed 4.0 kmh)
        // 2km / 4kmh = 0.5 hours * 60 = 30 minutes
        final duration = calculator.calculateEstimatedDuration(ActivityCategory.gang, ActivityIntensityLevel.lav, 2);
        expect(duration, 30);
      });
       test('should return 0 if distance or speed is zero', () {
        expect(calculator.calculateEstimatedDuration(ActivityCategory.loeb, ActivityIntensityLevel.hoej, 0, averageSpeedKmh: 10), 0);
        expect(calculator.calculateEstimatedDuration(ActivityCategory.loeb, ActivityIntensityLevel.hoej, 10, averageSpeedKmh: 0), 0);
      });
    });

    group('Database passthrough methods', () {
      test('getMetValue should call ActivityCalorieDatabase.getMetValue', () {
        expect(calculator.getMetValue(ActivityCategory.yoga, ActivityIntensityLevel.lav),
               ActivityCalorieDatabase.getMetValue(ActivityCategory.yoga, ActivityIntensityLevel.lav));
      });

      test('getActivityDescription should call ActivityCalorieDatabase.getDescription', () {
        expect(calculator.getActivityDescription(ActivityCategory.dans, ActivityIntensityLevel.moderat),
               ActivityCalorieDatabase.getDescription(ActivityCategory.dans, ActivityIntensityLevel.moderat));
      });
    });

    group('Metadata methods', () {
      test('getAllCategories should return all ActivityCategory.values', () {
        expect(calculator.getAllCategories(), ActivityCategory.values);
      });

      test('getAllIntensityLevels should return all ActivityIntensityLevel.values', () {
        expect(calculator.getAllIntensityLevels(), ActivityIntensityLevel.values);
      });

      test('supportsDistanceInput', () {
        expect(calculator.supportsDistanceInput(ActivityCategory.loeb), isTrue);
        expect(calculator.supportsDistanceInput(ActivityCategory.gang), isTrue);
        expect(calculator.supportsDistanceInput(ActivityCategory.cykling), isTrue);
        expect(calculator.supportsDistanceInput(ActivityCategory.svoemning), isTrue);
        expect(calculator.supportsDistanceInput(ActivityCategory.styrketraening), isFalse);
        expect(calculator.supportsDistanceInput(ActivityCategory.yoga), isFalse);
      });

      test('getSuggestedInputType', () {
        expect(calculator.getSuggestedInputType(ActivityCategory.loeb), ActivityInputType.distance);
        expect(calculator.getSuggestedInputType(ActivityCategory.styrketraening), ActivityInputType.time);
      });

      test('getDefaultUnit', () {
        expect(calculator.getDefaultUnit(ActivityCategory.loeb, ActivityIntensityLevel.moderat), 'km');
        expect(calculator.getDefaultUnit(ActivityCategory.svoemning, ActivityIntensityLevel.moderat), 'm'); // Special case
        expect(calculator.getDefaultUnit(ActivityCategory.styrketraening, ActivityIntensityLevel.moderat), 'min');
        expect(calculator.getDefaultUnit(ActivityCategory.yoga, ActivityIntensityLevel.lav), 'min');
      });
    });

    group('estimateCalories()', () {
      setUp(() {
         SharedPreferences.setMockInitialValues({weightKey: 70.0}); // Default weight for these tests
      });

      test('with distanceKm provided (uses distance-based)', async () {
        // Loeb, moderat (MET 9.0), default speed 10kmh. 70kg, 5km. Duration = 0.5hr. Cals = 9*70*0.5 = 315
        final estimate = await calculator.estimateCalories(
          ActivityCategory.loeb,
          ActivityIntensityLevel.moderat,
          distanceKm: 5,
        );
        expect(estimate.calories, 315);
        expect(estimate.durationMinutes, 30); // 5km / 10kmh = 0.5hr
        expect(estimate.distanceKm, 5);
      });

      test('with durationMinutes provided (uses time-based)', async () {
        // Dans, hoej (MET 7.0), 70kg, 45 mins (0.75hr). Cals = 7*70*0.75 = 367.5 -> 368
        final estimate = await calculator.estimateCalories(
          ActivityCategory.dans,
          ActivityIntensityLevel.hoej,
          durationMinutes: 45,
        );
        expect(estimate.calories, 368);
        expect(estimate.durationMinutes, 45);
        expect(estimate.distanceKm, isNull);
      });

      test('with neither distance nor duration (uses default duration)', async () {
        // Yoga, lav (MET 2.5), 70kg, default duration 30 mins (0.5hr). Cals = 2.5*70*0.5 = 87.5 -> 88
        final estimate = await calculator.estimateCalories(
          ActivityCategory.yoga,
          ActivityIntensityLevel.lav,
        );
        expect(estimate.calories, 88);
        expect(estimate.durationMinutes, ActivityCalorieCalculator.kDefaultDurationMinutes); // 30
        expect(estimate.distanceKm, isNull);
      });

      test('with userWeightKg provided, overriding SharedPreferences', async () {
        SharedPreferences.setMockInitialValues({weightKey: 100.0}); // This should be ignored
        // Loeb, hoej (MET 11.0), 60kg, 30 mins. Cals = 11*60*0.5 = 330
        final estimate = await calculator.estimateCalories(
          ActivityCategory.loeb,
          ActivityIntensityLevel.hoej,
          durationMinutes: 30,
          userWeightKg: 60.0,
        );
        expect(estimate.calories, 330);
      });
    });

    group('ActivityCalorieEstimate class', () {
      test('formattedEstimate with distance', () {
        final estimate = ActivityCalorieEstimate(
            calories: 315, durationMinutes: 30, distanceKm: 5.0, metValue: 9.0, userWeightKg: 70.0,
            category: ActivityCategory.loeb, intensity: ActivityIntensityLevel.moderat);
        expect(estimate.formattedEstimate, "~315 kcal (30 min / 5.0 km)");
      });

      test('formattedEstimate without distance', () {
        final estimate = ActivityCalorieEstimate(
            calories: 368, durationMinutes: 45, distanceKm: null, metValue: 7.0, userWeightKg: 70.0,
            category: ActivityCategory.dans, intensity: ActivityIntensityLevel.hoej);
        expect(estimate.formattedEstimate, "~368 kcal (45 min)");
      });

      test('detailedBreakdown', () {
         final estimate = ActivityCalorieEstimate(
            calories: 315, durationMinutes: 30, distanceKm: 5.0, metValue: 9.0, userWeightKg: 70.0,
            category: ActivityCategory.loeb, intensity: ActivityIntensityLevel.moderat, estimatedSpeedKmh: 10.0);
        final breakdown = estimate.detailedBreakdown;
        expect(breakdown, contains("MET: 9.0"));
        expect(breakdown, contains("Vægt: 70.0 kg"));
        expect(breakdown, contains("Varighed: 30 min"));
        expect(breakdown, contains("Distance: 5.0 km"));
        expect(breakdown, contains("Hastighed: 10.0 km/t"));
      });
       test('detailedBreakdown without distance/speed', () {
         final estimate = ActivityCalorieEstimate(
            calories: 88, durationMinutes: 30, distanceKm: null, metValue: 2.5, userWeightKg: 70.0,
            category: ActivityCategory.yoga, intensity: ActivityIntensityLevel.lav);
        final breakdown = estimate.detailedBreakdown;
        expect(breakdown, contains("MET: 2.5"));
        expect(breakdown, contains("Vægt: 70.0 kg"));
        expect(breakdown, contains("Varighed: 30 min"));
        expect(breakdown, isNot(contains("Distance:")));
        expect(breakdown, isNot(contains("Hastighed:")));
      });
    });
  });
}

// --- Mock/Placeholder Definitions from activity_calorie_data.dart (Assumed available) ---
// enum ActivityCategory { loeb, gang, cykling, svoemning, styrketraening, dans, yoga, andet }
// enum ActivityIntensityLevel { lav, moderat, hoej }
// class ActivityCalorieDatabase { /* ... static methods ... */ }
// These are defined in the previous file's output. In a real project, they'd be imported.

// Placeholder for ActivityInputType if needed by ActivityCalorieCalculator's interface
enum ActivityInputType { time, distance }

// Placeholder for ActivityCalorieCalculator (actual implementation would be in the source)
// This is a simplified version for testing purposes.
class ActivityCalorieCalculator {
  static const String kUserWeightKey = 'user_weight_kg';
  static const double _defaultWeightKg = 70.0;
  static const int kDefaultDurationMinutes = 30;

  Future<double> getUserWeight() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(kUserWeightKey) ?? _defaultWeightKg;
  }

  Future<void> setUserWeight(double weightKg) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(kUserWeightKey, weightKg);
  }

  Future<int> calculateTimeBasedCalories(
    ActivityCategory category,
    ActivityIntensityLevel intensity,
    int durationMinutes, {
    double? userWeightKg,
  }) async {
    final weight = userWeightKg ?? await getUserWeight();
    return ActivityCalorieDatabase.calculateCalories(category, intensity, weight, durationMinutes);
  }

  Future<int> calculateDistanceBasedCalories(
    ActivityCategory category,
    ActivityIntensityLevel intensity,
    double distanceKm, {
    double? userWeightKg,
    double? averageSpeedKmh,
  }) async {
    final weight = userWeightKg ?? await getUserWeight();
    return ActivityCalorieDatabase.calculateCaloriesFromDistance(category, intensity, weight, distanceKm, averageSpeedKmh: averageSpeedKmh);
  }

  int calculateEstimatedDuration(
    ActivityCategory category,
    ActivityIntensityLevel intensity,
    double distanceKm, {
    double? averageSpeedKmh,
  }) {
    if (distanceKm <= 0) return 0;
    final speed = averageSpeedKmh ?? ActivityCalorieDatabase.getDefaultSpeed(category, intensity);
    if (speed <= 0) return 0;
    return ((distanceKm / speed) * 60).round();
  }

  double getMetValue(ActivityCategory category, ActivityIntensityLevel intensity, {double orElseMet = 1.0}) {
    return ActivityCalorieDatabase.getMetValue(category, intensity, orElseMet: orElseMet);
  }

  String getActivityDescription(ActivityCategory category, ActivityIntensityLevel intensity, {String orElseDescription = "Ukendt aktivitet."}) {
    return ActivityCalorieDatabase.getDescription(category, intensity, orElseDescription: orElseDescription);
  }

  List<ActivityCategory> getAllCategories() => ActivityCategory.values;
  List<ActivityIntensityLevel> getAllIntensityLevels() => ActivityIntensityLevel.values;

  bool supportsDistanceInput(ActivityCategory category) {
    return category.supportsDistance; // Assumes extension method on ActivityCategory
  }

  ActivityInputType getSuggestedInputType(ActivityCategory category) {
    return supportsDistanceInput(category) ? ActivityInputType.distance : ActivityInputType.time;
  }

  String getDefaultUnit(ActivityCategory category, ActivityIntensityLevel intensity) {
    if (category == ActivityCategory.svoemning) return 'm'; // Specific for swimming
    return supportsDistanceInput(category) ? 'km' : 'min';
  }

  Future<ActivityCalorieEstimate> estimateCalories(
    ActivityCategory category,
    ActivityIntensityLevel intensity, {
    double? distanceKm,
    int? durationMinutes,
    double? userWeightKg,
    double? averageSpeedKmh,
  }) async {
    final weight = userWeightKg ?? await getUserWeight();
    int calculatedCalories;
    int finalDurationMinutes;
    double? finalDistanceKm = distanceKm;
    double? finalSpeedKmh = averageSpeedKmh;

    if (finalDistanceKm != null && finalDistanceKm > 0 && supportsDistanceInput(category)) {
      finalSpeedKmh ??= ActivityCalorieDatabase.getDefaultSpeed(category, intensity);
      if (finalSpeedKmh > 0) {
        finalDurationMinutes = ((finalDistanceKm / finalSpeedKmh) * 60).round();
      } else {
        finalDurationMinutes = 0; // Cannot calculate duration if speed is 0
      }
      calculatedCalories = ActivityCalorieDatabase.calculateCaloriesFromDistance(category, intensity, weight, finalDistanceKm, averageSpeedKmh: finalSpeedKmh);
    } else {
      finalDurationMinutes = durationMinutes ?? kDefaultDurationMinutes;
      calculatedCalories = ActivityCalorieDatabase.calculateCalories(category, intensity, weight, finalDurationMinutes);
    }

    final met = getMetValue(category, intensity);

    return ActivityCalorieEstimate(
      calories: calculatedCalories,
      durationMinutes: finalDurationMinutes,
      distanceKm: finalDistanceKm,
      metValue: met,
      userWeightKg: weight,
      category: category,
      intensity: intensity,
      estimatedSpeedKmh: finalSpeedKmh
    );
  }
}

class ActivityCalorieEstimate {
  final int calories;
  final int durationMinutes;
  final double? distanceKm;
  final double metValue;
  final double userWeightKg;
  final ActivityCategory category;
  final ActivityIntensityLevel intensity;
  final double? estimatedSpeedKmh;


  ActivityCalorieEstimate({
    required this.calories,
    required this.durationMinutes,
    this.distanceKm,
    required this.metValue,
    required this.userWeightKg,
    required this.category,
    required this.intensity,
    this.estimatedSpeedKmh,
  });

  String get formattedEstimate {
    if (distanceKm != null && distanceKm! > 0) {
      return "~$calories kcal ($durationMinutes min / ${distanceKm!.toStringAsFixed(1)} km)";
    }
    return "~$calories kcal ($durationMinutes min)";
  }

  String get detailedBreakdown {
    String breakdown = "MET: $metValue\nVægt: $userWeightKg kg\nVarighed: $durationMinutes min";
    if (distanceKm != null && distanceKm! > 0) {
      breakdown += "\nDistance: ${distanceKm!.toStringAsFixed(1)} km";
    }
    if (estimatedSpeedKmh != null && estimatedSpeedKmh! > 0) {
      breakdown += "\nHastighed: ${estimatedSpeedKmh!.toStringAsFixed(1)} km/t";
    }
    return breakdown;
  }
}
