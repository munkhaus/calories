import 'package:freezed_annotation/freezed_annotation.dart';
import '../domain/user_profile_model.dart';
import '../domain/onboarding_step.dart';

part 'onboarding_state.freezed.dart';

/// Onboarding state
@freezed
class OnboardingState with _$OnboardingState {
  const OnboardingState._();

  const factory OnboardingState({
    @Default(OnboardingStep.basicInfo) OnboardingStep currentStep,
    @Default(UserProfileModel()) UserProfileModel userProfile,
    @Default(false) bool isLoading,
    @Default(false) bool hasError,
    @Default(false) bool isEditingFromSummary,
    String? errorMessage,
  }) = _OnboardingState;

  /// Helper getters for state checks
  bool get isBasicInfo => currentStep == OnboardingStep.basicInfo;
  bool get isHealthInfo => currentStep == OnboardingStep.healthInfo;
  bool get isWorkActivity => currentStep == OnboardingStep.workActivity;
  bool get isLeisureActivity => currentStep == OnboardingStep.leisureActivity;
  bool get isGoals => currentStep == OnboardingStep.goals;
  bool get isCalorieEducation => currentStep == OnboardingStep.calorieEducation;
  bool get isSummary => currentStep == OnboardingStep.summary;
  bool get isCompleted => false;

  /// Check if we can proceed to next step
  bool get canProceedToNext {
    switch (currentStep) {
      case OnboardingStep.basicInfo:
        return userProfile.name.isNotEmpty &&
            userProfile.dateOfBirth != null &&
            userProfile.gender != null;
      case OnboardingStep.healthInfo:
        return userProfile.heightCm > 0 &&
            userProfile.currentWeightKg > 0;
      case OnboardingStep.workActivity:
        return userProfile.workActivityLevel != null;
      case OnboardingStep.leisureActivity:
        return userProfile.leisureActivityLevel != null;
      case OnboardingStep.goals:
        return userProfile.goalType != null &&
            (userProfile.goalType == GoalType.weightMaintenance || userProfile.targetWeightKg > 0);
      case OnboardingStep.calorieEducation:
        return true; // This is just an educational step
      case OnboardingStep.summary:
        return true;
    }
  }

  /// Get step progress (0.0 to 1.0)
  double get progress {
    switch (currentStep) {
      case OnboardingStep.basicInfo:
        return 0.14; // 1/7
      case OnboardingStep.healthInfo:
        return 0.29; // 2/7
      case OnboardingStep.workActivity:
        return 0.43; // 3/7
      case OnboardingStep.leisureActivity:
        return 0.57; // 4/7
      case OnboardingStep.goals:
        return 0.71; // 5/7
      case OnboardingStep.calorieEducation:
        return 0.86; // 6/7
      case OnboardingStep.summary:
        return 1.0; // Complete
    }
  }

  /// Get total number of steps
  int get totalSteps => 7;

  /// Get current step number (1-based)
  int get currentStepNumber {
    switch (currentStep) {
      case OnboardingStep.basicInfo:
        return 1;
      case OnboardingStep.healthInfo:
        return 2;
      case OnboardingStep.workActivity:
        return 3;
      case OnboardingStep.leisureActivity:
        return 4;
      case OnboardingStep.goals:
        return 5;
      case OnboardingStep.calorieEducation:
        return 6;
      case OnboardingStep.summary:
        return 7;
    }
  }

  /// Get step title
  String get stepTitle {
    switch (currentStep) {
      case OnboardingStep.basicInfo:
        return 'Personlige oplysninger';
      case OnboardingStep.healthInfo:
        return 'Fysiske mål';
      case OnboardingStep.workActivity:
        return 'Dit arbejde';
      case OnboardingStep.leisureActivity:
        return 'Din fritid';
      case OnboardingStep.goals:
        return 'Dine mål';
      case OnboardingStep.calorieEducation:
        return 'Sådan beregner vi dine kalorier';
      case OnboardingStep.summary:
        return 'Opsummering';
    }
  }

  /// Get step description
  String get stepDescription {
    switch (currentStep) {
      case OnboardingStep.basicInfo:
        return 'Fortæl os lidt om dig selv';
      case OnboardingStep.healthInfo:
        return 'Dine nuværende fysiske mål';
      case OnboardingStep.workActivity:
        return 'Hvor fysisk krævende er dit arbejde?';
      case OnboardingStep.leisureActivity:
        return 'Hvor aktiv er du i din fritid?';
      case OnboardingStep.goals:
        return 'Hvad vil du opnå?';
      case OnboardingStep.calorieEducation:
        return 'Forstå din personlige kalorie-beregning';
      case OnboardingStep.summary:
        return 'Lad os gennemgå dine oplysninger';
    }
  }
} 