import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calories/features/dashboard/presentation/dashboard_page.dart';
import 'package:calories/features/dashboard/widgets/calorie_overview_widget.dart';
import 'package:calories/features/dashboard/widgets/daily_settings_widget.dart';
import 'package:calories/features/onboarding/application/onboarding_notifier.dart';
import 'package:calories/features/onboarding/domain/user_profile_model.dart';
import 'package:calories/core/theme/app_theme.dart';

/// CRITICAL Integration test: Full dashboard UI reactivity
void main() {
  group('🚨 CRITICAL Dashboard Toggle UI Integration Tests', () {
    late ProviderContainer container;
    late OnboardingNotifier onboardingNotifier;

    setUp(() {
      container = ProviderContainer();
      onboardingNotifier = container.read(onboardingProvider.notifier);
      
      // Setup complete test profile with known values
      onboardingNotifier.updateName('Test User');
      onboardingNotifier.updateDateOfBirth(DateTime(1990, 1, 1));
      onboardingNotifier.updateGender(Gender.male);
      onboardingNotifier.updateHeight(180);
      onboardingNotifier.updateCurrentWeight(80);
      onboardingNotifier.updateGoalType(GoalType.weightMaintenance);
      onboardingNotifier.updateWorkActivityLevel(WorkActivityLevel.light);
      onboardingNotifier.updateLeisureActivityLevel(LeisureActivityLevel.moderatelyActive);
      onboardingNotifier.updateWeekdayDetection(false);
      onboardingNotifier.updateCurrentWorkDayStatus(true);
      onboardingNotifier.updateLeisureActivityForToday(true);
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('🔥 CRITICAL: Full Dashboard Calorie Display Update Test', (tester) async {
      print('\n🚨 CRITICAL TEST: Testing full dashboard calorie display reactivity');
      
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const DashboardPage(),
          ),
        ),
      );

      // Allow full loading
      await tester.pumpAndSettle(const Duration(seconds: 3));
      print('📱 Dashboard loaded completely');

      // Find all text widgets containing "kcal" (calorie displays)
      final initialCalorieTexts = _findAllCalorieTexts(tester);
      print('📊 Initial calorie displays found: ${initialCalorieTexts.length}');
      for (int i = 0; i < initialCalorieTexts.length; i++) {
        print('   [$i]: "${initialCalorieTexts[i]}"');
      }

      // Verify we found calorie displays
      expect(initialCalorieTexts.isNotEmpty, true, reason: 'Should find calorie displays in dashboard');

      // Find toggle switches by looking for Switch widgets
      final toggleWidgets = find.byType(Switch);
      print('🔘 Found ${toggleWidgets.evaluate().length} toggle switches');
      expect(toggleWidgets, findsAtLeastNWidgets(2), reason: 'Should find work day and leisure activity toggles');

      // Test 1: Toggle leisure activity OFF
      print('\n🔄 TEST 1: Toggling leisure activity OFF...');
      
      // Find leisure activity toggle (should be second switch)
      final leisureToggle = toggleWidgets.at(1);
      await tester.tap(leisureToggle);
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Check profile update
      var profile = container.read(onboardingProvider).userProfile;
      print('📋 Profile after leisure toggle: Leisure=${profile.isLeisureActivityEnabledToday}, TDEE=${profile.tdee}');

      // Get updated calorie displays
      final afterLeisureTexts = _findAllCalorieTexts(tester);
      print('📊 After leisure toggle: ${afterLeisureTexts.length} displays');
      for (int i = 0; i < afterLeisureTexts.length; i++) {
        print('   [$i]: "${afterLeisureTexts[i]}"');
      }

      // Compare calorie displays
      final leisureChangeDetected = !_listsEqual(initialCalorieTexts, afterLeisureTexts);
      print('📈 Calorie display changed after leisure toggle: $leisureChangeDetected');

      if (!leisureChangeDetected) {
        print('❌ CRITICAL FAILURE: UI did NOT update after leisure toggle despite profile change!');
        print('   Expected: Calorie displays should change');
        print('   Actual: Calorie displays remained the same');
        print('   This confirms the UI reactivity bug!');
      }

      // Test 2: Toggle work day OFF
      print('\n🔄 TEST 2: Toggling work day OFF...');
      
      final workToggle = toggleWidgets.at(0);
      await tester.tap(workToggle);
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Check profile update
      profile = container.read(onboardingProvider).userProfile;
      print('📋 Profile after work toggle: WorkDay=${profile.isCurrentlyWorkDay}, TDEE=${profile.tdee}');

      // Get updated calorie displays
      final afterWorkTexts = _findAllCalorieTexts(tester);
      print('📊 After work toggle: ${afterWorkTexts.length} displays');
      for (int i = 0; i < afterWorkTexts.length; i++) {
        print('   [$i]: "${afterWorkTexts[i]}"');
      }

      // Compare calorie displays
      final workChangeDetected = !_listsEqual(afterLeisureTexts, afterWorkTexts);
      print('📈 Calorie display changed after work toggle: $workChangeDetected');

      if (!workChangeDetected) {
        print('❌ CRITICAL FAILURE: UI did NOT update after work toggle despite profile change!');
      }

      // Test 3: Toggle both back ON
      print('\n🔄 TEST 3: Toggling both back ON...');
      
      await tester.tap(leisureToggle);
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 1));
      
      await tester.tap(workToggle);
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 1));

      profile = container.read(onboardingProvider).userProfile;
      print('📋 Final profile: WorkDay=${profile.isCurrentlyWorkDay}, Leisure=${profile.isLeisureActivityEnabledToday}, TDEE=${profile.tdee}');

      final finalTexts = _findAllCalorieTexts(tester);
      print('📊 Final calorie displays: ${finalTexts.length} displays');
      for (int i = 0; i < finalTexts.length; i++) {
        print('   [$i]: "${finalTexts[i]}"');
      }

      // Summary
      print('\n📊 CRITICAL TEST SUMMARY:');
      print('   - Initial displays: ${initialCalorieTexts.length}');
      print('   - After leisure OFF: ${afterLeisureTexts.length}');
      print('   - After work OFF: ${afterWorkTexts.length}');
      print('   - Final (both ON): ${finalTexts.length}');
      print('   - Leisure toggle UI change: $leisureChangeDetected');
      print('   - Work toggle UI change: $workChangeDetected');

      // Verify profile changes are working
      expect(profile.isCurrentlyWorkDay, true);
      expect(profile.isLeisureActivityEnabledToday, true);

      // The critical test: UI should have changed
      if (!leisureChangeDetected || !workChangeDetected) {
        fail('CRITICAL BUG CONFIRMED: UI does not react to toggle changes despite correct profile updates!');
      } else {
        print('✅ CRITICAL TEST PASSED: UI correctly reacts to toggles');
      }
    });

    testWidgets('🔍 Widget Tree Inspection Test', (tester) async {
      print('\n🔍 WIDGET TREE INSPECTION: Finding CalorieOverviewWidget');
      
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const DashboardPage(),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Look for specific widget types
      final calorieWidgets = find.byType(CalorieOverviewWidget);
      final dailySettingsWidgets = find.byType(DailySettingsWidget);
      
      print('📋 Widget tree analysis:');
      print('   - CalorieOverviewWidget found: ${calorieWidgets.evaluate().length}');
      print('   - DailySettingsWidget found: ${dailySettingsWidgets.evaluate().length}');

      expect(calorieWidgets, findsOneWidget, reason: 'Dashboard should contain CalorieOverviewWidget');
      expect(dailySettingsWidgets, findsOneWidget, reason: 'Dashboard should contain DailySettingsWidget');

      // Analyze all text widgets
      final allTexts = find.byType(Text);
      print('   - Total Text widgets: ${allTexts.evaluate().length}');

      // Look for specific calorie-related text patterns
      final caloriePatterns = ['kcal', 'kalorier', 'TDEE', 'mål'];
      for (final pattern in caloriePatterns) {
        final matches = find.textContaining(pattern, findRichText: true);
        print('   - Text containing "$pattern": ${matches.evaluate().length}');
      }

      print('✅ Widget tree inspection completed');
    });

    testWidgets('🔧 Debug Provider Watching Test', (tester) async {
      print('\n🔧 DEBUG: Testing provider watching in isolation');
      
      // Create a simple test widget that watches onboardingProvider
      Widget testWidget = Consumer(
        builder: (context, ref, child) {
          final profile = ref.watch(onboardingProvider).userProfile;
          print('🔄 Test widget rebuild triggered - TDEE: ${profile.tdee}');
          return Text('TDEE: ${profile.tdee}');
        },
      );

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              body: testWidget,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      // Get initial text
      final initialTdeeText = tester.widget<Text>(find.byType(Text)).data;
      print('📋 Initial TDEE text: "$initialTdeeText"');

      // Trigger provider change
      print('🔄 Triggering leisure activity toggle...');
      onboardingNotifier.updateLeisureActivityForToday(false);
      await tester.pump();

      // Get updated text
      final updatedTdeeText = tester.widget<Text>(find.byType(Text)).data;
      print('📋 Updated TDEE text: "$updatedTdeeText"');

      // Check if they're different
      final textChanged = initialTdeeText != updatedTdeeText;
      print('📈 TDEE text changed: $textChanged');

      if (textChanged) {
        print('✅ Provider watching works correctly in isolation');
      } else {
        print('❌ Provider watching failed even in isolation - this is the root problem!');
      }

      expect(textChanged, true, reason: 'TDEE text should change when leisure activity is toggled');
    });
  });
}

/// Helper function to find all text containing calorie-related information
List<String> _findAllCalorieTexts(WidgetTester tester) {
  final calorieTexts = <String>[];
  
  // Find all Text widgets
  final textWidgets = find.byType(Text);
  
  for (final textWidget in textWidgets.evaluate()) {
    final text = (textWidget.widget as Text).data;
    if (text != null && (text.contains('kcal') || text.contains('kalorier') || 
        text.contains('TDEE') || text.contains('mål'))) {
      calorieTexts.add(text);
    }
  }
  
  return calorieTexts;
}

/// Helper function to compare lists for equality
bool _listsEqual<T>(List<T> list1, List<T> list2) {
  if (list1.length != list2.length) return false;
  for (int i = 0; i < list1.length; i++) {
    if (list1[i] != list2[i]) return false;
  }
  return true;
} 