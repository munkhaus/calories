import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calories/features/dashboard/widgets/calorie_overview_widget.dart';
import 'package:calories/features/onboarding/application/onboarding_notifier.dart';
import 'package:calories/features/onboarding/domain/user_profile_model.dart';
import 'package:calories/core/theme/app_theme.dart';

/// Isolated CalorieOverviewWidget reactivity test
void main() {
  group('🔥 CalorieOverviewWidget UI Reactivity Tests', () {
    late ProviderContainer container;
    late OnboardingNotifier onboardingNotifier;

    setUp(() {
      container = ProviderContainer();
      onboardingNotifier = container.read(onboardingProvider.notifier);
      
      // Setup complete test profile
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

    testWidgets('🔥 CRITICAL: CalorieOverviewWidget Provider Reactivity', (tester) async {
      print('\n🔥 CRITICAL TEST: Testing CalorieOverviewWidget in isolation');
      
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: const CalorieOverviewWidget(),
            ),
          ),
        ),
      );

      // Allow loading
      await tester.pumpAndSettle(const Duration(seconds: 2));
      print('📱 CalorieOverviewWidget loaded');

      // Find all calorie-related text
      final initialTexts = _findAllTextsContaining(tester, ['kcal', 'TDEE', 'kalorier']);
      print('📊 Initial calorie texts: ${initialTexts.length} found');
      for (int i = 0; i < initialTexts.length; i++) {
        print('   [$i]: "${initialTexts[i]}"');
      }

      // Get initial profile state
      var profile = container.read(onboardingProvider).userProfile;
      print('📋 Initial profile: TDEE=${profile.tdee}, Work=${profile.isCurrentlyWorkDay}, Leisure=${profile.isLeisureActivityEnabledToday}');

      // TEST 1: Toggle leisure activity
      print('\n🔄 TEST 1: Toggling leisure activity OFF...');
      onboardingNotifier.updateLeisureActivityForToday(false);
      
      // Give widget time to rebuild
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Check updated state
      profile = container.read(onboardingProvider).userProfile;
      print('📋 After leisure toggle: TDEE=${profile.tdee}, Leisure=${profile.isLeisureActivityEnabledToday}');

      // Find updated texts
      final afterLeisureTexts = _findAllTextsContaining(tester, ['kcal', 'TDEE', 'kalorier']);
      print('📊 After leisure toggle: ${afterLeisureTexts.length} texts');
      for (int i = 0; i < afterLeisureTexts.length; i++) {
        print('   [$i]: "${afterLeisureTexts[i]}"');
      }

      // Compare
      final leisureChanged = !_listsEqual(initialTexts, afterLeisureTexts);
      print('📈 Leisure toggle caused UI change: $leisureChanged');

      // TEST 2: Toggle work day
      print('\n🔄 TEST 2: Toggling work day OFF...');
      onboardingNotifier.updateCurrentWorkDayStatus(false);
      
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 1));

      profile = container.read(onboardingProvider).userProfile;
      print('📋 After work toggle: TDEE=${profile.tdee}, Work=${profile.isCurrentlyWorkDay}');

      final afterWorkTexts = _findAllTextsContaining(tester, ['kcal', 'TDEE', 'kalorier']);
      print('📊 After work toggle: ${afterWorkTexts.length} texts');
      for (int i = 0; i < afterWorkTexts.length; i++) {
        print('   [$i]: "${afterWorkTexts[i]}"');
      }

      final workChanged = !_listsEqual(afterLeisureTexts, afterWorkTexts);
      print('📈 Work toggle caused UI change: $workChanged');

      // SUMMARY
      print('\n📊 CALORIE OVERVIEW WIDGET TEST SUMMARY:');
      print('   - Initial texts: ${initialTexts.length}');
      print('   - After leisure: ${afterLeisureTexts.length}');
      print('   - After work: ${afterWorkTexts.length}');
      print('   - Leisure UI change: $leisureChanged');
      print('   - Work UI change: $workChanged');

      // Verify basic functionality
      expect(initialTexts.isNotEmpty, true, reason: 'Should find calorie-related text in widget');
      
      // The critical assertion
      if (!leisureChanged && !workChanged) {
        print('❌ CRITICAL BUG: CalorieOverviewWidget does NOT react to provider changes!');
        fail('CalorieOverviewWidget is not reactive to onboardingProvider changes');
      } else {
        print('✅ CalorieOverviewWidget correctly reacts to provider changes');
      }
    });

    testWidgets('🔍 Provider Watch Behavior Test', (tester) async {
      print('\n🔍 PROVIDER WATCH: Testing if CalorieOverviewWidget watches providers correctly');
      
      int buildCount = 0;
      
      // Wrap CalorieOverviewWidget with a counter
      Widget testWidget = Consumer(
        builder: (context, ref, child) {
          buildCount++;
          print('🔄 Consumer build #$buildCount');
          ref.watch(onboardingProvider); // Explicit watch
          return const CalorieOverviewWidget();
        },
      );

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(body: testWidget),
          ),
        ),
      );

      await tester.pumpAndSettle();
      print('📋 Initial build count: $buildCount');

      // Trigger provider changes
      print('🔄 Triggering leisure toggle...');
      onboardingNotifier.updateLeisureActivityForToday(false);
      await tester.pump();
      print('📋 Build count after leisure toggle: $buildCount');

      print('🔄 Triggering work toggle...');
      onboardingNotifier.updateCurrentWorkDayStatus(false);
      await tester.pump();
      print('📋 Build count after work toggle: $buildCount');

      // Should have triggered rebuilds
      expect(buildCount, greaterThan(1), reason: 'Consumer should rebuild when provider changes');

      if (buildCount > 1) {
        print('✅ Provider watching triggers rebuilds correctly');
      } else {
        print('❌ Provider watching is NOT triggering rebuilds - this is the bug!');
      }
    });

    testWidgets('🧪 Direct TDEE Display Test', (tester) async {
      print('\n🧪 DIRECT TDEE TEST: Creating minimal TDEE display widget');
      
      // Create a minimal widget that should definitely update
      Widget directTdeeWidget = Consumer(
        builder: (context, ref, child) {
          final profile = ref.watch(onboardingProvider).userProfile;
          final tdee = profile.tdee;
          print('🔄 Direct TDEE widget build - TDEE: $tdee');
          return Column(
            children: [
              Text('TDEE: ${tdee.toInt()} kcal', key: const Key('tdee_text')),
              Text('Work Day: ${profile.isCurrentlyWorkDay}', key: const Key('work_text')),
              Text('Leisure: ${profile.isLeisureActivityEnabledToday}', key: const Key('leisure_text')),
            ],
          );
        },
      );

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(body: directTdeeWidget),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Get initial values
      var tdeeText = tester.widget<Text>(find.byKey(const Key('tdee_text'))).data!;
      var workText = tester.widget<Text>(find.byKey(const Key('work_text'))).data!;
      var leisureText = tester.widget<Text>(find.byKey(const Key('leisure_text'))).data!;
      
      print('📋 Initial values:');
      print('   - TDEE: $tdeeText');
      print('   - Work: $workText');
      print('   - Leisure: $leisureText');

      // Toggle leisure
      onboardingNotifier.updateLeisureActivityForToday(false);
      await tester.pump();

      var newTdeeText = tester.widget<Text>(find.byKey(const Key('tdee_text'))).data!;
      var newLeisureText = tester.widget<Text>(find.byKey(const Key('leisure_text'))).data!;
      
      print('📋 After leisure toggle:');
      print('   - TDEE: $newTdeeText');
      print('   - Leisure: $newLeisureText');

      // Check changes
      final tdeeChanged = tdeeText != newTdeeText;
      final leisureChanged = leisureText != newLeisureText;
      
      print('📈 Changes detected:');
      print('   - TDEE changed: $tdeeChanged');
      print('   - Leisure changed: $leisureChanged');

      expect(tdeeChanged, true, reason: 'TDEE should change when leisure activity is toggled');
      expect(leisureChanged, true, reason: 'Leisure text should change when toggled');

      if (tdeeChanged && leisureChanged) {
        print('✅ Direct provider watching works perfectly');
      } else {
        print('❌ Even direct provider watching is broken!');
      }
    });
  });
}

/// Helper to find all text widgets containing any of the given patterns
List<String> _findAllTextsContaining(WidgetTester tester, List<String> patterns) {
  final foundTexts = <String>[];
  final textWidgets = find.byType(Text);
  
  for (final textWidget in textWidgets.evaluate()) {
    final text = (textWidget.widget as Text).data;
    if (text != null) {
      for (final pattern in patterns) {
        if (text.contains(pattern)) {
          foundTexts.add(text);
          break; // Don't add same text multiple times
        }
      }
    }
  }
  
  return foundTexts;
}

/// Helper to compare lists
bool _listsEqual<T>(List<T> list1, List<T> list2) {
  if (list1.length != list2.length) return false;
  for (int i = 0; i < list1.length; i++) {
    if (list1[i] != list2[i]) return false;
  }
  return true;
} 