import 'package:flutter_test/flutter_test.dart';
import 'package:your_project_name/features/activity/infrastructure/activity_calorie_data.dart'; // Replace with your actual path

void main() {
  group('ActivityCalorieDatabase', () {
    // Assuming ActivityCalorieDatabase is a static class or a singleton accessed via static methods/instance.
    // For these tests, we'll assume static methods.

    group('getMetValue()', () {
      test('should return correct MET value for valid category and intensity', () {
        // Example: Running at high intensity
        expect(ActivityCalorieDatabase.getMetValue(ActivityCategory.loeb, ActivityIntensityLevel.hoej), 11.0);
        // Example: Weight training at medium intensity
        expect(ActivityCalorieDatabase.getMetValue(ActivityCategory.styrketraening, ActivityIntensityLevel.moderat), 4.5);
         // Example: Swimming at low intensity
        expect(ActivityCalorieDatabase.getMetValue(ActivityCategory.svoemning, ActivityIntensityLevel.lav), 7.0);
      });

      test('should use orElse for invalid/unmapped combinations', () {
        // Assuming 'andet' with 'lav' intensity is not specifically mapped and orElse provides a default MET
        final defaultMet = ActivityCalorieDatabase.getMetValue(ActivityCategory.andet, ActivityIntensityLevel.lav);
        // This depends on the actual orElse implementation in ActivityMetData.
        // For this test, let's assume orElse in the data returns a specific default like 1.0 or a category default.
        // We'll use a known unmapped combo if possible, or a generic one.
        // If ActivityCategory.andet and ActivityIntensityLevel.lav is unmapped, it might return from category default or overall default.
        // Let's assume ActivityCategory.andet has a default MET of 2.0 in its definition for orElse.
        expect(ActivityCalorieDatabase.getMetValue(ActivityCategory.andet, ActivityIntensityLevel.moderat, orElseMet: 1.5), 1.5);
        expect(ActivityCalorieDatabase.getMetValue(ActivityCategory.andet, ActivityIntensityLevel.hoej, orElseMet: 0), 0); // an unmapped combo
      });
    });

    group('getDescription()', () {
      test('should return correct description for valid category and intensity', () {
        expect(ActivityCalorieDatabase.getDescription(ActivityCategory.loeb, ActivityIntensityLevel.moderat), contains('Løb, moderat tempo'));
        expect(ActivityCalorieDatabase.getDescription(ActivityCategory.yoga, ActivityIntensityLevel.lav), contains('Yoga, Hatha'));
      });

      test('should use orElseDescription for invalid/unmapped combinations', () {
        expect(
          ActivityCalorieDatabase.getDescription(ActivityCategory.andet, ActivityIntensityLevel.hoej, orElseDescription: 'Ukendt aktivitet'),
          'Ukendt aktivitet',
        );
      });
    });

    group('getActivitiesForCategory()', () {
      test('should return all expected activities for a category', () {
        final cyclingActivities = ActivityCalorieDatabase.getActivitiesForCategory(ActivityCategory.cykling);
        expect(cyclingActivities.length, greaterThanOrEqualTo(2)); // Expecting at least low, moderate, high
        expect(cyclingActivities.any((data) => data.intensity == ActivityIntensityLevel.lav), isTrue);
        expect(cyclingActivities.any((data) => data.intensity == ActivityIntensityLevel.moderat), isTrue);
        expect(cyclingActivities.any((data) => data.intensity == ActivityIntensityLevel.hoej), isTrue);
      });

       test('should return specific entries for a category like styrketraening', () {
        final strengthActivities = ActivityCalorieDatabase.getActivitiesForCategory(ActivityCategory.styrketraening);
        // Assuming styrketraening might only have one generic entry or fewer specific intensities in the data
        expect(strengthActivities.length, greaterThanOrEqualTo(1));
        expect(strengthActivities.first.met, greaterThan(0));
      });
    });

    group('calculateCalories() (time-based)', () {
      // Formula: (MET * weight * durationHours).round()
      test('should calculate calories correctly for various inputs', () {
        // Loeb, hoej (MET 11.0), 70kg, 30 minutes (0.5 hours) => (11.0 * 70 * 0.5) = 385
        expect(ActivityCalorieDatabase.calculateCalories(ActivityCategory.loeb, ActivityIntensityLevel.hoej, 70, 30), 385);
        // Styrketraening, moderat (MET 4.5), 80kg, 60 minutes (1 hour) => (4.5 * 80 * 1.0) = 360
        expect(ActivityCalorieDatabase.calculateCalories(ActivityCategory.styrketraening, ActivityIntensityLevel.moderat, 80, 60), 360);
        // Dans, lav (MET 3.0), 60kg, 45 minutes (0.75 hours) => (3.0 * 60 * 0.75) = 135
        expect(ActivityCalorieDatabase.calculateCalories(ActivityCategory.dans, ActivityIntensityLevel.lav, 60, 45), 135);
      });

      test('should return 0 if duration is zero or negative', () {
        expect(ActivityCalorieDatabase.calculateCalories(ActivityCategory.loeb, ActivityIntensityLevel.hoej, 70, 0), 0);
        expect(ActivityCalorieDatabase.calculateCalories(ActivityCategory.loeb, ActivityIntensityLevel.hoej, 70, -10), 0);
      });
       test('should use orElseMet if combination not found', () {
        // (1.0 * 70 * 0.5) = 35
        expect(ActivityCalorieDatabase.calculateCalories(ActivityCategory.andet, ActivityIntensityLevel.megetHoej, 70, 30, orElseMet: 1.0), 35);
      });
    });

    group('calculateCaloriesFromDistance()', () {
      // Needs MET, weight, distanceKm, and speedKmh. Duration is (distanceKm / speedKmh).
      test('should calculate correctly with averageSpeedKmh provided', () {
        // Loeb, moderat (MET 9.0), 70kg, 5km, speed 10kmh. Duration = 5/10 = 0.5 hours.
        // Calories = (9.0 * 70 * 0.5) = 315
        expect(
          ActivityCalorieDatabase.calculateCaloriesFromDistance(
              ActivityCategory.loeb, ActivityIntensityLevel.moderat, 70, 5, averageSpeedKmh: 10),
          315);
      });

      test('should calculate correctly without averageSpeedKmh (uses getDefaultSpeed)', () {
        // Gang, moderat (MET 3.5), default speed for Gang/moderat is 5.0 km/h.
        // 60kg, 3km. Duration = 3km / 5kmh = 0.6 hours.
        // Calories = (3.5 * 60 * 0.6) = 126
        expect(
          ActivityCalorieDatabase.calculateCaloriesFromDistance(
              ActivityCategory.gang, ActivityIntensityLevel.moderat, 60, 3),
          126);

        // Cykling, hoej (MET 10.0), default speed for Cykling/hoej is 25 km/h.
        // 75kg, 20km. Duration = 20km / 25kmh = 0.8 hours
        // Calories = (10.0 * 75 * 0.8) = 600
        expect(
          ActivityCalorieDatabase.calculateCaloriesFromDistance(
              ActivityCategory.cykling, ActivityIntensityLevel.hoej, 75, 20),
          600);
      });

      test('should return 0 if distance or speed results in zero/invalid duration', () {
         expect(
          ActivityCalorieDatabase.calculateCaloriesFromDistance(
              ActivityCategory.loeb, ActivityIntensityLevel.moderat, 70, 0, averageSpeedKmh: 10),
          0);
         expect(
          ActivityCalorieDatabase.calculateCaloriesFromDistance(
              ActivityCategory.loeb, ActivityIntensityLevel.moderat, 70, 5, averageSpeedKmh: 0),
          0);
      });
    });

    group('getDefaultSpeed()', () {
      test('for Loeb (Running)', () {
        expect(ActivityCalorieDatabase.getDefaultSpeed(ActivityCategory.loeb, ActivityIntensityLevel.lav), 8.0); // Slower run
        expect(ActivityCalorieDatabase.getDefaultSpeed(ActivityCategory.loeb, ActivityIntensityLevel.moderat), 10.0); // Moderate run
        expect(ActivityCalorieDatabase.getDefaultSpeed(ActivityCategory.loeb, ActivityIntensityLevel.hoej), 12.0); // Faster run
      });
      test('for Gang (Walking)', () {
        expect(ActivityCalorieDatabase.getDefaultSpeed(ActivityCategory.gang, ActivityIntensityLevel.lav), 4.0);
        expect(ActivityCalorieDatabase.getDefaultSpeed(ActivityCategory.gang, ActivityIntensityLevel.moderat), 5.0);
        expect(ActivityCalorieDatabase.getDefaultSpeed(ActivityCategory.gang, ActivityIntensityLevel.hoej), 6.5);
      });
      test('for Cykling (Cycling)', () {
        expect(ActivityCalorieDatabase.getDefaultSpeed(ActivityCategory.cykling, ActivityIntensityLevel.lav), 15.0);
        expect(ActivityCalorieDatabase.getDefaultSpeed(ActivityCategory.cykling, ActivityIntensityLevel.moderat), 20.0);
        expect(ActivityCalorieDatabase.getDefaultSpeed(ActivityCategory.cykling, ActivityIntensityLevel.hoej), 25.0);
      });
      test('for a default category fallback', () {
        // Assuming categories not specifically listed fall back to a general speed or walking speed
        expect(ActivityCalorieDatabase.getDefaultSpeed(ActivityCategory.dans, ActivityIntensityLevel.moderat), 5.0); // Fallback to walking moderate
        expect(ActivityCalorieDatabase.getDefaultSpeed(ActivityCategory.andet, ActivityIntensityLevel.lav), 4.0); // Fallback to walking lav
      });
    });
  });
}


// --- Mock/Placeholder Definitions ---
// These would be replaced by actual imports from your project.

enum ActivityCategory {
  loeb, // Running
  gang, // Walking
  cykling, // Cycling
  svoemning, // Swimming
  styrketraening, // Strength training
  dans, // Dancing
  yoga,
  andet; // Other

  // Example helper for tests if needed
  bool get supportsDistance {
    return [loeb, gang, cykling, svoemning].contains(this);
  }
}

enum ActivityIntensityLevel {
  lav, // Low
  moderat, // Moderate
  hoej, // High
  megetHoej, // Very High (example for testing orElse)
}

class ActivityMetData {
  final ActivityCategory category;
  final ActivityIntensityLevel intensity;
  final double met;
  final String description;
  final double? defaultSpeedKmh; // Optional: only for distance-based activities

  ActivityMetData({
    required this.category,
    required this.intensity,
    required this.met,
    required this.description,
    this.defaultSpeedKmh,
  });
}

// Simplified static class for ActivityCalorieDatabase
class ActivityCalorieDatabase {
  static final List<ActivityMetData> _data = [
    // Loeb
    ActivityMetData(category: ActivityCategory.loeb, intensity: ActivityIntensityLevel.lav, met: 7.0, description: "Løb, langsomt tempo (<8 km/t)", defaultSpeedKmh: 8.0),
    ActivityMetData(category: ActivityCategory.loeb, intensity: ActivityIntensityLevel.moderat, met: 9.0, description: "Løb, moderat tempo (ca. 10 km/t)", defaultSpeedKmh: 10.0),
    ActivityMetData(category: ActivityCategory.loeb, intensity: ActivityIntensityLevel.hoej, met: 11.0, description: "Løb, hurtigt tempo (>12 km/t)", defaultSpeedKmh: 12.0),
    // Gang
    ActivityMetData(category: ActivityCategory.gang, intensity: ActivityIntensityLevel.lav, met: 2.5, description: "Gang, langsomt (<4 km/t)", defaultSpeedKmh: 4.0),
    ActivityMetData(category: ActivityCategory.gang, intensity: ActivityIntensityLevel.moderat, met: 3.5, description: "Gang, moderat (ca. 5 km/t)", defaultSpeedKmh: 5.0),
    ActivityMetData(category: ActivityCategory.gang, intensity: ActivityIntensityLevel.hoej, met: 5.0, description: "Gang, hurtigt (>6 km/t)", defaultSpeedKmh: 6.5),
    // Cykling
    ActivityMetData(category: ActivityCategory.cykling, intensity: ActivityIntensityLevel.lav, met: 6.0, description: "Cykling, roligt tempo (<15 km/t)", defaultSpeedKmh: 15.0),
    ActivityMetData(category: ActivityCategory.cykling, intensity: ActivityIntensityLevel.moderat, met: 8.0, description: "Cykling, moderat tempo (ca. 20 km/t)", defaultSpeedKmh: 20.0),
    ActivityMetData(category: ActivityCategory.cykling, intensity: ActivityIntensityLevel.hoej, met: 10.0, description: "Cykling, hurtigt tempo (>25 km/t)", defaultSpeedKmh: 25.0),
    // Styrketraening
    ActivityMetData(category: ActivityCategory.styrketraening, intensity: ActivityIntensityLevel.moderat, met: 4.5, description: "Styrketræning, generelt"), // Often one general value
    ActivityMetData(category: ActivityCategory.styrketraening, intensity: ActivityIntensityLevel.lav, met: 3.0, description: "Styrketræning, let"),
    ActivityMetData(category: ActivityCategory.styrketraening, intensity: ActivityIntensityLevel.hoej, met: 6.0, description: "Styrketræning, tungt"),
    // Dans
    ActivityMetData(category: ActivityCategory.dans, intensity: ActivityIntensityLevel.lav, met: 3.0, description: "Dans, lav intensitet (fx ballroom langsomt)"),
    ActivityMetData(category: ActivityCategory.dans, intensity: ActivityIntensityLevel.moderat, met: 5.0, description: "Dans, moderat intensitet (fx disco, step)"),
    ActivityMetData(category: ActivityCategory.dans, intensity: ActivityIntensityLevel.hoej, met: 7.0, description: "Dans, høj intensitet (fx zumba, ballet)"),
    // Yoga
    ActivityMetData(category: ActivityCategory.yoga, intensity: ActivityIntensityLevel.lav, met: 2.5, description: "Yoga, Hatha"),
    ActivityMetData(category: ActivityCategory.yoga, intensity: ActivityIntensityLevel.moderat, met: 4.0, description: "Yoga, Power"),
    // Svoemning
    ActivityMetData(category: ActivityCategory.svoemning, intensity: ActivityIntensityLevel.lav, met: 7.0, description: "Svømning, crawl langsomt", defaultSpeedKmh: 1.5), // Speed in km/h for swimming is slow
    ActivityMetData(category: ActivityCategory.svoemning, intensity: ActivityIntensityLevel.moderat, met: 8.5, description: "Svømning, crawl moderat", defaultSpeedKmh: 2.0),
    ActivityMetData(category: ActivityCategory.svoemning, intensity: ActivityIntensityLevel.hoej, met: 10.0, description: "Svømning, crawl hurtigt", defaultSpeedKmh: 2.5),

    // Fallback for 'andet' (Other) - can be a single entry or based on intensity
    ActivityMetData(category: ActivityCategory.andet, intensity: ActivityIntensityLevel.lav, met: 2.0, description: "Anden aktivitet, lav intensitet"),
  ];

  static ActivityMetData? _find(ActivityCategory category, ActivityIntensityLevel intensity) {
    try {
      return _data.firstWhere((d) => d.category == category && d.intensity == intensity);
    } catch (e) {
      // Try to find a generic entry for the category if intensity specific is not found
      try {
        return _data.firstWhere((d) => d.category == category && d.intensity == ActivityIntensityLevel.moderat); // Default to moderate
      } catch (e2) {
        return null;
      }
    }
  }

  static double getMetValue(ActivityCategory category, ActivityIntensityLevel intensity, {double orElseMet = 1.0}) {
    return _find(category, intensity)?.met ??
           _data.firstWhere((d) => d.category == category, orElse: () => ActivityMetData(category: category, intensity: intensity, met: orElseMet, description: "")).met;
  }

  static String getDescription(ActivityCategory category, ActivityIntensityLevel intensity, {String orElseDescription = "Ukendt aktivitet."}) {
     return _find(category, intensity)?.description ??
            _data.firstWhere((d) => d.category == category, orElse: () => ActivityMetData(category: category, intensity: intensity, met: 0, description: orElseDescription)).description;
  }

  static List<ActivityMetData> getActivitiesForCategory(ActivityCategory category) {
    return _data.where((d) => d.category == category).toList();
  }

  static int calculateCalories(ActivityCategory category, ActivityIntensityLevel intensity, double weightKg, int durationMinutes, {double? orElseMet}) {
    if (durationMinutes <= 0) return 0;
    final met = getMetValue(category, intensity, orElseMet: orElseMet ?? _getCategoryDefaultMet(category));
    final durationHours = durationMinutes / 60.0;
    return (met * weightKg * durationHours).round();
  }

  static double getDefaultSpeed(ActivityCategory category, ActivityIntensityLevel intensity) {
    // First, try to get specific speed
    final specificData = _find(category, intensity);
    if (specificData?.defaultSpeedKmh != null) {
      return specificData!.defaultSpeedKmh!;
    }
    // Fallback: if category is known for distance, but intensity is not, use moderate speed for that category
    if (category.supportsDistance) {
         final moderateDataForCategory = _find(category, ActivityIntensityLevel.moderat);
         if(moderateDataForCategory?.defaultSpeedKmh != null) return moderateDataForCategory!.defaultSpeedKmh!;
    }
    // Ultimate fallback: general moderate walking speed
    return 5.0;
  }

  static int calculateCaloriesFromDistance(ActivityCategory category, ActivityIntensityLevel intensity, double weightKg, double distanceKm, {double? averageSpeedKmh, double? orElseMet}) {
    if (distanceKm <= 0) return 0;
    final speed = averageSpeedKmh ?? getDefaultSpeed(category, intensity);
    if (speed <= 0) return 0;

    final durationHours = distanceKm / speed;
    if (durationHours <= 0) return 0;

    final met = getMetValue(category, intensity, orElseMet: orElseMet ?? _getCategoryDefaultMet(category));
    return (met * weightKg * durationHours).round();
  }

  static double _getCategoryDefaultMet(ActivityCategory category) {
    // Try to find a moderate MET for the category as a fallback
    try {
      return _data.firstWhere((d) => d.category == category && d.intensity == ActivityIntensityLevel.moderat).met;
    } catch (e) {
      // If no moderate MET, find any MET for the category
      try {
        return _data.firstWhere((d) => d.category == category).met;
      } catch (e2) {
        return 1.0; // Absolute fallback
      }
    }
  }
}
