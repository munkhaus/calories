import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../application/onboarding_notifier.dart';
import '../../domain/user_profile_model.dart';
import 'onboarding_base_layout.dart';

class GoalsStepWidget extends ConsumerStatefulWidget {
  const GoalsStepWidget({super.key});

  @override
  ConsumerState<GoalsStepWidget> createState() => _GoalsStepWidgetState();
}

class _GoalsStepWidgetState extends ConsumerState<GoalsStepWidget> {
  late TextEditingController _targetWeightController;
  late TextEditingController _weeklyGoalController;
  late FocusNode _targetWeightFocus;
  late FocusNode _weeklyGoalFocus;
  
  @override
  void initState() {
    super.initState();
    _targetWeightController = TextEditingController();
    _weeklyGoalController = TextEditingController();
    _targetWeightFocus = FocusNode();
    _weeklyGoalFocus = FocusNode();
  }
  
  @override
  void dispose() {
    _targetWeightController.dispose();
    _weeklyGoalController.dispose();
    _targetWeightFocus.dispose();
    _weeklyGoalFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    // Update controllers when state changes, but only if the user is not actively editing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Only update target weight controller if not focused and value differs
      if (!_targetWeightFocus.hasFocus && state.userProfile.targetWeightKg > 0) {
        final newValue = state.userProfile.targetWeightKg.toStringAsFixed(1);
        if (_targetWeightController.text != newValue) {
          _targetWeightController.text = newValue;
        }
      }
      
      // Only update weekly goal controller if not focused and value differs
      if (!_weeklyGoalFocus.hasFocus && state.userProfile.weeklyGoalKg > 0) {
        final newValue = state.userProfile.weeklyGoalKg.toStringAsFixed(1);
        if (_weeklyGoalController.text != newValue) {
          _weeklyGoalController.text = newValue;
        }
      }
    });

    return OnboardingBaseLayout(
      title: 'Hvad er dit mål?',
      subtitle: 'Vælg det mål der passer bedst til dig',
      children: [
        // Goal selection cards - simplified
        OnboardingSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OnboardingSectionHeader(
                title: 'Vælg dit hovedmål',
                subtitle: 'Dit mål påvirker dine daglige kalorier.',
              ),
              
              KSizes.spacingVerticalL,
        
              // Weight Loss Goal - simplified design
              OnboardingOptionCard(
                title: 'Tabe vægt',
                description: 'Graduel vægttab over tid.',
                isSelected: state.userProfile.goalType == GoalType.weightLoss,
                onTap: () => notifier.updateGoalType(GoalType.weightLoss),
              ),
              
              // Weight Maintenance Goal
              OnboardingOptionCard(
                title: 'Vedligeholde vægt',
                description: 'Holde min nuværende vægt stabil.',
                isSelected: state.userProfile.goalType == GoalType.weightMaintenance,
                onTap: () {
                  notifier.updateGoalType(GoalType.weightMaintenance);
                  // Auto-set target weight to current weight for maintenance
                  if (state.userProfile.currentWeightKg > 0) {
                    notifier.updateTargetWeight(state.userProfile.currentWeightKg);
                  }
                },
              ),
              
              // Weight Gain Goal
              OnboardingOptionCard(
                title: 'Tage på',
                description: 'Vægtøgning og opbygning af masse.',
                isSelected: state.userProfile.goalType == GoalType.weightGain,
                onTap: () => notifier.updateGoalType(GoalType.weightGain),
              ),
        
              // Muscle Gain Goal
              OnboardingOptionCard(
                title: 'Bygge muskler',
                description: 'Fokus på muskelmasse og styrke.',
                isSelected: state.userProfile.goalType == GoalType.muscleGain,
                onTap: () => notifier.updateGoalType(GoalType.muscleGain),
              ),
            ],
          ),
        ),
        
        // Target weight input (if goal is not maintenance)
        if (state.userProfile.goalType != null && 
            state.userProfile.goalType != GoalType.weightMaintenance) ...[
          KSizes.spacingVerticalL,
          _buildTargetWeightSection(context, state, notifier),
          
          KSizes.spacingVerticalL,
          _buildWeeklyGoalSection(context, state, notifier),
        ],
        
        // Informational help text based on selected goal
        if (state.userProfile.goalType != null) ...[
          KSizes.spacingVerticalL,
          _buildGoalExplanation(state.userProfile.goalType!),
        ],
      ],
    );
  }

  Widget _buildTargetWeightSection(
    BuildContext context,
    dynamic state,
    dynamic notifier,
  ) {
    final goalType = state.userProfile.goalType;
    final currentWeight = state.userProfile.currentWeightKg;
    
    String title;
    
    switch (goalType) {
      case GoalType.weightLoss:
        title = 'Hvad er din målvægt?';
        break;
      case GoalType.weightGain:
      case GoalType.muscleGain:
        title = 'Hvad er din målvægt?';
        break;
      default:
        return const SizedBox.shrink();
    }

    // Calculate reasonable weight range based on current weight
    double minWeight = currentWeight > 0 ? (currentWeight * 0.7).clamp(40, 150) : 40;
    double maxWeight = currentWeight > 0 ? (currentWeight * 1.3).clamp(60, 200) : 200;
    double targetWeight = state.userProfile.targetWeightKg > 0 
        ? state.userProfile.targetWeightKg.clamp(minWeight, maxWeight)
        : currentWeight > 0 ? currentWeight : minWeight;

    return OnboardingSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OnboardingSectionHeader(
            title: title,
            subtitle: 'Sæt et realistisk mål.',
          ),
          
          KSizes.spacingVerticalL,
          
          // Target weight input - simplified styling
          OnboardingInputContainer(
            isActive: state.userProfile.targetWeightKg > 0,
            child: TextFormField(
              controller: _targetWeightController,
              focusNode: _targetWeightFocus,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              onChanged: (value) {
                // Only update state if the value is valid and different from current state
                final weight = double.tryParse(value);
                if (weight != null && weight >= minWeight && weight <= maxWeight) {
                  // Small delay to prevent rapid updates while typing
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (mounted && _targetWeightController.text == value) {
                      notifier.updateTargetWeight(weight);
                    }
                  });
                }
              },
              onEditingComplete: () {
                // Ensure final validation when user finishes editing
                final weight = double.tryParse(_targetWeightController.text);
                if (weight != null && weight >= minWeight && weight <= maxWeight) {
                  notifier.updateTargetWeight(weight);
                } else {
                  // Reset to current state value if invalid
                  if (state.userProfile.targetWeightKg > 0) {
                    _targetWeightController.text = state.userProfile.targetWeightKg.toStringAsFixed(1);
                  } else {
                    _targetWeightController.clear();
                  }
                }
                _targetWeightFocus.unfocus();
              },
              decoration: InputDecoration(
                hintText: 'Indtast målvægt',
                suffixText: 'kg',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: AppColors.primary.withOpacity(0.6),
                  fontSize: KSizes.fontSizeL,
                ),
                suffixStyle: TextStyle(
                  color: AppColors.primary,
                  fontWeight: KSizes.fontWeightMedium,
                  fontSize: KSizes.fontSizeL,
                ),
              ),
              style: TextStyle(
                fontSize: KSizes.fontSizeXXL,
                fontWeight: KSizes.fontWeightBold,
                color: AppColors.primary,
              ),
            ),
          ),
          
          KSizes.spacingVerticalL,
          
          // Target weight slider
          OnboardingSlider(
            value: targetWeight,
            min: minWeight,
            max: maxWeight,
            divisions: ((maxWeight - minWeight) * 2).round(),
            onChanged: (value) {
              notifier.updateTargetWeight(value);
              // Only update text controller if user is not typing in the field
              if (!_targetWeightFocus.hasFocus) {
                _targetWeightController.text = value.toStringAsFixed(1);
              }
            },
            minLabel: '${minWeight.round()} kg',
            maxLabel: '${maxWeight.round()} kg',
            unit: 'kg',
          ),
          
          // Weight difference help text
          if (state.userProfile.targetWeightKg > 0 && currentWeight > 0) ...[
            KSizes.spacingVerticalM,
            OnboardingHelpText(
              text: _getWeightDifferenceText(goalType, currentWeight, state.userProfile.targetWeightKg),
              type: OnboardingHelpType.motivational,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWeeklyGoalSection(
    BuildContext context,
    dynamic state,
    dynamic notifier,
  ) {
    final goalType = state.userProfile.goalType;
    if (goalType == GoalType.weightMaintenance) return const SizedBox.shrink();

    String title;
    String unit;
    double min, max, defaultValue;
    
    if (goalType == GoalType.weightLoss) {
      title = 'Hvor meget vil du tabe per uge?';
      unit = 'kg/uge';
      min = 0.1;
      max = 1.0;
      defaultValue = 0.5;
    } else {
      title = 'Hvor meget vil du tage på per uge?';
      unit = 'kg/uge';
      min = 0.1;
      max = 0.8;
      defaultValue = 0.3;
    }

    double weeklyGoal = state.userProfile.weeklyGoalKg > 0 
        ? state.userProfile.weeklyGoalKg 
        : defaultValue;

    return OnboardingSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OnboardingSectionHeader(
            title: title,
            subtitle: 'Vælg et bæredygtigt tempo.',
          ),
          
          KSizes.spacingVerticalL,
          
          // Weekly goal input - simplified styling
          OnboardingInputContainer(
            isActive: state.userProfile.weeklyGoalKg > 0,
            child: TextFormField(
              controller: _weeklyGoalController,
              focusNode: _weeklyGoalFocus,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              onChanged: (value) {
                // Only update state if the value is valid and different from current state
                final goal = double.tryParse(value);
                if (goal != null && goal >= min && goal <= max) {
                  // Small delay to prevent rapid updates while typing
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (mounted && _weeklyGoalController.text == value) {
                      notifier.updateWeeklyGoal(goal);
                    }
                  });
                }
              },
              onEditingComplete: () {
                // Ensure final validation when user finishes editing
                final goal = double.tryParse(_weeklyGoalController.text);
                if (goal != null && goal >= min && goal <= max) {
                  notifier.updateWeeklyGoal(goal);
                } else {
                  // Reset to current state value if invalid
                  if (state.userProfile.weeklyGoalKg > 0) {
                    _weeklyGoalController.text = state.userProfile.weeklyGoalKg.toStringAsFixed(1);
                  } else {
                    _weeklyGoalController.clear();
                  }
                }
                _weeklyGoalFocus.unfocus();
              },
              decoration: InputDecoration(
                hintText: 'Indtast ugentligt mål',
                suffixText: unit,
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: AppColors.primary.withOpacity(0.6),
                  fontSize: KSizes.fontSizeL,
                ),
                suffixStyle: TextStyle(
                  color: AppColors.primary,
                  fontWeight: KSizes.fontWeightMedium,
                  fontSize: KSizes.fontSizeL,
                ),
              ),
              style: TextStyle(
                fontSize: KSizes.fontSizeXXL,
                fontWeight: KSizes.fontWeightBold,
                color: AppColors.primary,
              ),
            ),
          ),
          
          KSizes.spacingVerticalL,
          
          // Weekly goal slider
          OnboardingSlider(
            value: weeklyGoal.clamp(min, max),
            min: min,
            max: max,
            divisions: ((max - min) * 10).round(),
            onChanged: (value) {
              notifier.updateWeeklyGoal(value);
              // Only update text controller if user is not typing in the field
              if (!_weeklyGoalFocus.hasFocus) {
                _weeklyGoalController.text = value.toStringAsFixed(1);
              }
            },
            minLabel: '${min.toStringAsFixed(1)} kg',
            maxLabel: '${max.toStringAsFixed(1)} kg',
            unit: 'kg/uge',
          ),
          
          // Weekly goal recommendation
          KSizes.spacingVerticalM,
          OnboardingHelpText(
            text: _getWeeklyGoalRecommendation(goalType, weeklyGoal),
            type: OnboardingHelpType.motivational,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalExplanation(GoalType goalType) {
    String explanation;
    
    switch (goalType) {
      case GoalType.weightLoss:
        explanation = 'Vægttab kræver et kalorieunderskud. Dit kaloriemål beregnes til at understøtte vægttab.';
        break;
      case GoalType.weightMaintenance:
        explanation = 'For at holde vægten stabil skal kalorieforbrug og indtag være i balance.';
        break;
      case GoalType.weightGain:
        explanation = 'Vægtøgning kræver et kalorieoverskud. Dit kaloriemål tilpasses til vægtøgning.';
        break;
      case GoalType.muscleGain:
        explanation = 'Muskelopbygning kræver både kalorier og protein. Dit indtag beregnes til muskeludvikling.';
        break;
    }

    return OnboardingHelpText(
      text: explanation,
      type: OnboardingHelpType.positive,
    );
  }

  String _getWeightDifferenceText(GoalType goalType, double currentWeight, double targetWeight) {
    final difference = (targetWeight - currentWeight).abs();
    
    if (goalType == GoalType.weightLoss) {
      return 'Du vil tabe ${difference.toStringAsFixed(1)} kg samlet.';
    } else {
      return 'Du vil tage ${difference.toStringAsFixed(1)} kg på samlet.';
    }
  }

  String _getWeeklyGoalRecommendation(GoalType goalType, double weeklyGoal) {
    if (goalType == GoalType.weightLoss) {
      if (weeklyGoal <= 0.3) {
        return 'Langsomt og bæredygtigt tempo.';
      } else if (weeklyGoal <= 0.7) {
        return 'Moderat tempo - realistisk for de fleste.';
      } else {
        return 'Hurtigt tempo - kan være udfordrende at holde.';
      }
    } else {
      if (weeklyGoal <= 0.2) {
        return 'Langsomt tempo - minimerer fedtindtag.';
      } else if (weeklyGoal <= 0.5) {
        return 'Moderat tempo - god balance mellem muskler og fedt.';
      } else {
        return 'Hurtigt tempo - kan give mere fedt end muskler.';
      }
    }
  }
} 