import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/k_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../application/onboarding_notifier.dart';
import '../application/onboarding_state.dart';
import '../domain/onboarding_step.dart';
import 'widgets/personal_info_step_widget.dart';
import 'widgets/physical_info_step_widget.dart';
import 'widgets/work_activity_step_widget.dart';
import 'widgets/leisure_activity_step_widget.dart';
import 'widgets/goals_step_widget.dart';
import 'widgets/summary_step_widget.dart';
import '../../../main.dart';

/// Main onboarding page
class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(state.stepTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: state.currentStepNumber > 1
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => ref.read(onboardingProvider.notifier).previousStep(),
              )
            : null,
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(state),
          
          // Step content
          Expanded(
            child: _buildStepContent(state.currentStep),
          ),
          
          // Navigation buttons
          _buildNavigationButtons(context, ref, state),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(OnboardingState state) {
    return Container(
      padding: EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withOpacity(0.1),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trin ${state.currentStepNumber} af ${state.totalSteps} • ${(state.progress * 100).round()}% færdig',
                style: TextStyle(
                  fontSize: KSizes.fontSizeS,
                  color: AppColors.textSecondary,
                  fontWeight: KSizes.fontWeightMedium,
                ),
              ),
            ],
          ),
          
          KSizes.spacingVerticalM,
          
          // Progress bar with better styling
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(KSizes.radiusS),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(KSizes.radiusS),
              child: LinearProgressIndicator(
                value: state.progress,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
          
          KSizes.spacingVerticalM,
          
          // Step description with better typography
          Text(
            _getActionableStepDescription(state.currentStep),
            style: TextStyle(
              fontSize: KSizes.fontSizeM,
              color: AppColors.primary,
              height: 1.3,
              fontWeight: KSizes.fontWeightMedium,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(OnboardingStep step) {
    switch (step) {
      case OnboardingStep.basicInfo:
        return const PersonalInfoStepWidget();
      case OnboardingStep.healthInfo:
        return const PhysicalInfoStepWidget();
      case OnboardingStep.workActivity:
        return const WorkActivityStepWidget();
      case OnboardingStep.leisureActivity:
        return const LeisureActivityStepWidget();
      case OnboardingStep.goals:
        return const GoalsStepWidget();
      case OnboardingStep.summary:
        return const SummaryStepWidget();
      case OnboardingStep.completed:
        return _buildCompletedStep();
    }
  }

  Widget _buildCompletedStep() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            size: KSizes.iconXXL * 2,
            color: Colors.green,
          ),
          SizedBox(height: KSizes.margin4x),
          Text(
            'Tillykke!',
            style: TextStyle(
              fontSize: KSizes.fontSizeHeading,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: KSizes.margin2x),
          Text(
            'Du er nu klar til at starte din sundhedsrejse',
            style: TextStyle(
              fontSize: KSizes.fontSizeL,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context, WidgetRef ref, OnboardingState state) {
    return Container(
      padding: EdgeInsets.all(KSizes.margin4x),
      child: Row(
        children: [
          if (state.currentStepNumber > 1)
            Expanded(
              child: OutlinedButton(
                onPressed: () => ref.read(onboardingProvider.notifier).previousStep(),
                child: const Text('Tilbage'),
              ),
            ),
          
          if (state.currentStepNumber > 1)
            SizedBox(width: KSizes.margin4x),
          
          Expanded(
            flex: state.currentStepNumber > 1 ? 1 : 2,
            child: ElevatedButton(
              onPressed: state.canProceedToNext
                  ? () async {
                      if (state.currentStep == OnboardingStep.completed) {
                        // Navigate to main app by replacing entire app structure
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const AppWrapper(),
                          ),
                          (route) => false,
                        );
                      } else if (state.currentStep == OnboardingStep.summary) {
                        // Complete onboarding before going to completion screen
                        await ref.read(onboardingProvider.notifier).completeOnboarding();
                        if (ref.read(onboardingProvider).hasError) {
                          // Show error message if completion failed
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(ref.read(onboardingProvider).errorMessage ?? 'Der opstod en fejl'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else {
                          // Proceed to next step (completed screen)
                          ref.read(onboardingProvider.notifier).nextStep();
                        }
                      } else {
                        ref.read(onboardingProvider.notifier).nextStep();
                      }
                    }
                  : null,
              child: Text(
                state.currentStep == OnboardingStep.completed
                    ? 'Start app'
                    : state.currentStep == OnboardingStep.summary
                        ? 'Fuldfør'
                        : state.canProceedToNext 
                            ? 'Fortsæt'
                            : 'Udfyld felterne',
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getActionableStepDescription(OnboardingStep step) {
    switch (step) {
      case OnboardingStep.basicInfo:
        return '👋 Fortæl os hvem du er';
      case OnboardingStep.healthInfo:
        return '📏 Indtast dine fysiske mål';
      case OnboardingStep.workActivity:
        return '💼 Beskriv dit arbejde';
      case OnboardingStep.leisureActivity:
        return '🏃‍♂️ Hvor aktiv er du i fritiden?';
      case OnboardingStep.goals:
        return '🎯 Hvad vil du opnå?';
      case OnboardingStep.summary:
        return '✅ Gennemgå dine oplysninger';
      case OnboardingStep.completed:
        return '🎉 Du er klar til at starte!';
    }
  }
}