import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../core/constants/k_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/progress_indicator_widget.dart';
import '../application/onboarding_notifier.dart';
import '../application/onboarding_state.dart';
import 'widgets/animated_step_transition.dart';
import 'widgets/welcome_step_widget.dart';
import 'widgets/personal_info_step_widget.dart';
import 'widgets/physical_info_step_widget.dart';
import 'widgets/goals_step_widget.dart';
import 'widgets/summary_step_widget.dart';
import 'widgets/completed_step_widget.dart';

/// Main onboarding page
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(KSizes.margin4x),
          child: Column(
            children: [
              // Progress indicator
              ProgressIndicatorWidget(
                currentStep: _getStepIndex(state.currentStep),
                totalSteps: 5,
              ),
              
              const SizedBox(height: KSizes.margin4x),
              
              // Main content
              Expanded(
                child: AnimatedStepTransition(
                  animation: _animation,
                  child: _buildCurrentStep(state.currentStep),
                ),
              ),
              
              // Navigation buttons
              _buildNavigationButtons(state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(OnboardingStep step) {
    switch (step) {
      case OnboardingStep.welcome:
        return const WelcomeStepWidget();
      case OnboardingStep.personalInfo:
        return const PersonalInfoStepWidget();
      case OnboardingStep.physicalInfo:
        return const PhysicalInfoStepWidget();
      case OnboardingStep.goals:
        return const GoalsStepWidget();
      case OnboardingStep.summary:
        return const SummaryStepWidget();
      case OnboardingStep.completed:
        return const CompletedStepWidget();
    }
  }

  int _getStepIndex(OnboardingStep step) {
    switch (step) {
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
        return 4; // Don't show as step 5
    }
  }

  Widget _buildNavigationButtons(OnboardingState state) {
    // Hide navigation buttons on welcome step since it has its own "Kom i gang" button
    // Also hide on completed step
    if (state.currentStep == OnboardingStep.welcome || 
        state.currentStep == OnboardingStep.completed) {
      return const SizedBox.shrink();
    }
    
    return Row(
      children: [
        // Back button
        if (_getStepIndex(state.currentStep) > 0)
          Expanded(
            child: CustomButton(
              text: 'Tilbage',
              variant: ButtonVariant.outline,
              onPressed: () {
                ref.read(onboardingProvider.notifier).previousStep();
              },
            ),
          ),
        
        if (_getStepIndex(state.currentStep) > 0) const SizedBox(width: KSizes.margin4x),
        
        // Next/Complete button
        Expanded(
          flex: 2,
          child: CustomButton(
            text: state.currentStep == OnboardingStep.summary ? 'Færdig' : 'Næste',
            variant: ButtonVariant.primary,
            isLoading: state.isLoading,
            onPressed: state.canProceedToNext
                ? () async {
                    if (state.currentStep == OnboardingStep.summary) {
                      await ref.read(onboardingProvider.notifier).completeOnboarding();
                      // The AppWrapper will detect completion and navigate automatically
                    } else {
                      ref.read(onboardingProvider.notifier).nextStep();
                    }
                  }
                : null,
          ),
        ),
      ],
    );
  }
} 