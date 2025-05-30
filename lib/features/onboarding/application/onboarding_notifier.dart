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
    
    // Check if onboarding is already completed
    final completedProfile = await OnboardingStorageService.loadUserProfile();
    if (completedProfile != null) {
      print('✅ Onboarding already completed, loading permanent profile...');
      print('📥 Found completed profile: ${completedProfile.name}');
      
      // Initialize work day status if using automatic detection
      final updatedProfile = _initializeWorkDayStatus(completedProfile);
      
      state = state.copyWith(
        userProfile: updatedProfile,
        currentStep: OnboardingStep.completed,
      );
      
      _calculateTargets();
      print('✅ Loaded completed profile successfully');
      return;
    }
    
    // Otherwise, load partial progress
    final partialProfile = await OnboardingStorageService.loadPartialProgress();
    if (partialProfile != null) {
      print('📥 Found partial progress, continuing from ${partialProfile.name}');
      state = state.copyWith(userProfile: partialProfile);
      _calculateTargets();
    } else {
      print('📭 No saved progress found, starting fresh');
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
      OnboardingStep.summary => OnboardingStep.completed,
      OnboardingStep.completed => OnboardingStep.completed,
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
      OnboardingStep.completed => OnboardingStep.summary,
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
    state = state.copyWith(
      userProfile: state.userProfile.copyWith(isCurrentlyWorkDay: isWorkDay),
    );
    _calculateTargets();
    // Auto-save is handled by _calculateTargets for completed users
    if (!state.userProfile.isOnboardingCompleted) {
      _autoSaveProgress();
    }
  }

  /// Update leisure activity enabled status for today
  void updateLeisureActivityForToday(bool isEnabled) {
    state = state.copyWith(
      userProfile: state.userProfile.copyWith(isLeisureActivityEnabledToday: isEnabled),
    );
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
        
        state = state.copyWith(
          userProfile: completedProfile,
          currentStep: OnboardingStep.completed,
          isLoading: false,
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
    if (profile.dateOfBirth == null || 
        profile.currentWeightKg <= 0 || 
        profile.heightCm <= 0 ||
        profile.gender == null ||
        profile.goalType == null) {
      return 0;
    }

    // Calculate age from dateOfBirth directly to avoid Freezed issues
    final now = DateTime.now();
    int age = now.year - profile.dateOfBirth!.year;
    if (now.month < profile.dateOfBirth!.month ||
        (now.month == profile.dateOfBirth!.month && now.day < profile.dateOfBirth!.day)) {
      age--;
    }

    if (age <= 0) return 0;

    // Calculate BMR using Mifflin-St Jeor equation (more precise calculation)
    double bmr;
    if (profile.gender == Gender.male) {
      bmr = (10.0 * profile.currentWeightKg) + (6.25 * profile.heightCm) - (5.0 * age) + 5.0;
    } else {
      bmr = (10.0 * profile.currentWeightKg) + (6.25 * profile.heightCm) - (5.0 * age) - 161.0;
    }

    double tdee;
    
    // Use new activity system if available
    if (profile.workActivityLevel != null && profile.leisureActivityLevel != null) {
      // Calculate work activity multiplier based on current day
      double workMultiplier = 1.0;
      if (profile.isCurrentlyWorkDay) {
        workMultiplier = switch (profile.workActivityLevel!) {
          WorkActivityLevel.sedentary => 1.2,
          WorkActivityLevel.light => 1.375,
          WorkActivityLevel.moderate => 1.55,
          WorkActivityLevel.heavy => 1.725,
          WorkActivityLevel.veryHeavy => 1.9,
        };
      } else {
        // Non-work day: sedentary baseline
        workMultiplier = 1.2;
      }
      
      // Calculate leisure activity addition
      double leisureAddition = 0.0;
      if (profile.isLeisureActivityEnabledToday) {
        leisureAddition = switch (profile.leisureActivityLevel!) {
          LeisureActivityLevel.sedentary => 0.0,
          LeisureActivityLevel.lightlyActive => 0.155, // ~155 calories
          LeisureActivityLevel.moderatelyActive => 0.35, // ~350 calories
          LeisureActivityLevel.veryActive => 0.525, // ~525 calories
          LeisureActivityLevel.extraActive => 0.7, // ~700 calories
        };
      }
      
      tdee = (bmr * workMultiplier) + (bmr * leisureAddition);
    } else {
      // Fall back to legacy activity level system
      if (profile.activityLevel == null) return 0;
      
      final activityMultiplier = switch (profile.activityLevel!) {
        ActivityLevel.sedentary => 1.2,
        ActivityLevel.lightlyActive => 1.375,
        ActivityLevel.moderatelyActive => 1.55,
        ActivityLevel.veryActive => 1.725,
        ActivityLevel.extraActive => 1.9,
      };
      
      tdee = bmr * activityMultiplier;
    }

    // Adjust for goal type with consistent calculation
    switch (profile.goalType!) {
      case GoalType.weightLoss:
        // Create caloric deficit: 1 kg fat = 7700 kcal
        final weeklyDeficit = profile.weeklyGoalKg * 7700.0;
        final dailyDeficit = weeklyDeficit / 7.0;
        tdee = tdee - dailyDeficit;
        break;
      case GoalType.weightGain:
      case GoalType.muscleGain:
        // Create caloric surplus: 1 kg gain = 7700 kcal
        final weeklySurplus = profile.weeklyGoalKg * 7700.0;
        final dailySurplus = weeklySurplus / 7.0;
        tdee = tdee + dailySurplus;
        break;
      case GoalType.weightMaintenance:
        // No adjustment needed - maintain current TDEE
        break;
    }

    // Ensure minimum calories (never go below 1200 for safety)
    tdee = tdee.clamp(1200.0, 4000.0);

    return tdee.round();
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
    // Only calculate if we have all necessary data
    final profile = state.userProfile;
    
    // Check for required basic data
    if (profile.heightCm <= 0 || 
        profile.currentWeightKg <= 0 || 
        profile.dateOfBirth == null || 
        profile.gender == null || 
        profile.goalType == null) {
      return;
    }
    
    // Check for activity data - either new system or legacy
    final hasNewActivitySystem = profile.workActivityLevel != null && profile.leisureActivityLevel != null;
    final hasLegacyActivitySystem = profile.activityLevel != null;
    
    if (!hasNewActivitySystem && !hasLegacyActivitySystem) {
      return; // No activity data available
    }
      
    final targetCalories = _calculateTargetCalories(profile);
    final macros = _calculateMacronutrients(targetCalories);
    
    final updatedProfile = profile.copyWith(
      targetCalories: targetCalories,
      targetProteinG: macros.protein,
      targetFatG: macros.fat,
      targetCarbsG: macros.carbs,
    );
    
    state = state.copyWith(
      userProfile: updatedProfile,
    );
    
    // Only auto-save when targets change for completed users if it's a meaningful change
    if (state.userProfile.isOnboardingCompleted) {
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
}

/// Provider for onboarding notifier
final onboardingProvider = StateNotifierProvider<OnboardingNotifier, OnboardingState>(
  (ref) => OnboardingNotifier(),
); 