import 'package:flutter_test/flutter_test.dart';
import 'package:calories/features/onboarding/domain/user_profile_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // Helper to create a UserProfileModel with common defaults for tests
  UserProfileModel createProfile({
    String id = '1',
    String email = 'test@example.com',
    String name = 'Test User',
    DateTime? dateOfBirth,
    Gender? gender,
    double heightCm = 170,
    double currentWeightKg = 70,
    GoalType? goalType = GoalType.weightMaintenance,
    double targetWeightKg = 70,
    bool isOnboardingCompleted = true,
    ActivityLevel? activityLevel, // Legacy
    WorkActivityLevel? workActivityLevel,
    LeisureActivityLevel? leisureActivityLevel,
    ActivityTrackingPreference activityTrackingPreference = ActivityTrackingPreference.automatic,
    bool useAutomaticWeekdayDetection = true,
    bool isCurrentlyWorkDay = false, // Manual override for today
    bool isLeisureActivityEnabledToday = true, // Manual toggle for leisure activity today
  }) {
    return UserProfileModel(
      id: id,
      email: email,
      name: name,
      dateOfBirth: dateOfBirth,
      gender: gender,
      heightCm: heightCm,
      currentWeightKg: currentWeightKg,
      goalType: goalType,
      targetWeightKg: targetWeightKg,
      isOnboardingCompleted: isOnboardingCompleted,
      activityLevel: activityLevel,
      workActivityLevel: workActivityLevel,
      leisureActivityLevel: leisureActivityLevel,
      activityTrackingPreference: activityTrackingPreference,
      useAutomaticWeekdayDetection: useAutomaticWeekdayDetection,
      isCurrentlyWorkDay: isCurrentlyWorkDay,
      isLeisureActivityEnabledToday: isLeisureActivityEnabledToday,
    );
  }

  // Fixed date for consistent age calculation in tests
  final now = DateTime.now();
  final preciseDateOfBirthThirtyYearsAgo = DateTime(now.year - 30, now.month, now.day);
  // Base BMR for male, 30y, 180cm, 75kg is 1730 kcal. Used in TDEE tests.
  const double baseBmrForTdeeTests = 1730;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  group('UserProfileModel Calculations', () {
    group('Age Calculation', () {
      test('should calculate age correctly for a past birth date', () {
        final profile = createProfile(dateOfBirth: DateTime(1990, 5, 15));
        expect(profile.age, greaterThan(30));
      });

      test('should be 0 if dateOfBirth is null', () {
        final profile = createProfile(dateOfBirth: null);
        expect(profile.age, 0);
      });

      test('should be 0 if dateOfBirth is in the future', () {
        final profile =
            createProfile(dateOfBirth: DateTime.now().add(const Duration(days: 1)));
        expect(profile.age, 0);
      });

      test('should calculate age correctly if birthday is today', () {
        final profile = createProfile(dateOfBirth: preciseDateOfBirthThirtyYearsAgo);
        expect(profile.age, 30);
      });

      test('should calculate age correctly if birthday was yesterday', () {
        final yesterday = now.subtract(const Duration(days: 1));
        final profile = createProfile(dateOfBirth: DateTime(yesterday.year - 30, yesterday.month, yesterday.day));
        expect(profile.age, 30);
      });

      test('should calculate age correctly if birthday is tomorrow', () {
        final tomorrow = now.add(const Duration(days: 1));
        final profile = createProfile(dateOfBirth: DateTime(tomorrow.year - 30, tomorrow.month, tomorrow.day));
        expect(profile.age, 29);
      });
    });

    group('BMR Calculation (Mifflin-St Jeor)', () {
      test('should calculate BMR correctly for male', () {
        final profile = createProfile(
          dateOfBirth: preciseDateOfBirthThirtyYearsAgo,
          gender: Gender.male,
          heightCm: 180,
          currentWeightKg: 75,
        );
        expect(profile.bmr, closeTo(baseBmrForTdeeTests, 0.1)); // 1730
      });

      test('should calculate BMR correctly for female', () {
        final profile = createProfile(
          dateOfBirth: preciseDateOfBirthThirtyYearsAgo,
          gender: Gender.female,
          heightCm: 165,
          currentWeightKg: 60,
        );
        expect(profile.bmr, closeTo(1320.25, 0.1));
      });

      test('should be 0 if dateOfBirth is null', () {
        final profile = createProfile(dateOfBirth: null, gender: Gender.male);
        expect(profile.bmr, 0);
      });

      test('should be 0 if gender is null', () {
        final profile = createProfile(dateOfBirth: preciseDateOfBirthThirtyYearsAgo, gender: null);
        expect(profile.bmr, 0);
      });

      test('should be 0 if heightCm is 0', () {
        final profile = createProfile(
            dateOfBirth: preciseDateOfBirthThirtyYearsAgo,
            gender: Gender.male,
            heightCm: 0);
        expect(profile.bmr, 0);
      });

      test('should be 0 if currentWeightKg is 0', () {
        final profile = createProfile(
            dateOfBirth: preciseDateOfBirthThirtyYearsAgo,
            gender: Gender.male,
            currentWeightKg: 0);
        expect(profile.bmr, 0);
      });

      test('should be 0 if age is 0 (e.g., future birth date)', () {
        final profile = createProfile(
          dateOfBirth: DateTime.now().add(const Duration(days: 365)),
          gender: Gender.male,
          heightCm: 180,
          currentWeightKg: 75,
        );
        expect(profile.bmr, 0);
      });

      test('should be clamped to a minimum of 800', () {
        final profile = createProfile(
          dateOfBirth: DateTime(now.year - 80, now.month, now.day),
          gender: Gender.female,
          heightCm: 150,
          currentWeightKg: 30,
        );
        expect(profile.bmr, 800);
      });

       test('should be clamped to a maximum of 3000', () {
         final profile = createProfile(
          dateOfBirth: DateTime(now.year - 18, now.month, now.day),
          gender: Gender.male,
          heightCm: 250,
          currentWeightKg: 200,
        );
        expect(profile.bmr, 3000);
      });
    });

    group('isCompleteForCalculations', () {
      test('should be true if all required fields are present and onboarding is complete', () {
        final profile = createProfile(
          dateOfBirth: preciseDateOfBirthThirtyYearsAgo,
          gender: Gender.male,
          heightCm: 180,
          currentWeightKg: 75,
          goalType: GoalType.weightLoss,
          targetWeightKg: 70,
          isOnboardingCompleted: true,
        );
        expect(profile.isCompleteForCalculations, isTrue);
      });

      test('should be false if dateOfBirth is null', () {
        final profile = createProfile(dateOfBirth: null, gender: Gender.male, heightCm: 180, currentWeightKg: 75, goalType: GoalType.weightLoss, targetWeightKg: 70);
        expect(profile.isCompleteForCalculations, isFalse);
      });

      // Add other checks for isCompleteForCalculations (gender, height, weight, goalType, targetWeight, isOnboardingCompleted)
       test('should be false if gender is null', () {
        final profile = createProfile(gender: null, dateOfBirth: preciseDateOfBirthThirtyYearsAgo, heightCm: 180, currentWeightKg: 75, goalType: GoalType.weightLoss, targetWeightKg: 70);
        expect(profile.isCompleteForCalculations, isFalse);
      });

      test('should be false if heightCm is 0', () {
        final profile = createProfile(heightCm: 0, dateOfBirth: preciseDateOfBirthThirtyYearsAgo, gender: Gender.male, currentWeightKg: 75, goalType: GoalType.weightLoss, targetWeightKg: 70);
        expect(profile.isCompleteForCalculations, isFalse);
      });

      test('should be false if currentWeightKg is 0', () {
        final profile = createProfile(currentWeightKg: 0, dateOfBirth: preciseDateOfBirthThirtyYearsAgo, gender: Gender.male, heightCm: 180, goalType: GoalType.weightLoss, targetWeightKg: 70);
        expect(profile.isCompleteForCalculations, isFalse);
      });

      test('should be false if goalType is null', () {
        final profile = createProfile(goalType: null, dateOfBirth: preciseDateOfBirthThirtyYearsAgo, gender: Gender.male, heightCm: 180, currentWeightKg: 75, targetWeightKg: 70);
        expect(profile.isCompleteForCalculations, isFalse);
      });

      test('should be false if targetWeightKg is 0', () {
        final profile = createProfile(targetWeightKg: 0, dateOfBirth: preciseDateOfBirthThirtyYearsAgo, gender: Gender.male, heightCm: 180, currentWeightKg: 75, goalType: GoalType.weightLoss);
        expect(profile.isCompleteForCalculations, isFalse);
      });

      test('should be false if isOnboardingCompleted is false', () {
        final profile = createProfile(
          isOnboardingCompleted: false,
          dateOfBirth: preciseDateOfBirthThirtyYearsAgo,
          gender: Gender.male,
          heightCm: 180,
          currentWeightKg: 75,
          goalType: GoalType.weightLoss,
          targetWeightKg: 70,
        );
        expect(profile.isCompleteForCalculations, isFalse);
      });
    });

    group('TDEE Calculation (Legacy)', () {
      UserProfileModel createLegacyTdeeProfile(ActivityLevel? activityLevel, {bool complete = true}) {
        return createProfile(
          dateOfBirth: preciseDateOfBirthThirtyYearsAgo,
          gender: Gender.male,
          heightCm: 180,
          currentWeightKg: 75,
          goalType: GoalType.weightMaintenance,
          targetWeightKg: 75,
          isOnboardingCompleted: complete,
          activityLevel: activityLevel,
          workActivityLevel: null,
          leisureActivityLevel: null,
        );
      }

      test('should be 0 if isCompleteForCalculations is false', () {
        final profile = createLegacyTdeeProfile(ActivityLevel.sedentary, complete: false);
        expect(profile.tdee, 0);
      });

      test('should use sedentary multiplier (1.2) if activityLevel is null and profile is complete', () {
        final profile = createLegacyTdeeProfile(null);
        expect(profile.tdee, closeTo(baseBmrForTdeeTests * 1.2, 0.1));
      });

      test('should calculate TDEE for sedentary (1.2)', () {
        final profile = createLegacyTdeeProfile(ActivityLevel.sedentary);
        expect(profile.tdee, closeTo(baseBmrForTdeeTests * 1.2, 0.1));
      });

      test('should calculate TDEE for lightlyActive (1.375)', () {
        final profile = createLegacyTdeeProfile(ActivityLevel.lightlyActive);
        expect(profile.tdee, closeTo(baseBmrForTdeeTests * 1.375, 0.1));
      });

      test('should calculate TDEE for moderatelyActive (1.55)', () {
        final profile = createLegacyTdeeProfile(ActivityLevel.moderatelyActive);
        expect(profile.tdee, closeTo(baseBmrForTdeeTests * 1.55, 0.1));
      });

      test('should calculate TDEE for veryActive (1.725)', () {
        final profile = createLegacyTdeeProfile(ActivityLevel.veryActive);
        expect(profile.tdee, closeTo(baseBmrForTdeeTests * 1.725, 0.1));
      });

      test('should calculate TDEE for extraActive (1.9)', () {
        final profile = createLegacyTdeeProfile(ActivityLevel.extraActive);
        expect(profile.tdee, closeTo(baseBmrForTdeeTests * 1.9, 0.1));
      });
    });

    group('TDEE Calculation (New System)', () {
      UserProfileModel createNewSystemTdeeProfile({
        WorkActivityLevel work = WorkActivityLevel.sedentary,
        LeisureActivityLevel leisure = LeisureActivityLevel.sedentary,
        ActivityTrackingPreference trackingPreference = ActivityTrackingPreference.automatic,
        bool useAutoWeekday = true,
        bool currentWorkDay = false, // Effective if useAutoWeekday = false
        bool leisureEnabledToday = true,
        bool complete = true,
        required DateTime currentTestDate, // To control workday detection
      }) {
        // Mock DateTime.now() by creating a profile with a specific dateOfBirth
        // such that 'age' is 30 relative to currentTestDate.
        // And then, the _getIsWorkDay internal to TDEE will use the *actual* DateTime.now().
        // This is tricky. For _getIsWorkDay to be testable, it needs to be injectable or
        // we test on specific days of the week.
        // For these tests, we'll rely on setting useAutomaticWeekdayDetection = false
        // and isCurrentlyWorkDay to control the work day status deterministically.

        return createProfile(
          dateOfBirth: DateTime(currentTestDate.year - 30, currentTestDate.month, currentTestDate.day), // Age 30
          gender: Gender.male, // BMR will be 1730
          heightCm: 180,
          currentWeightKg: 75,
          goalType: GoalType.weightMaintenance,
          targetWeightKg: 75,
          isOnboardingCompleted: complete,
          activityLevel: null, // Ensure new system is used
          workActivityLevel: work,
          leisureActivityLevel: leisure,
          activityTrackingPreference: trackingPreference,
          useAutomaticWeekdayDetection: useAutoWeekday, // Control this for predictability
          isCurrentlyWorkDay: currentWorkDay, // Control this for predictability
          isLeisureActivityEnabledToday: leisureEnabledToday,
        );
      }

      // Factors from UserProfileModel:
      // Work: sedentary: 1.2, light: 1.35, moderate: 1.5, heavy: 1.7, veryHeavy: 1.9
      // Leisure: sedentary: 1.0, lightlyActive: 1.1, moderatelyActive: 1.2, veryActive: 1.3, extraActive: 1.4
      // Leisure factor added is (leisureFactor - 1.0)

      test('should be 0 if isCompleteForCalculations is false', () {
        final profile = createNewSystemTdeeProfile(complete: false, currentTestDate: DateTime.now());
        expect(profile.tdee, 0);
      });

      // --- Automatic Tracking ---
      // Scenario 1: Automatic, Work Day, Leisure Enabled
      test('Automatic: Work Day, Leisure Enabled', () {
        final profile = createNewSystemTdeeProfile(
          work: WorkActivityLevel.moderate, // factor 1.5
          leisure: LeisureActivityLevel.lightlyActive, // factor 1.1 (adds 0.1)
          useAutoWeekday: false, // Manual override for workday
          currentWorkDay: true,   // It IS a workday
          leisureEnabledToday: true,
          currentTestDate: DateTime.now(),
        );
        // Expected: BMR * (workFactor + (leisureFactor - 1.0))
        // Expected: 1730 * (1.5 + (1.1 - 1.0)) = 1730 * (1.5 + 0.1) = 1730 * 1.6 = 2768
        expect(profile.tdee, closeTo(baseBmrForTdeeTests * (1.5 + 0.1), 0.1));
      });

      // Scenario 2: Automatic, Non-Work Day, Leisure Enabled
      test('Automatic: Non-Work Day, Leisure Enabled', () {
        final profile = createNewSystemTdeeProfile(
          work: WorkActivityLevel.moderate, // factor 1.5 (but non-workday, so uses 1.2)
          leisure: LeisureActivityLevel.moderatelyActive, // factor 1.2 (adds 0.2)
          useAutoWeekday: false,
          currentWorkDay: false, // It is NOT a workday
          leisureEnabledToday: true,
          currentTestDate: DateTime.now(),
        );
        // Expected: BMR * (sedentaryWorkFactor + (leisureFactor - 1.0))
        // Expected: 1730 * (1.2 + (1.2 - 1.0)) = 1730 * (1.2 + 0.2) = 1730 * 1.4 = 2422
        expect(profile.tdee, closeTo(baseBmrForTdeeTests * (1.2 + 0.2), 0.1));
      });

      // Scenario 3: Automatic, Work Day, Leisure Disabled
      test('Automatic: Work Day, Leisure Disabled', () {
        final profile = createNewSystemTdeeProfile(
          work: WorkActivityLevel.light, // factor 1.35
          leisure: LeisureActivityLevel.veryActive, // factor 1.3 (adds 0.3, but disabled)
          useAutoWeekday: false,
          currentWorkDay: true,
          leisureEnabledToday: false, // Leisure disabled
          currentTestDate: DateTime.now(),
        );
        // Expected: BMR * workFactor
        // Expected: 1730 * 1.35 = 2335.5
        expect(profile.tdee, closeTo(baseBmrForTdeeTests * 1.35, 0.1));
      });

      // Scenario 4: Automatic, Non-Work Day, Leisure Disabled
      test('Automatic: Non-Work Day, Leisure Disabled', () {
        final profile = createNewSystemTdeeProfile(
          work: WorkActivityLevel.heavy, // factor 1.7 (but non-workday, so uses 1.2)
          leisure: LeisureActivityLevel.extraActive, // factor 1.4 (adds 0.4, but disabled)
          useAutoWeekday: false,
          currentWorkDay: false,
          leisureEnabledToday: false, // Leisure disabled
          currentTestDate: DateTime.now(),
        );
        // Expected: BMR * sedentaryWorkFactor
        // Expected: 1730 * 1.2 = 2076
        expect(profile.tdee, closeTo(baseBmrForTdeeTests * 1.2, 0.1));
      });

      // --- Manual Tracking ---
      test('Manual Tracking: Work Day, Leisure (should be ignored)', () {
        final profile = createNewSystemTdeeProfile(
          trackingPreference: ActivityTrackingPreference.manual,
          work: WorkActivityLevel.sedentary, // factor 1.2
          leisure: LeisureActivityLevel.veryActive, // factor 1.3 (should be ignored)
          useAutoWeekday: false,
          currentWorkDay: true,
          leisureEnabledToday: true, // Does not matter for manual
          currentTestDate: DateTime.now(),
        );
        // Expected: BMR * workFactor (leisure is 0 for manual)
        // Expected: 1730 * 1.2 = 2076
        expect(profile.tdee, closeTo(baseBmrForTdeeTests * 1.2, 0.1));
      });

      test('Manual Tracking: Non-Work Day, Leisure (should be ignored)', () {
        final profile = createNewSystemTdeeProfile(
          trackingPreference: ActivityTrackingPreference.manual,
          work: WorkActivityLevel.moderate, // factor 1.5 (but non-workday, so 1.2)
          leisure: LeisureActivityLevel.extraActive, // factor 1.4 (should be ignored)
          useAutoWeekday: false,
          currentWorkDay: false,
          leisureEnabledToday: false, // Does not matter for manual
          currentTestDate: DateTime.now(),
        );
        // Expected: BMR * sedentaryWorkFactor (leisure is 0 for manual)
        // Expected: 1730 * 1.2 = 2076
        expect(profile.tdee, closeTo(baseBmrForTdeeTests * 1.2, 0.1));
      });

      // --- Hybrid Tracking (should behave like Automatic for base TDEE) ---
      test('Hybrid Tracking: Work Day, Leisure Enabled (behaves like Automatic)', () {
        final profile = createNewSystemTdeeProfile(
          trackingPreference: ActivityTrackingPreference.hybrid,
          work: WorkActivityLevel.moderate, // factor 1.5
          leisure: LeisureActivityLevel.lightlyActive, // factor 1.1 (adds 0.1)
          useAutoWeekday: false,
          currentWorkDay: true,
          leisureEnabledToday: true,
          currentTestDate: DateTime.now(),
        );
        expect(profile.tdee, closeTo(baseBmrForTdeeTests * (1.5 + 0.1), 0.1));
      });

      // Test automatic weekday detection (requires running tests on specific days or injecting DateTime)
      // For now, this is implicitly tested by the manual override tests.
      // A more robust test would involve injecting a DateTime provider.
    });

    group('BMI Calculation', () {
      test('should calculate BMI correctly', () {
        final profile = createProfile(currentWeightKg: 75, heightCm: 180); // Male, 30y
        // BMI = 75 / (1.8 * 1.8) = 75 / 3.24 = 23.148...
        expect(profile.bmi, closeTo(23.15, 0.01));
      });

      test('should be 0 if heightCm is 0', () {
        final profile = createProfile(currentWeightKg: 75, heightCm: 0);
        expect(profile.bmi, 0);
      });

      test('should be 0 if currentWeightKg is 0', () {
        final profile = createProfile(currentWeightKg: 0, heightCm: 180);
        expect(profile.bmi, 0);
      });
    });

    group('BMI Category', () {
      test('should return "Ukendt" if BMI is 0', () {
        final profile = createProfile(currentWeightKg: 0, heightCm: 0); // Results in BMI 0
        expect(profile.bmiCategory, 'Ukendt');
      });

      test('should return "Undervægt" for BMI < 18.5', () {
        // Weight 50kg, Height 1.75m -> BMI = 50 / (1.75*1.75) = 50 / 3.0625 = 16.33
        final profile = createProfile(currentWeightKg: 50, heightCm: 175);
        expect(profile.bmiCategory, 'Undervægt');
      });

      test('should return "Normal" for BMI >= 18.5 and < 25.0', () {
        // Weight 70kg, Height 1.75m -> BMI = 70 / (1.75*1.75) = 70 / 3.0625 = 22.86
        final profile = createProfile(currentWeightKg: 70, heightCm: 175);
        expect(profile.bmiCategory, 'Normal');
      });

      test('should return "Overvægt" for BMI >= 25.0 and < 30.0', () {
        // Weight 85kg, Height 1.75m -> BMI = 85 / (1.75*1.75) = 85 / 3.0625 = 27.76
        final profile = createProfile(currentWeightKg: 85, heightCm: 175);
        expect(profile.bmiCategory, 'Overvægt');
      });

      test('should return "Fedme" for BMI >= 30.0', () {
        // Weight 100kg, Height 1.75m -> BMI = 100 / (1.75*1.75) = 100 / 3.0625 = 32.65
        final profile = createProfile(currentWeightKg: 100, heightCm: 175);
        expect(profile.bmiCategory, 'Fedme');
      });
    });

  });
}
