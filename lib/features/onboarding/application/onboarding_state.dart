import 'package:freezed_annotation/freezed_annotation.dart';
import '../domain/user_profile_model.dart';

part 'onboarding_state.freezed.dart';

/// Onboarding flow steps
enum OnboardingStep {
  welcome,
  personalInfo,
  physicalInfo,
  goals,
  summary,
  completed,
}

/// Onboarding state
@freezed
class OnboardingState with _$OnboardingState {
  const OnboardingState._();

  const factory OnboardingState({
    @Default(OnboardingStep.welcome) OnboardingStep currentStep,
    @Default(UserProfileModel()) UserProfileModel userProfile,
    @Default(false) bool isLoading,
    @Default(false) bool hasError,
    @Default(false) bool isEditingFromSummary,
    String? errorMessage,
  }) = _OnboardingState;

  /// Helper getters for state checks
  bool get isWelcome => currentStep == OnboardingStep.welcome;
  bool get isPersonalInfo => currentStep == OnboardingStep.personalInfo;
  bool get isPhysicalInfo => currentStep == OnboardingStep.physicalInfo;
  bool get isGoals => currentStep == OnboardingStep.goals;
  bool get isSummary => currentStep == OnboardingStep.summary;
  bool get isCompleted => currentStep == OnboardingStep.completed;

  /// Check if we can proceed to next step
  bool get canProceedToNext {
    switch (currentStep) {
      case OnboardingStep.welcome:
        return true;
      case OnboardingStep.personalInfo:
        return userProfile.name.isNotEmpty &&
            userProfile.dateOfBirth != null &&
            userProfile.gender != null;
      case OnboardingStep.physicalInfo:
        return userProfile.heightCm > 0 &&
            userProfile.currentWeightKg > 0 &&
            userProfile.targetWeightKg > 0;
      case OnboardingStep.goals:
        return userProfile.goalType != null && userProfile.activityLevel != null;
      case OnboardingStep.summary:
        return true;
      case OnboardingStep.completed:
        return false;
    }
  }

  /// Get step progress (0.0 to 1.0)
  double get progress {
    switch (currentStep) {
      case OnboardingStep.welcome:
        return 0.0;
      case OnboardingStep.personalInfo:
        return 0.2;
      case OnboardingStep.physicalInfo:
        return 0.4;
      case OnboardingStep.goals:
        return 0.6;
      case OnboardingStep.summary:
        return 0.8;
      case OnboardingStep.completed:
        return 1.0;
    }
  }

  /// Get total number of steps (excluding welcome and completed)
  int get totalSteps => 4;

  /// Get current step number (1-based)
  int get currentStepNumber {
    switch (currentStep) {
      case OnboardingStep.welcome:
        return 0;
      case OnboardingStep.personalInfo:
        return 1;
      case OnboardingStep.physicalInfo:
        return 2;
      case OnboardingStep.goals:
        return 3;
      case OnboardingStep.summary:
        return 4;
      case OnboardingStep.completed:
        return 4;
    }
  }

  /// Get step title
  String get stepTitle {
    switch (currentStep) {
      case OnboardingStep.welcome:
        return 'Velkommen til Dit Sunde Jeg';
      case OnboardingStep.personalInfo:
        return 'Personlige oplysninger';
      case OnboardingStep.physicalInfo:
        return 'Fysiske mål';
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
      case OnboardingStep.welcome:
        return 'Lad os komme i gang med at sætte op din personlige sundhedsrejse';
      case OnboardingStep.personalInfo:
        return 'Fortæl os lidt om dig selv';
      case OnboardingStep.physicalInfo:
        return 'Dine nuværende og målrettede fysiske mål';
      case OnboardingStep.goals:
        return 'Hvad vil du gerne opnå?';
      case OnboardingStep.summary:
        return 'Lad os gennemgå dine oplysninger';
      case OnboardingStep.completed:
        return 'Du er klar til at starte din sundhedsrejse!';
    }
  }
} 