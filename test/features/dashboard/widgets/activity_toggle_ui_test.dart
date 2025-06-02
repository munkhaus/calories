import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calories/features/dashboard/widgets/daily_settings_widget.dart';
import 'package:calories/features/dashboard/widgets/calorie_overview_widget.dart';
import 'package:calories/features/onboarding/application/onboarding_notifier.dart';
import 'package:calories/features/onboarding/domain/user_profile_model.dart';
import 'package:calories/core/theme/app_theme.dart';

/// Comprehensive UI test to identify toggle problems
void main() {
  group('Activity Toggle UI Tests - Problem Identification', () {
    late ProviderContainer container;
    late OnboardingNotifier onboardingNotifier;

    setUp(() {
      container = ProviderContainer();
      onboardingNotifier = container.read(onboardingProvider.notifier);
      
      // Setup a complete test profile
      final testProfile = UserProfileModel(
        name: 'Test User',
        dateOfBirth: DateTime(1990, 1, 1),
        gender: Gender.male,
        heightCm: 180,
        currentWeightKg: 80,
        goalType: GoalType.weightMaintenance,
        workActivityLevel: WorkActivityLevel.light,
        leisureActivityLevel: LeisureActivityLevel.moderatelyActive,
        activityTrackingPreference: ActivityTrackingPreference.automatic,
        useAutomaticWeekdayDetection: false, // Manual control
        isCurrentlyWorkDay: true,
        isLeisureActivityEnabledToday: true,
        targetCalories: 4000,
        isOnboardingCompleted: true,
      );
      
      // Use individual update methods to setup profile
      onboardingNotifier.updateName(testProfile.name);
      onboardingNotifier.updateDateOfBirth(testProfile.dateOfBirth!);
      onboardingNotifier.updateGender(testProfile.gender!);
      onboardingNotifier.updateHeight(testProfile.heightCm);
      onboardingNotifier.updateCurrentWeight(testProfile.currentWeightKg);
      onboardingNotifier.updateGoalType(testProfile.goalType!);
      onboardingNotifier.updateWorkActivityLevel(testProfile.workActivityLevel!);
      onboardingNotifier.updateLeisureActivityLevel(testProfile.leisureActivityLevel!);
      onboardingNotifier.updateWeekdayDetection(false);
      onboardingNotifier.updateCurrentWorkDayStatus(true);
      onboardingNotifier.updateLeisureActivityForToday(true);
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('🔍 Test 1: Verify Toggle UI Elements Exist', (tester) async {
      print('\n🧪 TEST 1: Verifying toggle UI elements exist');
      
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  const DailySettingsWidget(),
                  const CalorieOverviewWidget(),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      print('📱 Widgets loaded');

      // Find toggle widgets
      final workToggleFinder = find.text('Arbejdsdag');
      final leisureToggleFinder = find.text('Fritidsaktivitet tæller');
      
      expect(workToggleFinder, findsOneWidget, reason: 'Work day toggle should be visible');
      expect(leisureToggleFinder, findsOneWidget, reason: 'Leisure activity toggle should be visible');
      
      print('✅ TEST 1 PASSED: Both toggles are visible');
    });

    testWidgets('🔍 Test 2: Verify Initial Profile State', (tester) async {
      print('\n🧪 TEST 2: Verifying initial profile state');
      
      final initialProfile = container.read(onboardingProvider).userProfile;
      
      print('📋 Initial Profile State:');
      print('   - Work Day: ${initialProfile.isCurrentlyWorkDay}');
      print('   - Leisure Enabled: ${initialProfile.isLeisureActivityEnabledToday}');
      print('   - Target Calories: ${initialProfile.targetCalories}');
      print('   - TDEE: ${initialProfile.tdee}');
      
      expect(initialProfile.isCurrentlyWorkDay, true);
      expect(initialProfile.isLeisureActivityEnabledToday, true);
      expect(initialProfile.targetCalories, 4000);
      
      print('✅ TEST 2 PASSED: Initial profile state is correct');
    });

    testWidgets('🔍 Test 3: Work Day Toggle Updates Profile', (tester) async {
      print('\n🧪 TEST 3: Testing work day toggle profile updates');
      
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              body: const DailySettingsWidget(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Get initial state
      var profile = container.read(onboardingProvider).userProfile;
      print('📋 Before toggle: Work Day = ${profile.isCurrentlyWorkDay}');
      
      // Find and tap work day toggle
      final workToggle = find.text('Arbejdsdag');
      expect(workToggle, findsOneWidget);
      
      await tester.tap(workToggle);
      await tester.pump();
      await tester.pumpAndSettle();

      // Check if profile updated
      profile = container.read(onboardingProvider).userProfile;
      print('📋 After toggle: Work Day = ${profile.isCurrentlyWorkDay}');
      
      expect(profile.isCurrentlyWorkDay, false, reason: 'Work day should toggle from true to false');
      
      print('✅ TEST 3 PASSED: Work day toggle updates profile');
    });

    testWidgets('🔍 Test 4: Leisure Activity Toggle Updates Profile', (tester) async {
      print('\n🧪 TEST 4: Testing leisure activity toggle profile updates');
      
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              body: const DailySettingsWidget(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Get initial state
      var profile = container.read(onboardingProvider).userProfile;
      print('📋 Before toggle: Leisure Enabled = ${profile.isLeisureActivityEnabledToday}');
      
      // Find and tap leisure activity toggle
      final leisureToggle = find.text('Fritidsaktivitet tæller');
      expect(leisureToggle, findsOneWidget);
      
      await tester.tap(leisureToggle);
      await tester.pump();
      await tester.pumpAndSettle();

      // Check if profile updated
      profile = container.read(onboardingProvider).userProfile;
      print('📋 After toggle: Leisure Enabled = ${profile.isLeisureActivityEnabledToday}');
      
      expect(profile.isLeisureActivityEnabledToday, false, reason: 'Leisure activity should toggle from true to false');
      
      print('✅ TEST 4 PASSED: Leisure activity toggle updates profile');
    });

    testWidgets('🔍 Test 5: CRITICAL - CalorieOverviewWidget Reactivity', (tester) async {
      print('\n🧪 TEST 5 (CRITICAL): Testing CalorieOverviewWidget reactivity to toggles');
      
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  const DailySettingsWidget(),
                  const Expanded(child: CalorieOverviewWidget()),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      print('📱 Combined widget loaded');

      // Get initial state and calories
      var profile = container.read(onboardingProvider).userProfile;
      print('📋 Initial State:');
      print('   - Work Day: ${profile.isCurrentlyWorkDay}');
      print('   - Leisure Enabled: ${profile.isLeisureActivityEnabledToday}');
      print('   - TDEE: ${profile.tdee}');
      print('   - Target Calories: ${profile.targetCalories}');

      // Look for calorie text in the UI
      final calorieTextFinder = find.textContaining('kcal');
      expect(calorieTextFinder, findsWidgets);
      
      // Take screenshot of initial state
      final initialCalorieTexts = calorieTextFinder.evaluate().map(
        (element) => (element.widget as Text).data ?? ''
      ).toList();
      print('📊 Initial calorie displays: $initialCalorieTexts');

      // Toggle leisure activity OFF
      print('\n🔄 Toggling leisure activity OFF...');
      final leisureToggle = find.text('Fritidsaktivitet tæller');
      await tester.tap(leisureToggle);
      await tester.pump();
      await tester.pumpAndSettle();

      // Check profile update
      profile = container.read(onboardingProvider).userProfile;
      print('📋 After leisure toggle:');
      print('   - Leisure Enabled: ${profile.isLeisureActivityEnabledToday}');
      print('   - TDEE: ${profile.tdee}');
      print('   - Target Calories: ${profile.targetCalories}');

      // Check if UI updated
      final updatedCalorieTexts = calorieTextFinder.evaluate().map(
        (element) => (element.widget as Text).data ?? ''
      ).toList();
      print('📊 Updated calorie displays: $updatedCalorieTexts');

      // Compare calorie displays
      final calorieDifferent = !_listsEqual(initialCalorieTexts, updatedCalorieTexts);
      print('📈 Calorie display changed: $calorieDifferent');

      if (!calorieDifferent) {
        print('❌ CRITICAL ISSUE: Calorie display did NOT change after toggle!');
        print('   This confirms the UI reactivity problem.');
      } else {
        print('✅ UI correctly updated calorie display');
      }

      // Toggle work day OFF
      print('\n🔄 Toggling work day OFF...');
      final workToggle = find.text('Hjemme/fridag'); // Should now show "Hjemme/fridag"
      if (workToggle.evaluate().isEmpty) {
        // Fallback: find by gesture detector or container
        final workContainer = find.byType(GestureDetector).at(0); // First toggle should be work day
        await tester.tap(workContainer);
      } else {
        await tester.tap(workToggle);
      }
      await tester.pump();
      await tester.pumpAndSettle();

      // Final state check
      profile = container.read(onboardingProvider).userProfile;
      print('📋 Final state:');
      print('   - Work Day: ${profile.isCurrentlyWorkDay}');
      print('   - Leisure Enabled: ${profile.isLeisureActivityEnabledToday}');
      print('   - TDEE: ${profile.tdee}');
      print('   - Target Calories: ${profile.targetCalories}');

      final finalCalorieTexts = calorieTextFinder.evaluate().map(
        (element) => (element.widget as Text).data ?? ''
      ).toList();
      print('📊 Final calorie displays: $finalCalorieTexts');

      print('\n📊 SUMMARY:');
      print('   - Initial: $initialCalorieTexts');
      print('   - After leisure toggle: $updatedCalorieTexts');
      print('   - After work toggle: $finalCalorieTexts');
      
      // The test should verify that TDEE changes resulted in UI changes
      expect(profile.isCurrentlyWorkDay, false);
      expect(profile.isLeisureActivityEnabledToday, false);
      
      if (calorieDifferent) {
        print('✅ TEST 5 PASSED: UI is reactive to toggles');
      } else {
        print('❌ TEST 5 FAILED: UI is NOT reactive to toggles - THIS IS THE BUG');
      }
    });

    testWidgets('🔍 Test 6: Provider Notification Test', (tester) async {
      print('\n🧪 TEST 6: Testing provider notification propagation');
      
      int notificationCount = 0;
      
      // Create a listener widget that tracks provider changes
      Widget listenerWidget = Consumer(
        builder: (context, ref, child) {
          ref.listen(onboardingProvider, (previous, next) {
            notificationCount++;
            print('📡 Provider notification #$notificationCount');
            print('   - Previous TDEE: ${previous?.userProfile.tdee}');
            print('   - New TDEE: ${next.userProfile.tdee}');
          });
          
          final profile = ref.watch(onboardingProvider).userProfile;
          return Text('TDEE: ${profile.tdee}');
        },
      );

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  const DailySettingsWidget(),
                  listenerWidget,
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      print('📋 Initial notification count: $notificationCount');
      
      // Trigger leisure toggle
      onboardingNotifier.updateLeisureActivityForToday(false);
      await tester.pump();
      
      print('📋 After leisure toggle notification count: $notificationCount');
      
      // Trigger work day toggle
      onboardingNotifier.updateCurrentWorkDayStatus(false);
      await tester.pump();
      
      print('📋 After work toggle notification count: $notificationCount');
      
      expect(notificationCount, greaterThan(0), reason: 'Provider should notify listeners');
      
      print('✅ TEST 6 PASSED: Provider notifications are working');
    });
  });
}

bool _listsEqual<T>(List<T> list1, List<T> list2) {
  if (list1.length != list2.length) return false;
  for (int i = 0; i < list1.length; i++) {
    if (list1[i] != list2[i]) return false;
  }
  return true;
} 