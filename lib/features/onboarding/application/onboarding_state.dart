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
  bool get isSummary => currentStep == OnboardingStep.summary;
  bool get isCompleted => currentStep == OnboardingStep.completed;

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
      case OnboardingStep.summary:
        return true;
      case OnboardingStep.completed:
        return true;
    }
  }

  /// Get step progress (0.0 to 1.0)
  double get progress {
    switch (currentStep) {
      case OnboardingStep.basicInfo:
        return 0.17;
      case OnboardingStep.healthInfo:
        return 0.33;
      case OnboardingStep.workActivity:
        return 0.50;
      case OnboardingStep.leisureActivity:
        return 0.67;
      case OnboardingStep.goals:
        return 0.83;
      case OnboardingStep.summary:
        return 0.95;
      case OnboardingStep.completed:
        return 1.0;
    }
  }

  /// Get total number of steps (excluding completed)
  int get totalSteps => 6;

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
      case OnboardingStep.summary:
        return 6;
      case OnboardingStep.completed:
        return 6;
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
      case OnboardingStep.summary:
        return 'Opsummering';
      case OnboardingStep.completed:
        return 'Færdig!';
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
      case OnboardingStep.summary:
        return 'Lad os gennemgå dine oplysninger';
      case OnboardingStep.completed:
        return 'Du er klar til at starte din sundhedsrejse!';
    }
  }
} 