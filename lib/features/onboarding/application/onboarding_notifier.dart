import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user_profile_model.dart';
import '../domain/onboarding_step.dart';
import '../infrastructure/onboarding_storage_service.dart';
import 'onboarding_state.dart';

/// Onboarding state notifier
class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(const OnboardingState()) {
    _loadSavedProgress();
  }

  /// Load saved progress from storage
  Future<void> _loadSavedProgress() async {
    print('🔍 Loading saved progress...');
    
    try {
      final savedProfile = await OnboardingStorageService.loadUserProfile();
      
      if (savedProfile != null) {
        print('✅ Onboarding already completed, loading permanent profile...');
        print('📥 Found completed profile: ${savedProfile.name}');
        
        // ALWAYS FORCE RECALCULATION for existing users to fix old calculations
        final recalculatedTargetCalories = _calculateTargetCalories(savedProfile);
        
        print('🔄 FORCING recalculation: old=${savedProfile.targetCalories} -> new=$recalculatedTargetCalories');
        print('🔍 Current settings:');
        print('  - Activity tracking: ${savedProfile.activityTrackingPreference}');
        print('  - Work activity: ${savedProfile.workActivityLevel}');
        print('  - Leisure activity: ${savedProfile.leisureActivityLevel}');
        print('  - Leisure enabled today: ${savedProfile.isLeisureActivityEnabledToday}');
        print('  - BMR: ${savedProfile.bmr.toInt()}');
        print('  - TDEE: ${savedProfile.tdee.toInt()}');
        
        final updatedProfile = savedProfile.copyWith(
          targetCalories: recalculatedTargetCalories,
        );
        
        // Save the corrected profile
        await OnboardingStorageService.saveUserProfile(updatedProfile);
        
        state = state.copyWith(
          userProfile: updatedProfile,
          currentStep: OnboardingStep.summary,
        );
        print('✅ Profile FORCE updated with correct target calories: $recalculatedTargetCalories');
        
        _calculateTargets();
        print('✅ Loaded completed profile successfully');
      } else {
        print('🔍 No saved profile found, starting fresh onboarding');
        state = state.copyWith(
          currentStep: OnboardingStep.basicInfo,
        );
      }
    } catch (e) {
      print('❌ Error loading saved progress: $e');
      state = state.copyWith(
        currentStep: OnboardingStep.basicInfo,
      );
    }
  }

  /// Initialize work day status based on automatic detection
  UserProfileModel _initializeWorkDayStatus(UserProfileModel profile) {
    if (profile.useAutomaticWeekdayDetection) {
      final now = DateTime.now();
      final isWorkDay = now.weekday >= 1 && now.weekday <= 5; // Monday = 1, Sunday = 7
      
      return profile.copyWith(
        isCurrentlyWorkDay: isWorkDay,
        // Reset leisure activity to enabled each day (user can disable if needed)
        isLeisureActivityEnabledToday: true,
      );
    }
    return profile;
  }

  /// Save updates for completed users directly to permanent storage (no auto-save logging)
  Future<void> _saveCompletedUserUpdate() async {
    if (state.userProfile.isOnboardingCompleted) {
      try {
        await OnboardingStorageService.saveUserProfile(state.userProfile);
      } catch (e) {
        print('❌ Failed to save user profile update: $e');
      }
    }
  }

  /// Auto-save progress after each update
  Future<void> _autoSaveProgress() async {
    try {
      if (state.userProfile.isOnboardingCompleted) {
        // For completed users, do nothing - their profile is already permanently saved
        // No auto-save needed to avoid excessive logging
        return;
      } else {
        // For incomplete onboarding, save as partial progress
        await OnboardingStorageService.savePartialProgress(state.userProfile);
        print('✅ Auto-save successful');
      }
    } catch (e) {
      print('❌ Auto-save failed: $e');
    }
  }

  /// Navigate to next step
  void nextStep() {
    if (!state.canProceedToNext) return;

    final nextStep = switch (state.currentStep) {
      OnboardingStep.basicInfo => OnboardingStep.healthInfo,
      OnboardingStep.healthInfo => OnboardingStep.workActivity,
      OnboardingStep.workActivity => OnboardingStep.leisureActivity,
      OnboardingStep.leisureActivity => OnboardingStep.goals,
      OnboardingStep.goals => OnboardingStep.calorieEducation,
      OnboardingStep.calorieEducation => OnboardingStep.summary,
      OnboardingStep.summary => OnboardingStep.summary,
    };

    state = state.copyWith(currentStep: nextStep);
  }

  /// Navigate to previous step
  void previousStep() {
    final previousStep = switch (state.currentStep) {
      OnboardingStep.basicInfo => OnboardingStep.basicInfo,
      OnboardingStep.healthInfo => OnboardingStep.basicInfo,
      OnboardingStep.workActivity => OnboardingStep.healthInfo,
      OnboardingStep.leisureActivity => OnboardingStep.workActivity,
      OnboardingStep.goals => OnboardingStep.leisureActivity,
      OnboardingStep.calorieEducation => OnboardingStep.goals,
      OnboardingStep.summary => OnboardingStep.calorieEducation,
    };

    state = state.copyWith(currentStep: previousStep);
  }

  /// Navigate to specific step
  void goToStep(OnboardingStep step) {
    state = state.copyWith(currentStep: step);
  }

  /// Update user name
  void updateName(String name) {
    state = state.copyWith(
      userProfile: state.userProfile.copyWith(name: name),
    );
    if (state.userProfile.isOnboardingCompleted) {
      _saveCompletedUserUpdate();
    } else {
      _autoSaveProgress();
    }
  }

  /// Update date of birth
  void updateDateOfBirth(DateTime dateOfBirth) {
    state = state.copyWith(
      userProfile: state.userProfile.copyWith(dateOfBirth: dateOfBirth),
    );
    _calculateTargets();
    // Auto-save is handled by _calculateTargets for completed users
    if (!state.userProfile.isOnboardingCompleted) {
      _autoSaveProgress();
    }
  }

  /// Update gender
  void updateGender(Gender gender) {
    state = state.copyWith(
      userProfile: state.userProfile.copyWith(gender: gender),
    );
    _calculateTargets();
    // Auto-save is handled by _calculateTargets for completed users
    if (!state.userProfile.isOnboardingCompleted) {
      _autoSaveProgress();
    }
  }

  /// Update height in cm
  void updateHeight(double heightCm) {
    state = state.copyWith(
      userProfile: state.userProfile.copyWith(heightCm: heightCm),
    );
    _calculateTargets();
    // Auto-save is handled by _calculateTargets for completed users
    if (!state.userProfile.isOnboardingCompleted) {
      _autoSaveProgress();
    }
  }

  /// Update current weight in kg
  void updateCurrentWeight(double currentWeightKg) {
    // Auto-initialize target weight if not set yet
    final targetWeight = state.userProfile.targetWeightKg <= 0 
        ? currentWeightKg 
        : state.userProfile.targetWeightKg;
    
    state = state.copyWith(
      userProfile: state.userProfile.copyWith(
        currentWeightKg: currentWeightKg,
        targetWeightKg: targetWeight,
      ),
    );
    _calculateTargets();
    // Auto-save is handled by _calculateTargets for completed users
    if (!state.userProfile.isOnboardingCompleted) {
      _autoSaveProgress();
    }
  }

  /// Update target weight in kg
  void updateTargetWeight(double targetWeightKg) {
    state = state.copyWith(
      userProfile: state.userProfile.copyWith(targetWeightKg: targetWeightKg),
    );
    _calculateTargets();
    // Auto-save is handled by _calculateTargets for completed users
    if (!state.userProfile.isOnboardingCompleted) {
      _autoSaveProgress();
    }
  }

  /// Update goal type
  void updateGoalType(GoalType goalType) {
    // Set default weekly goal based on goal type for consistent calculations
    double defaultWeeklyGoal = switch (goalType) {
      GoalType.weightLoss => 0.5, // 0.5 kg per week loss
      GoalType.weightGain => 0.5, // 0.5 kg per week gain
      GoalType.muscleGain => 0.3, // 0.3 kg per week gain (slower for muscle)
      GoalType.weightMaintenance => 0.0, // No weight change
    };
    
    state = state.copyWith(
      userProfile: state.userProfile.copyWith(
        goalType: goalType,
        weeklyGoalKg: defaultWeeklyGoal,
      ),
    );
    _calculateTargets();
    // Auto-save is handled by _calculateTargets for completed users
    if (!state.userProfile.isOnboardingCompleted) {
      _autoSaveProgress();
    }
  }

  /// Update activity level
  void updateActivityLevel(ActivityLevel activityLevel) {
    state = state.copyWith(
      userProfile: state.userProfile.copyWith(activityLevel: activityLevel),
    );
    _calculateTargets();
    // Auto-save is handled by _calculateTargets for completed users
    if (!state.userProfile.isOnboardingCompleted) {
      _autoSaveProgress();
    }
  }

  /// Update activity tracking preference
  void updateActivityTrackingPreference(ActivityTrackingPreference preference) {
    state = state.copyWith(
      userProfile: state.userProfile.copyWith(activityTrackingPreference: preference),
    );
    _calculateTargets();
    // Auto-save is handled by _calculateTargets for completed users
    if (!state.userProfile.isOnboardingCompleted) {
      _autoSaveProgress();
    }
  }

  /// Update work activity level
  void updateWorkActivityLevel(WorkActivityLevel workActivityLevel) {
    state = state.copyWith(
      userProfile: state.userProfile.copyWith(workActivityLevel: workActivityLevel),
    );
    _calculateTargets();
    // Auto-save is handled by _calculateTargets for completed users
    if (!state.userProfile.isOnboardingCompleted) {
      _autoSaveProgress();
    }
  }

  /// Update leisure activity level
  void updateLeisureActivityLevel(LeisureActivityLevel leisureActivityLevel) {
    state = state.copyWith(
      userProfile: state.userProfile.copyWith(leisureActivityLevel: leisureActivityLevel),
    );
    _calculateTargets();
    // Auto-save is handled by _calculateTargets for completed users
    if (!state.userProfile.isOnboardingCompleted) {
      _autoSaveProgress();
    }
  }

  /// Update weekday detection preference
  void updateWeekdayDetection(bool useAutomatic) {
    state = state.copyWith(
      userProfile: state.userProfile.copyWith(useAutomaticWeekdayDetection: useAutomatic),
    );
    _calculateTargets();
    // Auto-save is handled by _calculateTargets for completed users
    if (!state.userProfile.isOnboardingCompleted) {
      _autoSaveProgress();
    }
  }

  /// Update current work day status (manual override)
  void updateCurrentWorkDayStatus(bool isWorkDay) {
    print('🔵 updateCurrentWorkDayStatus CALLED with: isWorkDay=$isWorkDay');
    print('🔵 BEFORE state update - Profile: isWorkDay=${state.userProfile.isCurrentlyWorkDay}, isLeisure=${state.userProfile.isLeisureActivityEnabledToday}');
    state = state.copyWith(
      userProfile: state.userProfile.copyWith(isCurrentlyWorkDay: isWorkDay),
    );
    print('🔵 AFTER state update - Profile: isWorkDay=${state.userProfile.isCurrentlyWorkDay}, isLeisure=${state.userProfile.isLeisureActivityEnabledToday}');
    _calculateTargets();
    // Auto-save is handled by _calculateTargets for completed users
    if (!state.userProfile.isOnboardingCompleted) {
      _autoSaveProgress();
    }
  }

  /// Update leisure activity enabled status for today
  void updateLeisureActivityForToday(bool isEnabled) {
    print('🟢 updateLeisureActivityForToday CALLED with: isEnabled=$isEnabled');
    print('🟢 BEFORE state update - Profile: isWorkDay=${state.userProfile.isCurrentlyWorkDay}, isLeisure=${state.userProfile.isLeisureActivityEnabledToday}');
    state = state.copyWith(
      userProfile: state.userProfile.copyWith(isLeisureActivityEnabledToday: isEnabled),
    );
    print('🟢 AFTER state update - Profile: isWorkDay=${state.userProfile.isCurrentlyWorkDay}, isLeisure=${state.userProfile.isLeisureActivityEnabledToday}');
    _calculateTargets();
    // Auto-save is handled by _calculateTargets for completed users
    if (!state.userProfile.isOnboardingCompleted) {
      _autoSaveProgress();
    }
  }

  /// Update weekly goal weight change
  void updateWeeklyGoal(double weeklyGoalKg) {
    state = state.copyWith(
      userProfile: state.userProfile.copyWith(weeklyGoalKg: weeklyGoalKg),
    );
    _calculateTargets();
    // Auto-save is handled by _calculateTargets for completed users
    if (!state.userProfile.isOnboardingCompleted) {
      _autoSaveProgress();
    }
  }

  /// Complete onboarding
  Future<void> completeOnboarding() async {
    state = state.copyWith(isLoading: true, hasError: false);
    
    try {
      final completedProfile = state.userProfile.copyWith(
        isOnboardingCompleted: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Save to permanent storage
      final saveSuccess = await OnboardingStorageService.saveUserProfile(completedProfile);
      
      if (saveSuccess) {
        // Clear partial progress since we're done
        await OnboardingStorageService.clearPartialProgress();
        
        // Update profile but keep loading state true and don't change step
        // This prevents UI flashing before navigation
        state = state.copyWith(
          userProfile: completedProfile,
          // Keep currentStep as is and keep loading true
        );
      } else {
        throw Exception('Failed to save user profile');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Kunne ikke gemme dine oplysninger. Prøv igen.',
      );
    }
  }

  /// Reset onboarding (useful for testing or re-doing onboarding)
  Future<void> reset() async {
    await OnboardingStorageService.clearOnboardingData();
    await OnboardingStorageService.clearPartialProgress();
    state = const OnboardingState();
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(hasError: false, errorMessage: null);
  }

  /// Calculate target calories based on user profile
  int _calculateTargetCalories(UserProfileModel profile) {
    print('🟡 _calculateTargetCalories USING Profile: isWorkDay=${profile.isCurrentlyWorkDay}, isLeisure=${profile.isLeisureActivityEnabledToday}, TDEE=${profile.tdee}');
    if (profile.dateOfBirth == null || 
        profile.currentWeightKg <= 0 || 
        profile.heightCm <= 0 ||
        profile.gender == null ||
        profile.goalType == null) {
      return 0;
    }

    // Use the profile's TDEE calculation (which is now fixed)
    final tdee = profile.tdee;
    
    // Apply goal-based calorie adjustment
    double targetCalories = tdee;
    
    if (profile.goalType == GoalType.weightLoss) {
      // Weight loss: create caloric deficit
      final weeklyDeficitKcal = profile.weeklyGoalKg * 7700.0; // 1 kg fat ≈ 7700 kcal
      final dailyDeficitKcal = weeklyDeficitKcal / 7.0;
      targetCalories = tdee - dailyDeficitKcal;
    } else if (profile.goalType == GoalType.weightGain || profile.goalType == GoalType.muscleGain) {
      // Weight gain: create caloric surplus
      final weeklySurplusKcal = profile.weeklyGoalKg * 7700.0;
      final dailySurplusKcal = weeklySurplusKcal / 7.0;
      targetCalories = tdee + dailySurplusKcal;
    } else if (profile.goalType == GoalType.weightMaintenance) {
      // Maintenance: no adjustment needed
      targetCalories = tdee;
    }

    // Safety bounds
    return targetCalories.clamp(800.0, 4000.0).round();
  }

  /// Calculate macronutrient targets
  ({double protein, double fat, double carbs}) _calculateMacronutrients(int calories) {
    if (calories <= 0) return (protein: 0.0, fat: 0.0, carbs: 0.0);

    // Standard macronutrient distribution
    const proteinPercentage = 0.25; // 25%
    const fatPercentage = 0.30; // 30%
    const carbsPercentage = 0.45; // 45%

    final protein = (calories * proteinPercentage) / 4; // 4 kcal per gram
    final fat = (calories * fatPercentage) / 9; // 9 kcal per gram
    final carbs = (calories * carbsPercentage) / 4; // 4 kcal per gram

    return (
      protein: protein,
      fat: fat,
      carbs: carbs,
    );
  }

  void _calculateTargets() {
    final profile = state.userProfile;
    print('🟣 _calculateTargets CALLED');
    print('🟣 Initial Profile for _calculateTargets: isWorkDay=${profile.isCurrentlyWorkDay}, isLeisure=${profile.isLeisureActivityEnabledToday}');

    // UserProfileModel handles its own BMR and TDEE calculation internally via getters
    // We just need to ensure the profile object itself is up-to-date with toggle changes before these getters are implicitly called
    // when _calculateTargetCalories accesses profile.tdee

    // The 'profile' instance here already reflects the latest toggle states
    // (isCurrentlyWorkDay, isLeisureActivityEnabledToday) due to calls like:
    // state = state.copyWith(userProfile: state.userProfile.copyWith(isCurrentlyWorkDay: isWorkDay));
    // BEFORE _calculateTargets() is called.

    // So, when _calculateTargetCalories(profile) is called,
    // profile.tdee will use the current toggle states.

    final targetCalories = _calculateTargetCalories(profile);
    
    // We don't need to explicitly set bmr and tdee on the profile using copyWith here,
    // as they are getters on UserProfileModel that calculate based on its current state.
    // We only need to update the targetCalories.
    final updatedProfile = profile.copyWith(
      targetCalories: targetCalories, // targetCalories is already an int
    );
    print('🟣 Profile after Target Calories ($targetCalories): isWorkDay=${updatedProfile.isCurrentlyWorkDay}, isLeisure=${updatedProfile.isLeisureActivityEnabledToday}, BMR=${updatedProfile.bmr}, TDEE=${updatedProfile.tdee}');

    state = state.copyWith(
      userProfile: updatedProfile,
    );
    
    // Always save for completed users when target calories change
    if (profile.isOnboardingCompleted) {
      _saveCompletedUserUpdate();
    }
  }

  /// Restart onboarding flow (for editing existing data)
  Future<void> restartOnboardingFlow() async {
    print('🔄 Restarting onboarding flow for editing...');
    
    // Do NOT reset data - just restart the flow to allow editing
    // Keep all existing userProfile data so user can edit it
    state = state.copyWith(
      currentStep: OnboardingStep.basicInfo,
      isEditingFromSummary: false,
    );
    
    print('✅ Onboarding flow restarted for editing (data preserved)');
  }

  /// Force recalculate targets for existing users (fixes old calculations)
  Future<void> forceRecalculateTargets() async {
    print('🔄 Force recalculating targets for existing user...');
    
    // Force recalculation
    _calculateTargets();
    
    // Save the updated profile to permanent storage
    if (state.userProfile.isOnboardingCompleted) {
      await _saveCompletedUserUpdate();
      print('✅ Targets recalculated and saved!');
      print('- New Target Calories: ${state.userProfile.targetCalories} kcal');
      print('- BMR: ${state.userProfile.bmr.toInt()} kcal');
      print('- TDEE: ${state.userProfile.tdee.toInt()} kcal');
    }
  }
}

/// Provider for onboarding notifier
final onboardingProvider = StateNotifierProvider<OnboardingNotifier, OnboardingState>(
  (ref) => OnboardingNotifier(),
); 