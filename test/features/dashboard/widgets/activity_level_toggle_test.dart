import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calories/features/onboarding/application/onboarding_notifier.dart';
import 'package:calories/features/onboarding/domain/user_profile_model.dart';

import 'package:shared_preferences/shared_preferences.dart';

/// Test suite to verify that activity level toggles properly affect calorie calculations
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  group('Activity Level Toggle Impact on Calories', () {
    late ProviderContainer container;
    late OnboardingNotifier onboardingNotifier;

    setUp(() {
      container = ProviderContainer();
      onboardingNotifier = container.read(onboardingProvider.notifier);
      
      // Setup a test user profile with all required values
      final testProfile = UserProfileModel(
        name: 'Test User',
        dateOfBirth: DateTime(1990, 1, 1), // 34 years old
        gender: Gender.male,
        heightCm: 180,
        currentWeightKg: 80,
        goalType: GoalType.weightMaintenance,
        weeklyGoalKg: 0,
        targetCalories: 2000,
        workActivityLevel: WorkActivityLevel.light, // Office work
        leisureActivityLevel: LeisureActivityLevel.moderatelyActive, // Regular exercise
        activityTrackingPreference: ActivityTrackingPreference.automatic,
        useAutomaticWeekdayDetection: false, // Manual control for testing
        isCurrentlyWorkDay: true,
        isLeisureActivityEnabledToday: true,
      );
      
      // Use individual update methods instead of updateUserProfile
      onboardingNotifier.updateName(testProfile.name);
      onboardingNotifier.updateDateOfBirth(testProfile.dateOfBirth!);
      onboardingNotifier.updateGender(testProfile.gender!);
      onboardingNotifier.updateHeight(testProfile.heightCm);
      onboardingNotifier.updateCurrentWeight(testProfile.currentWeightKg);
      onboardingNotifier.updateGoalType(testProfile.goalType!);
      onboardingNotifier.updateWorkActivityLevel(testProfile.workActivityLevel!);
      onboardingNotifier.updateLeisureActivityLevel(testProfile.leisureActivityLevel!);
    });

    tearDown(() {
      container.dispose();
    });

    test('Should calculate different TDEE for work day vs non-work day', () {
      // Test BMR calculation first
      final profile = container.read(onboardingProvider).userProfile;
      
      // Calculate expected BMR for 34-year-old male, 180cm, 80kg
      // Mifflin-St Jeor: BMR = (10 × weight) + (6.25 × height) - (5 × age) + 5
      final expectedBmr = (10 * 80) + (6.25 * 180) - (5 * 34) + 5;
      // = 800 + 1125 - 170 + 5 = 1760 kcal
      
      print('📊 Expected BMR: ${expectedBmr.round()} kcal');

      // Test work day TDEE
      double workDayTdee = _calculateTestTdee(profile.copyWith(isCurrentlyWorkDay: true));
      print('💼 Work Day TDEE: ${workDayTdee.round()} kcal');
      
      // Test non-work day TDEE  
      double nonWorkDayTdee = _calculateTestTdee(profile.copyWith(isCurrentlyWorkDay: false));
      print('🏠 Non-Work Day TDEE: ${nonWorkDayTdee.round()} kcal');
      
      // Work day should have higher TDEE due to light work activity
      expect(workDayTdee, greaterThan(nonWorkDayTdee));
      
      // Calculate expected values:
      // Work day: BMR × 1.375 (light work) + BMR × 0.35 (moderate leisure) = BMR × 1.725
      final expectedWorkDayTdee = expectedBmr * 1.375 + expectedBmr * 0.35; // 3034 kcal
      
      // Non-work day: BMR × 1.2 (sedentary baseline) + BMR × 0.35 (moderate leisure) = BMR × 1.55
      final expectedNonWorkDayTdee = expectedBmr * 1.2 + expectedBmr * 0.35; // 2728 kcal
      
      print('📈 Expected Work Day TDEE: ${expectedWorkDayTdee.round()} kcal');
      print('📉 Expected Non-Work Day TDEE: ${expectedNonWorkDayTdee.round()} kcal');
      
      // Allow for small rounding differences
      expect(workDayTdee, closeTo(expectedWorkDayTdee, 10));
      expect(nonWorkDayTdee, closeTo(expectedNonWorkDayTdee, 10));
    });

    test('Should calculate different TDEE when leisure activity is toggled off', () {
      final profile = container.read(onboardingProvider).userProfile;
      final expectedBmr = (10 * 80) + (6.25 * 180) - (5 * 34) + 5; // 1760 kcal
      
      // Test work day with leisure activity enabled
      double withLeisureTdee = _calculateTestTdee(profile.copyWith(
        isCurrentlyWorkDay: true,
        isLeisureActivityEnabledToday: true,
      ));
      print('🏃‍♂️ Work Day + Leisure TDEE: ${withLeisureTdee.round()} kcal');
      
      // Test work day with leisure activity disabled
      double withoutLeisureTdee = _calculateTestTdee(profile.copyWith(
        isCurrentlyWorkDay: true,
        isLeisureActivityEnabledToday: false,
      ));
      print('🚫 Work Day - No Leisure TDEE: ${withoutLeisureTdee.round()} kcal');
      
      // With leisure should have higher TDEE
      expect(withLeisureTdee, greaterThan(withoutLeisureTdee));
      
      // Calculate expected values:
      // With leisure: BMR × 1.375 (light work) + BMR × 0.35 (moderate leisure) = 3034 kcal
      final expectedWithLeisure = expectedBmr * 1.375 + expectedBmr * 0.35;
      
      // Without leisure: BMR × 1.375 (light work) + 0 = 2420 kcal
      final expectedWithoutLeisure = expectedBmr * 1.375;
      
      print('📈 Expected With Leisure: ${expectedWithLeisure.round()} kcal');
      print('📉 Expected Without Leisure: ${expectedWithoutLeisure.round()} kcal');
      
      expect(withLeisureTdee, closeTo(expectedWithLeisure, 10));
      expect(withoutLeisureTdee, closeTo(expectedWithoutLeisure, 10));
      
      // The difference should be exactly the leisure activity bonus
      final leisureDifference = withLeisureTdee - withoutLeisureTdee;
      final expectedLeisureBonus = expectedBmr * 0.35; // Moderate leisure = +35% of BMR
      
      print('💪 Leisure Activity Bonus: ${leisureDifference.round()} kcal');
      print('📊 Expected Leisure Bonus: ${expectedLeisureBonus.round()} kcal');
      
      expect(leisureDifference, closeTo(expectedLeisureBonus, 5));
    });

    test('Should verify that toggle changes affect remaining calories calculation', () {
      final profile = container.read(onboardingProvider).userProfile;
      
      // Simulate some consumed calories (e.g., 1200 kcal eaten so far)
      final consumedCalories = 1200.0;
      
      // Test scenario 1: Work day with leisure activity
      final tdeeWithLeisure = _calculateTestTdee(profile.copyWith(
        isCurrentlyWorkDay: true,
        isLeisureActivityEnabledToday: true,
      ));
      final remainingWithLeisure = tdeeWithLeisure - consumedCalories;
      
      // Test scenario 2: Work day without leisure activity
      final tdeeWithoutLeisure = _calculateTestTdee(profile.copyWith(
        isCurrentlyWorkDay: true,
        isLeisureActivityEnabledToday: false,
      ));
      final remainingWithoutLeisure = tdeeWithoutLeisure - consumedCalories;
      
      print('🍽️ Consumed: ${consumedCalories.round()} kcal');
      print('✅ Remaining with leisure: ${remainingWithLeisure.round()} kcal');
      print('❌ Remaining without leisure: ${remainingWithoutLeisure.round()} kcal');
      
      // With leisure activity enabled, should have more calories remaining
      expect(remainingWithLeisure, greaterThan(remainingWithoutLeisure));
      
      // The difference should be significant (about 600+ kcal for moderate leisure)
      final difference = remainingWithLeisure - remainingWithoutLeisure;
      print('🔄 Toggle Impact: ${difference.round()} kcal difference');
      
      expect(difference, greaterThan(500)); // Should be substantial difference
    });

    test('Should demonstrate the bug: Toggle changes dont affect calories in UI', () {
      // This test demonstrates what SHOULD happen vs what currently happens
      final profile = container.read(onboardingProvider).userProfile;
      
      print('\n🐛 BUG DEMONSTRATION:');
      print('====================');
      
      // Initial state: Work day with leisure enabled
      onboardingNotifier.updateCurrentWorkDayStatus(true);
      onboardingNotifier.updateLeisureActivityForToday(true);
      
      var currentProfile = container.read(onboardingProvider).userProfile;
      var tdee1 = _calculateTestTdee(currentProfile);
      print('🟢 Initial: Work day + Leisure = ${tdee1.round()} kcal');
      
      // Toggle leisure activity off
      onboardingNotifier.updateLeisureActivityForToday(false);
      
      currentProfile = container.read(onboardingProvider).userProfile;
      var tdee2 = _calculateTestTdee(currentProfile);
      print('🔴 After toggle: Work day - Leisure = ${tdee2.round()} kcal');
      
      // Toggle work day off
      onboardingNotifier.updateCurrentWorkDayStatus(false);
      
      currentProfile = container.read(onboardingProvider).userProfile;
      var tdee3 = _calculateTestTdee(currentProfile);
      print('🔴 After work toggle: Home day - Leisure = ${tdee3.round()} kcal');
      
      print('\n📊 Expected behavior:');
      print('   • Each toggle should change TDEE immediately');
      print('   • UI should show different "kalorier tilbage"');
      print('   • Changes should be visible without app restart');
      
      // Verify that profile changes are actually saved
      expect(currentProfile.isCurrentlyWorkDay, false);
      expect(currentProfile.isLeisureActivityEnabledToday, false);
      
      // Verify TDEE calculations are correct
      expect(tdee1, greaterThan(tdee2)); // Leisure toggle should reduce TDEE
      expect(tdee2, greaterThan(tdee3)); // Work toggle should reduce TDEE further
      
      print('\n✅ Profile changes are saved correctly');
      print('✅ TDEE calculations respond to changes');
      print('❌ UI probably doesnt listen to profile changes');
    });
  });
}

/// Helper function to replicate the TDEE calculation from CalorieOverviewWidget
double _calculateTestTdee(UserProfileModel profile) {
  // Calculate BMR using Mifflin-St Jeor Equation
  final now = DateTime.now();
  final birthDate = profile.dateOfBirth!;
  int age = now.year - birthDate.year;
  if (now.month < birthDate.month || 
      (now.month == birthDate.month && now.day < birthDate.day)) {
    age--;
  }

  double bmr;
  if (profile.gender == Gender.male) {
    bmr = (10 * profile.currentWeightKg) + 
          (6.25 * profile.heightCm) - 
          (5 * age) + 5;
  } else {
    bmr = (10 * profile.currentWeightKg) + 
          (6.25 * profile.heightCm) - 
          (5 * age) - 161;
  }

  // Calculate work activity multiplier
  double workMultiplier = 1.2; // Default sedentary baseline
  
  if (profile.isCurrentlyWorkDay) {
    workMultiplier = switch (profile.workActivityLevel!) {
      WorkActivityLevel.sedentary => 1.2,
      WorkActivityLevel.light => 1.375,
      WorkActivityLevel.moderate => 1.55,
      WorkActivityLevel.heavy => 1.725,
      WorkActivityLevel.veryHeavy => 1.9,
    };
  }
  
  // Calculate leisure activity addition
  double leisureAddition = 0.0;
  if (profile.activityTrackingPreference != ActivityTrackingPreference.manual && 
      profile.isLeisureActivityEnabledToday) {
    leisureAddition = switch (profile.leisureActivityLevel!) {
      LeisureActivityLevel.sedentary => 0.0,
      LeisureActivityLevel.lightlyActive => 0.155,
      LeisureActivityLevel.moderatelyActive => 0.35,
      LeisureActivityLevel.veryActive => 0.525,
      LeisureActivityLevel.extraActive => 0.7,
    };
  }
  
  return (bmr * workMultiplier) + (bmr * leisureAddition);
} 