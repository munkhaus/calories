import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calories/features/onboarding/application/onboarding_notifier.dart';
import 'package:calories/features/onboarding/domain/user_profile_model.dart';

/// Unit test to identify provider reactivity issues
void main() {
  group('CalorieOverviewWidget Provider Reactivity Tests', () {
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

    test('🔍 Test 1: Provider State Updates on Leisure Toggle', () {
      print('\n🧪 TEST 1: Provider state updates on leisure toggle');
      
      // Get initial state
      var profile = container.read(onboardingProvider).userProfile;
      final initialTdee = profile.tdee;
      final initialTargetCalories = profile.targetCalories;
      
      print('📋 Initial State:');
      print('   - Leisure Enabled: ${profile.isLeisureActivityEnabledToday}');
      print('   - TDEE: $initialTdee');
      print('   - Target Calories: $initialTargetCalories');
      
      expect(profile.isLeisureActivityEnabledToday, true);
      
      // Toggle leisure activity off
      onboardingNotifier.updateLeisureActivityForToday(false);
      
      // Get updated state
      profile = container.read(onboardingProvider).userProfile;
      final updatedTdee = profile.tdee;
      final updatedTargetCalories = profile.targetCalories;
      
      print('📋 After Toggle:');
      print('   - Leisure Enabled: ${profile.isLeisureActivityEnabledToday}');
      print('   - TDEE: $updatedTdee');
      print('   - Target Calories: $updatedTargetCalories');
      
      expect(profile.isLeisureActivityEnabledToday, false);
      expect(updatedTdee, lessThan(initialTdee), reason: 'TDEE should decrease when leisure activity is disabled');
      
      print('✅ TEST 1 PASSED: Provider state updates correctly');
    });

    test('🔍 Test 2: Provider State Updates on Work Day Toggle', () {
      print('\n🧪 TEST 2: Provider state updates on work day toggle');
      
      // Get initial state
      var profile = container.read(onboardingProvider).userProfile;
      final initialTdee = profile.tdee;
      final initialTargetCalories = profile.targetCalories;
      
      print('📋 Initial State:');
      print('   - Work Day: ${profile.isCurrentlyWorkDay}');
      print('   - TDEE: $initialTdee');
      print('   - Target Calories: $initialTargetCalories');
      
      expect(profile.isCurrentlyWorkDay, true);
      
      // Toggle work day off
      onboardingNotifier.updateCurrentWorkDayStatus(false);
      
      // Get updated state
      profile = container.read(onboardingProvider).userProfile;
      final updatedTdee = profile.tdee;
      final updatedTargetCalories = profile.targetCalories;
      
      print('📋 After Toggle:');
      print('   - Work Day: ${profile.isCurrentlyWorkDay}');
      print('   - TDEE: $updatedTdee');
      print('   - Target Calories: $updatedTargetCalories');
      
      expect(profile.isCurrentlyWorkDay, false);
      expect(updatedTdee, lessThan(initialTdee), reason: 'TDEE should decrease when work day is disabled');
      
      print('✅ TEST 2 PASSED: Provider state updates correctly');
    });

    test('🔍 Test 3: Provider Notification Mechanism', () {
      print('\n🧪 TEST 3: Provider notification mechanism');
      
      int notificationCount = 0;
      UserProfileModel? lastProfile;
      
      // Listen to provider changes
      final subscription = container.listen(
        onboardingProvider,
        (previous, next) {
          notificationCount++;
          lastProfile = next.userProfile;
          print('📡 Notification #$notificationCount');
          print('   - Previous TDEE: ${previous?.userProfile.tdee}');
          print('   - New TDEE: ${next.userProfile.tdee}');
        },
      );
      
      print('📋 Initial notification count: $notificationCount');
      
      // Trigger leisure toggle
      onboardingNotifier.updateLeisureActivityForToday(false);
      print('📋 After leisure toggle: $notificationCount notifications');
      
      // Trigger work day toggle
      onboardingNotifier.updateCurrentWorkDayStatus(false);
      print('📋 After work toggle: $notificationCount notifications');
      
      expect(notificationCount, greaterThan(0), reason: 'Provider should send notifications');
      expect(lastProfile, isNotNull, reason: 'Should have received profile updates');
      
      subscription.close();
      
      print('✅ TEST 3 PASSED: Provider notifications working');
    });

    test('🔍 Test 4: Multiple Toggle Sequence', () {
      print('\n🧪 TEST 4: Multiple toggle sequence');
      
      List<double> tdeeHistory = [];
      List<int> targetCaloriesHistory = [];
      
      // Record initial state
      var profile = container.read(onboardingProvider).userProfile;
      tdeeHistory.add(profile.tdee);
      targetCaloriesHistory.add(profile.targetCalories);
      
      print('📋 Initial: TDEE=${profile.tdee}, Target=${profile.targetCalories}');
      
      // Toggle 1: Leisure OFF
      onboardingNotifier.updateLeisureActivityForToday(false);
      profile = container.read(onboardingProvider).userProfile;
      tdeeHistory.add(profile.tdee);
      targetCaloriesHistory.add(profile.targetCalories);
      print('📋 Leisure OFF: TDEE=${profile.tdee}, Target=${profile.targetCalories}');
      
      // Toggle 2: Work Day OFF
      onboardingNotifier.updateCurrentWorkDayStatus(false);
      profile = container.read(onboardingProvider).userProfile;
      tdeeHistory.add(profile.tdee);
      targetCaloriesHistory.add(profile.targetCalories);
      print('📋 Work OFF: TDEE=${profile.tdee}, Target=${profile.targetCalories}');
      
      // Toggle 3: Leisure ON
      onboardingNotifier.updateLeisureActivityForToday(true);
      profile = container.read(onboardingProvider).userProfile;
      tdeeHistory.add(profile.tdee);
      targetCaloriesHistory.add(profile.targetCalories);
      print('📋 Leisure ON: TDEE=${profile.tdee}, Target=${profile.targetCalories}');
      
      // Toggle 4: Work Day ON
      onboardingNotifier.updateCurrentWorkDayStatus(true);
      profile = container.read(onboardingProvider).userProfile;
      tdeeHistory.add(profile.tdee);
      targetCaloriesHistory.add(profile.targetCalories);
      print('📋 Work ON: TDEE=${profile.tdee}, Target=${profile.targetCalories}');
      
      print('\n📊 TDEE History: $tdeeHistory');
      print('📊 Target Calories History: $targetCaloriesHistory');
      
      // Verify each step produced different values
      expect(tdeeHistory.toSet().length, greaterThan(1), reason: 'TDEE should change with toggles');
      
      // Final TDEE should match initial (full circle)
      expect(tdeeHistory.last, tdeeHistory.first, reason: 'Final state should match initial state');
      
      print('✅ TEST 4 PASSED: Multiple toggle sequence works correctly');
    });

    test('🔍 Test 5: Target Calories vs TDEE Relationship', () {
      print('\n🧪 TEST 5: Target calories vs TDEE relationship');
      
      // Test different combinations
      final testCases = [
        {'work': true, 'leisure': true, 'name': 'Both ON'},
        {'work': true, 'leisure': false, 'name': 'Work ON, Leisure OFF'},
        {'work': false, 'leisure': true, 'name': 'Work OFF, Leisure ON'},
        {'work': false, 'leisure': false, 'name': 'Both OFF'},
      ];
      
      Map<String, Map<String, double>> results = {};
      
      for (final testCase in testCases) {
        onboardingNotifier.updateCurrentWorkDayStatus(testCase['work'] as bool);
        onboardingNotifier.updateLeisureActivityForToday(testCase['leisure'] as bool);
        
        final profile = container.read(onboardingProvider).userProfile;
        results[testCase['name'] as String] = {
          'tdee': profile.tdee,
          'targetCalories': profile.targetCalories.toDouble(),
        };
        
        print('📋 ${testCase['name']}: TDEE=${profile.tdee.toInt()}, Target=${profile.targetCalories}');
      }
      
      // Verify TDEE hierarchy
      final bothOn = results['Both ON']!['tdee']!;
      final workOnLeisureOff = results['Work ON, Leisure OFF']!['tdee']!;
      final workOffLeisureOn = results['Work OFF, Leisure ON']!['tdee']!;
      final bothOff = results['Both OFF']!['tdee']!;
      
      expect(bothOn, greaterThan(workOnLeisureOff), reason: 'Both ON should be highest');
      expect(bothOn, greaterThan(workOffLeisureOn), reason: 'Both ON should be highest');
      expect(bothOff, lessThan(workOnLeisureOff), reason: 'Both OFF should be lowest');
      expect(bothOff, lessThan(workOffLeisureOn), reason: 'Both OFF should be lowest');
      
      print('✅ TEST 5 PASSED: TDEE hierarchy is correct');
    });

    test('🔍 Test 6: CRITICAL - Provider Watch Simulation', () {
      print('\n🧪 TEST 6 (CRITICAL): Simulating CalorieOverviewWidget provider watching');
      
      // Simulate what CalorieOverviewWidget should do
      UserProfileModel? watchedProfile;
      int watchCallCount = 0;
      
      // Simulate ref.watch(onboardingProvider)
      final subscription = container.listen(
        onboardingProvider,
        (previous, next) {
          watchCallCount++;
          watchedProfile = next.userProfile;
          print('🔄 Widget would rebuild #$watchCallCount');
          print('   - New TDEE: ${next.userProfile.tdee}');
          print('   - New Target Calories: ${next.userProfile.targetCalories}');
        },
      );
      
      print('📋 Starting watch simulation...');
      
      // Initial "watch"
      watchedProfile = container.read(onboardingProvider).userProfile;
      print('📋 Initial watch: TDEE=${watchedProfile?.tdee}, Target=${watchedProfile?.targetCalories}');
      
      // Simulate toggle operations like in real app
      print('\n🔄 Simulating leisure toggle...');
      onboardingNotifier.updateLeisureActivityForToday(false);
      
      print('\n🔄 Simulating work day toggle...');
      onboardingNotifier.updateCurrentWorkDayStatus(false);
      
      print('\n📊 Watch Summary:');
      print('   - Total rebuilds triggered: $watchCallCount');
      print('   - Final TDEE: ${watchedProfile?.tdee}');
      print('   - Final Target Calories: ${watchedProfile?.targetCalories}');
      
      expect(watchCallCount, greaterThan(0), reason: 'Widget should have been notified to rebuild');
      
      subscription.close();
      
      if (watchCallCount > 0) {
        print('✅ TEST 6 PASSED: Widget would receive rebuild notifications');
      } else {
        print('❌ TEST 6 FAILED: Widget would NOT receive rebuild notifications - THIS IS THE BUG');
      }
    });
  });
} 