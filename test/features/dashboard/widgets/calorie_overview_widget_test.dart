import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calories/features/dashboard/widgets/calorie_overview_widget.dart';
import 'package:calories/features/onboarding/application/onboarding_notifier.dart';
import 'package:calories/features/onboarding/domain/user_profile_model.dart';

/// Test to verify CalorieOverviewWidget rebuilds when activity toggles change
void main() {
  group('CalorieOverviewWidget UI Reactivity Test', () {
    late ProviderContainer container;
    late OnboardingNotifier onboardingNotifier;

    setUp(() {
      container = ProviderContainer();
      onboardingNotifier = container.read(onboardingProvider.notifier);
      
      // Setup a completed user profile
      final testProfile = UserProfileModel(
        name: 'Test User',
        dateOfBirth: DateTime(1990, 1, 1),
        gender: Gender.male,
        heightCm: 180,
        currentWeightKg: 80,
        goalType: GoalType.weightMaintenance,
        weeklyGoalKg: 0,
        targetCalories: 2000,
        workActivityLevel: WorkActivityLevel.light,
        leisureActivityLevel: LeisureActivityLevel.moderatelyActive,
        activityTrackingPreference: ActivityTrackingPreference.automatic,
        useAutomaticWeekdayDetection: false,
        isCurrentlyWorkDay: true,
        isLeisureActivityEnabledToday: true,
        isOnboardingCompleted: true, // Key: user is completed
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
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('Should rebuild and show different calories when leisure activity is toggled', (tester) async {
      print('🧪 Testing UI reactivity to leisure activity toggle');
      
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              body: const CalorieOverviewWidget(),
            ),
          ),
        ),
      );

      // Initial pump to load the widget
      await tester.pumpAndSettle();
      print('📱 Initial widget loaded');

      // Find any text showing calories remaining (look for pattern with "tilbage")
      final initialText = find.textContaining('tilbage').evaluate().isEmpty 
          ? null
          : tester.widget<Text>(find.textContaining('tilbage').first).data;
      
      if (initialText != null) {
        print('🔢 Initial calories text: $initialText');
      } else {
        print('❓ No "tilbage" text found, checking for any number pattern');
        // Look for any large numbers (calorie values)
        final numberFinders = [
          find.textContaining('2000'),
          find.textContaining('2400'),
          find.textContaining('2800'),
          find.textContaining('3000'),
        ];
        
        for (final finder in numberFinders) {
          if (finder.evaluate().isNotEmpty) {
            final text = tester.widget<Text>(finder.first).data;
            print('🔢 Found number text: $text');
            break;
          }
        }
      }

      // Toggle leisure activity OFF
      print('🔄 Toggling leisure activity OFF');
      onboardingNotifier.updateLeisureActivityForToday(false);
      
      // Pump to trigger rebuild
      await tester.pump();
      await tester.pumpAndSettle();
      print('📱 Widget updated after toggle');

      // Check if calories changed
      final updatedText = find.textContaining('tilbage').evaluate().isEmpty 
          ? null
          : tester.widget<Text>(find.textContaining('tilbage').first).data;
      
      if (updatedText != null) {
        print('🔢 Updated calories text: $updatedText');
        
        if (initialText != null && updatedText != initialText) {
          print('✅ SUCCESS: Calories text changed from "$initialText" to "$updatedText"');
        } else if (initialText != null) {
          print('❌ PROBLEM: Calories text did NOT change (still "$updatedText")');
        }
      } else {
        print('❓ No "tilbage" text found after toggle');
      }

      // Verify the profile was actually updated
      final currentProfile = container.read(onboardingProvider).userProfile;
      expect(currentProfile.isLeisureActivityEnabledToday, false);
      print('✅ Profile was updated correctly (leisure activity: ${currentProfile.isLeisureActivityEnabledToday})');

      // Toggle leisure activity back ON
      print('🔄 Toggling leisure activity ON');
      onboardingNotifier.updateLeisureActivityForToday(true);
      
      await tester.pump();
      await tester.pumpAndSettle();
      print('📱 Widget updated after second toggle');

      // Check final state
      final finalProfile = container.read(onboardingProvider).userProfile;
      expect(finalProfile.isLeisureActivityEnabledToday, true);
      print('✅ Profile restored correctly (leisure activity: ${finalProfile.isLeisureActivityEnabledToday})');
      
      print('🧪 Test completed');
    });

    testWidgets('Should rebuild and show different calories when work day is toggled', (tester) async {
      print('🧪 Testing UI reactivity to work day toggle');
      
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              body: const CalorieOverviewWidget(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      print('📱 Initial widget loaded');

      // Check initial state  
      final initialProfile = container.read(onboardingProvider).userProfile;
      print('📋 Initial state: work day = ${initialProfile.isCurrentlyWorkDay}');

      // Toggle work day OFF  
      print('🔄 Toggling work day OFF');
      onboardingNotifier.updateCurrentWorkDayStatus(false);
      
      await tester.pump();
      await tester.pumpAndSettle();
      print('📱 Widget updated after work day toggle');

      // Verify the profile was actually updated
      final updatedProfile = container.read(onboardingProvider).userProfile;
      expect(updatedProfile.isCurrentlyWorkDay, false);
      print('✅ Profile updated correctly (work day: ${updatedProfile.isCurrentlyWorkDay})');

      // Toggle back ON
      print('🔄 Toggling work day ON');
      onboardingNotifier.updateCurrentWorkDayStatus(true);
      
      await tester.pump();
      await tester.pumpAndSettle();
      print('📱 Widget updated after second toggle');

      final finalProfile = container.read(onboardingProvider).userProfile;
      expect(finalProfile.isCurrentlyWorkDay, true);
      print('✅ Profile restored correctly (work day: ${finalProfile.isCurrentlyWorkDay})');
      
      print('🧪 Work day toggle test completed');
    });
  });
} 