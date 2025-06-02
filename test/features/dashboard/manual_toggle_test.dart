import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calories/features/onboarding/application/onboarding_notifier.dart';
import 'package:calories/features/onboarding/domain/user_profile_model.dart';

/// Manual test - run this and check console output to verify provider reactivity
void main() {
  test('🔧 Manual Provider Reactivity Test', () async {
    print('\n🔧 MANUAL TEST: Verifying onboarding provider reactivity');
    
    final container = ProviderContainer();
    final onboardingNotifier = container.read(onboardingProvider.notifier);
    
    // Setup complete profile
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
    
    // Test profile state changes
    print('\n📋 Testing provider state changes...');
    
    var profile = container.read(onboardingProvider).userProfile;
    print('✅ Initial: Work=${profile.isCurrentlyWorkDay}, Leisure=${profile.isLeisureActivityEnabledToday}, TDEE=${profile.tdee}');
    
    // Toggle leisure
    onboardingNotifier.updateLeisureActivityForToday(false);
    profile = container.read(onboardingProvider).userProfile;
    print('✅ After leisure OFF: Work=${profile.isCurrentlyWorkDay}, Leisure=${profile.isLeisureActivityEnabledToday}, TDEE=${profile.tdee}');
    
    // Toggle work
    onboardingNotifier.updateCurrentWorkDayStatus(false);
    profile = container.read(onboardingProvider).userProfile;
    print('✅ After work OFF: Work=${profile.isCurrentlyWorkDay}, Leisure=${profile.isLeisureActivityEnabledToday}, TDEE=${profile.tdee}');
    
    // Toggle both back on
    onboardingNotifier.updateLeisureActivityForToday(true);
    onboardingNotifier.updateCurrentWorkDayStatus(true);
    profile = container.read(onboardingProvider).userProfile;
    print('✅ Final (both ON): Work=${profile.isCurrentlyWorkDay}, Leisure=${profile.isLeisureActivityEnabledToday}, TDEE=${profile.tdee}');
    
    print('\n🎯 Provider test completed - check that TDEE values changed correctly');
    
    container.dispose();
  });
} 