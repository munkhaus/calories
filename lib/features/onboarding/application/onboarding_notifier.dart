import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user_profile_model.dart';
import '../infrastructure/onboarding_storage_service.dart';
import 'onboarding_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Onboarding state notifier
class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(const OnboardingState()) {
    _loadSavedProgress();
  }

  /// Load any saved progress from previous session
  Future<void> _loadSavedProgress() async {
    try {
      print('🔍 Loading saved progress...');
      
      // First check if onboarding is completed and load permanent profile
      final isCompleted = await OnboardingStorageService.isOnboardingCompleted();
      if (isCompleted) {
        print('✅ Onboarding already completed, loading permanent profile...');
        final completedProfile = await OnboardingStorageService.loadUserProfile();
        if (completedProfile != null) {
          print('📥 Found completed profile: ${completedProfile.name}');
          state = state.copyWith(
            userProfile: completedProfile,
            currentStep: OnboardingStep.completed,
          );
          print('✅ Loaded completed profile successfully');
          return;
        }
      }
      
      // If no completed profile, check for partial progress
      final savedProfile = await OnboardingStorageService.loadPartialProgress();
      if (savedProfile != null) {
        print('📥 Found saved partial profile: ${savedProfile.name}');
        state = state.copyWith(userProfile: savedProfile);
        _calculateTargets();
        print('✅ Loaded partial progress successfully');
      } else {
        print('ℹ️ No saved progress found');
      }
    } catch (e) {
      // If loading fails, continue with empty profile
      print('❌ Failed to load saved progress: $e');
    }
  }

  /// Auto-save progress after each update
  Future<void> _autoSaveProgress() async {
    try {
      print('🔄 Auto-saving progress: ${state.userProfile.name}');
      await OnboardingStorageService.savePartialProgress(state.userProfile);
      print('✅ Auto-save successful');
    } catch (e) {
      print('❌ Failed to auto-save progress: $e');
    }
  }

  /// Go to next step
  void nextStep() {
    if (!state.canProceedToNext) return;

    // If editing from summary, return to summary instead of normal flow
    if (state.isEditingFromSummary) {
      state = state.copyWith(
        currentStep: OnboardingStep.summary,
        isEditingFromSummary: false,
      );
      return;
    }

    final nextStep = switch (state.currentStep) {
      OnboardingStep.welcome => OnboardingStep.personalInfo,
      OnboardingStep.personalInfo => OnboardingStep.physicalInfo,
      OnboardingStep.physicalInfo => OnboardingStep.goals,
      OnboardingStep.goals => OnboardingStep.summary,
      OnboardingStep.summary => OnboardingStep.completed,
      OnboardingStep.completed => OnboardingStep.completed,
    };

    state = state.copyWith(currentStep: nextStep);
  }

  /// Go to previous step
  void previousStep() {
    // If editing from summary, return to summary instead of normal flow
    if (state.isEditingFromSummary) {
      state = state.copyWith(
        currentStep: OnboardingStep.summary,
        isEditingFromSummary: false,
      );
      return;
    }

    final prevStep = switch (state.currentStep) {
      OnboardingStep.welcome => OnboardingStep.welcome,
      OnboardingStep.personalInfo => OnboardingStep.welcome,
      OnboardingStep.physicalInfo => OnboardingStep.personalInfo,
      OnboardingStep.goals => OnboardingStep.physicalInfo,
      OnboardingStep.summary => OnboardingStep.goals,
      OnboardingStep.completed => OnboardingStep.summary,
    };

    state = state.copyWith(currentStep: prevStep);
  }

  /// Go to specific step by number (1=personalInfo, 2=physicalInfo, 3=goals)
  void goToStep(int stepNumber) {
    final targetStep = switch (stepNumber) {
      0 => OnboardingStep.welcome,
      1 => OnboardingStep.personalInfo,
      2 => OnboardingStep.physicalInfo,
      3 => OnboardingStep.goals,
      4 => OnboardingStep.summary,
      5 => OnboardingStep.completed,
      _ => state.currentStep, // Stay on current step if invalid
    };

    // Track if we're coming from summary to edit a section
    final isEditingFromSummary = state.currentStep == OnboardingStep.summary && 
                                 targetStep != OnboardingStep.summary;

    state = state.copyWith(
      currentStep: targetStep,
      isEditingFromSummary: isEditingFromSummary,
    );
  }

  /// Update user name
  void updateName(String name) {
    state = state.copyWith(
      userProfile: state.userProfile.copyWith(name: name),
    );
    _autoSaveProgress();
  }

  /// Update date of birth
  void updateDateOfBirth(DateTime dateOfBirth) {
    state = state.copyWith(
      userProfile: state.userProfile.copyWith(dateOfBirth: dateOfBirth),
    );
    _calculateTargets();
    _autoSaveProgress();
  }

  /// Update gender
  void updateGender(Gender gender) {
    state = state.copyWith(
      userProfile: state.userProfile.copyWith(gender: gender),
    );
    _calculateTargets();
    _autoSaveProgress();
  }

  /// Update height in cm
  void updateHeight(double heightCm) {
    state = state.copyWith(
      userProfile: state.userProfile.copyWith(heightCm: heightCm),
    );
    _calculateTargets();
    _autoSaveProgress();
  }

  /// Update current weight in kg
  void updateCurrentWeight(double currentWeightKg) {
    state = state.copyWith(
      userProfile: state.userProfile.copyWith(currentWeightKg: currentWeightKg),
    );
    _calculateTargets();
    _autoSaveProgress();
  }

  /// Update target weight in kg
  void updateTargetWeight(double targetWeightKg) {
    state = state.copyWith(
      userProfile: state.userProfile.copyWith(targetWeightKg: targetWeightKg),
    );
    _calculateTargets();
    _autoSaveProgress();
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
    _autoSaveProgress();
  }

  /// Update activity level
  void updateActivityLevel(ActivityLevel activityLevel) {
    state = state.copyWith(
      userProfile: state.userProfile.copyWith(activityLevel: activityLevel),
    );
    _calculateTargets();
    _autoSaveProgress();
  }

  /// Update weekly goal weight change
  void updateWeeklyGoal(double weeklyGoalKg) {
    state = state.copyWith(
      userProfile: state.userProfile.copyWith(weeklyGoalKg: weeklyGoalKg),
    );
    _calculateTargets();
    _autoSaveProgress();
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
        profile.activityLevel == null ||
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

    // Apply activity level multiplier (using precise values)
    final activityMultiplier = switch (profile.activityLevel!) {
      ActivityLevel.sedentary => 1.2,
      ActivityLevel.lightlyActive => 1.375,
      ActivityLevel.moderatelyActive => 1.55,
      ActivityLevel.veryActive => 1.725,
      ActivityLevel.extraActive => 1.9,
    };

    double tdee = bmr * activityMultiplier;

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
    if (profile.heightCm > 0 && 
        profile.currentWeightKg > 0 && 
        profile.dateOfBirth != null && 
        profile.gender != null && 
        profile.activityLevel != null && 
        profile.goalType != null) {
      
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
    }
  }

  /// Restart onboarding flow (for editing existing data)
  Future<void> restartOnboardingFlow() async {
    print('🔄 Restarting onboarding flow for editing...');
    
    // Do NOT reset data - just restart the flow to allow editing
    // Keep all existing userProfile data so user can edit it
    state = state.copyWith(
      currentStep: OnboardingStep.welcome,
      isEditingFromSummary: false,
    );
    
    print('✅ Onboarding flow restarted for editing (data preserved)');
  }
}

/// Provider for onboarding notifier
final onboardingProvider = StateNotifierProvider<OnboardingNotifier, OnboardingState>(
  (ref) => OnboardingNotifier(),
); 