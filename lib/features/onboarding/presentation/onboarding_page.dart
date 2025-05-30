import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/k_sizes.dart';
import '../application/onboarding_notifier.dart';
import '../application/onboarding_state.dart';
import '../domain/onboarding_step.dart';
import 'widgets/personal_info_step_widget.dart';
import 'widgets/physical_info_step_widget.dart';
import 'widgets/work_activity_step_widget.dart';
import 'widgets/leisure_activity_step_widget.dart';
import 'widgets/goals_step_widget.dart';
import 'widgets/calorie_explanation_step_widget.dart';
import 'widgets/summary_step_widget.dart';

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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trin ${state.currentStepNumber} af ${state.totalSteps}',
                style: TextStyle(
                  fontSize: KSizes.fontSizeS,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '${(state.progress * 100).round()}%',
                style: TextStyle(
                  fontSize: KSizes.fontSizeS,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: KSizes.margin2x),
          LinearProgressIndicator(
            value: state.progress,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          SizedBox(height: KSizes.margin2x),
          Text(
            state.stepDescription,
            style: TextStyle(
              fontSize: KSizes.fontSizeM,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
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
      case OnboardingStep.calorieExplanation:
        return const CalorieExplanationStepWidget();
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
                  ? () {
                      if (state.currentStep == OnboardingStep.completed) {
                        Navigator.of(context).pushReplacementNamed('/dashboard');
                      } else {
                        ref.read(onboardingProvider.notifier).nextStep();
                      }
                    }
                  : null,
              child: Text(
                state.currentStep == OnboardingStep.completed
                    ? 'Start app'
                    : state.currentStep == OnboardingStep.summary
                        ? 'Afslut'
                        : 'Næste',
              ),
            ),
          ),
        ],
      ),
    );
  }
} 