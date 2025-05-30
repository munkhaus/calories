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
  
  @override
  void initState() {
    super.initState();
    _targetWeightController = TextEditingController();
    _weeklyGoalController = TextEditingController();
  }
  
  @override
  void dispose() {
    _targetWeightController.dispose();
    _weeklyGoalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    // Update controllers when state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.userProfile.targetWeightKg > 0) {
        final newValue = state.userProfile.targetWeightKg.toStringAsFixed(1);
        if (_targetWeightController.text != newValue) {
          _targetWeightController.text = newValue;
        }
      }
      
      if (state.userProfile.weeklyGoalKg > 0) {
        final newValue = state.userProfile.weeklyGoalKg.toStringAsFixed(1);
        if (_weeklyGoalController.text != newValue) {
          _weeklyGoalController.text = newValue;
        }
      }
    });

    return OnboardingBaseLayout(
      title: '🎯 Hvad er dit mål?',
      subtitle: 'Vælg det mål der passer bedst til dig',
      children: [
        // Goal selection cards with consistent primary color theme
        OnboardingSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OnboardingSectionHeader(
                icon: Icons.trending_down,
                title: 'Vælg dit hovedmål',
                subtitle: 'Dit mål påvirker dine daglige kalorier.',
                iconColor: AppColors.primary,
              ),
              
              KSizes.spacingVerticalL,
        
              // Weight Loss Goal - using consistent primary color theme
              OnboardingOptionCard(
                title: 'Tabe vægt',
                description: 'Sund og bæredygtig vægttab over tid.',
                icon: Icons.trending_down,
                color: AppColors.primary, // Changed from AppColors.error
                isSelected: state.userProfile.goalType == GoalType.weightLoss,
                onTap: () => notifier.updateGoalType(GoalType.weightLoss),
              ),
              
              KSizes.spacingVerticalM,
        
              // Weight Maintenance Goal
              OnboardingOptionCard(
                title: 'Vedligeholde vægt',
                description: 'Holde min nuværende vægt stabil.',
                icon: Icons.trending_flat,
                color: AppColors.primary, // Changed from AppColors.info
                isSelected: state.userProfile.goalType == GoalType.weightMaintenance,
                onTap: () {
                  notifier.updateGoalType(GoalType.weightMaintenance);
                  // Auto-set target weight to current weight for maintenance
                  if (state.userProfile.currentWeightKg > 0) {
                    notifier.updateTargetWeight(state.userProfile.currentWeightKg);
                  }
                },
              ),
              
              KSizes.spacingVerticalM,
              
              // Weight Gain Goal
              OnboardingOptionCard(
                title: 'Tage på',
                description: 'Sund vægtøgning og opbygning af masse.',
                icon: Icons.trending_up,
                color: AppColors.primary, // Changed from AppColors.success
                isSelected: state.userProfile.goalType == GoalType.weightGain,
                onTap: () => notifier.updateGoalType(GoalType.weightGain),
              ),
              
              KSizes.spacingVerticalM,
        
              // Muscle Gain Goal
              OnboardingOptionCard(
                title: 'Bygge muskler',
                description: 'Fokus på muskelmasse og styrke.',
                icon: Icons.fitness_center,
                color: AppColors.primary, // Changed from AppColors.warning
                isSelected: state.userProfile.goalType == GoalType.muscleGain,
                onTap: () => notifier.updateGoalType(GoalType.muscleGain),
              ),
            ],
          ),
        ),
        
        // Target weight input (if goal is not maintenance) - NOW WITH SLIDER
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
    String subtitle;
    
    switch (goalType) {
      case GoalType.weightLoss:
        title = 'Hvad er din målvægt?';
        subtitle = 'Indtast den vægt du gerne vil nå. Vælg et realistisk mål for bæredygtige resultater.';
        break;
      case GoalType.weightGain:
      case GoalType.muscleGain:
        title = 'Hvad er din målvægt?';
        subtitle = 'Indtast den vægt du ønsker at opnå. Husk at muskelopbygning tager tid.';
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
            icon: Icons.track_changes,
            title: title,
            subtitle: 'Sæt et realistisk mål.',
            iconColor: AppColors.primary, // Changed from AppColors.secondary
          ),
          
          KSizes.spacingVerticalL,
          
          // Target weight input with consistent primary color
          OnboardingInputContainer(
            color: AppColors.primary, // Changed from AppColors.secondary
            isActive: state.userProfile.targetWeightKg > 0,
            child: TextFormField(
              initialValue: state.userProfile.targetWeightKg > 0 
                  ? state.userProfile.targetWeightKg.toStringAsFixed(1)
                  : '',
              decoration: InputDecoration(
                labelText: 'Målvægt',
                suffixText: 'kg',
                border: InputBorder.none,
                labelStyle: TextStyle(
                  color: AppColors.primary, // Changed from AppColors.secondary
                  fontWeight: KSizes.fontWeightMedium,
                ),
                suffixStyle: TextStyle(
                  color: AppColors.primary, // Changed from AppColors.secondary
                  fontWeight: KSizes.fontWeightMedium,
                  fontSize: KSizes.fontSizeL,
                ),
              ),
              style: TextStyle(
                fontSize: KSizes.fontSizeXL,
                fontWeight: KSizes.fontWeightBold,
                color: AppColors.primary, // Changed from AppColors.secondary
              ),
              textAlign: TextAlign.center,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                final weight = double.tryParse(value);
                if (weight != null && weight > 0) {
                  notifier.updateTargetWeight(weight);
                }
              },
            ),
          ),
          
          KSizes.spacingVerticalL,
          
          // ADD SLIDER for target weight - consistent with physical info step
          OnboardingSlider(
            value: targetWeight,
            min: minWeight,
            max: maxWeight,
            divisions: ((maxWeight - minWeight) * 2).round(),
            onChanged: notifier.updateTargetWeight,
            color: AppColors.primary,
            minLabel: '${minWeight.round()} kg',
            maxLabel: '${maxWeight.round()} kg',
          ),
          
          if (currentWeight > 0) ...[
            KSizes.spacingVerticalM,
            OnboardingHelpText(
              text: 'Din nuværende vægt: ${currentWeight.toStringAsFixed(1)} kg',
              icon: Icons.info_outline,
              color: AppColors.info,
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
    
    String title;
    String subtitle;
    String recommendation;
    String unit;
    double minWeekly;
    double maxWeekly;
    
    switch (goalType) {
      case GoalType.weightLoss:
        title = 'Hvor hurtigt vil du tabe dig?';
        subtitle = 'Vælg et realistisk tempo for sundt og bæredygtigt vægttab.';
        recommendation = 'Anbefalet: 0.3-0.7 kg per uge';
        unit = 'kg/uge';
        minWeekly = 0.1;
        maxWeekly = 1.0;
        break;
      case GoalType.weightGain:
        title = 'Hvor hurtigt vil du tage på?';
        subtitle = 'Vælg et passende tempo for sund vægtøgning uden overdreven fedtopbygning.';
        recommendation = 'Anbefalet: 0.3-0.5 kg per uge';
        unit = 'kg/uge';
        minWeekly = 0.1;
        maxWeekly = 0.8;
        break;
      case GoalType.muscleGain:
        title = 'Hvor hurtigt vil du bygge muskler?';
        subtitle = 'Muskelopbygning kræver tålmodighed. Langsomt og støt vinder løbet.';
        recommendation = 'Anbefalet: 0.2-0.4 kg per uge';
        unit = 'kg/uge';
        minWeekly = 0.1;
        maxWeekly = 0.6;
        break;
      default:
        return const SizedBox.shrink();
    }

    double weeklyGoal = state.userProfile.weeklyGoalKg > 0 
        ? state.userProfile.weeklyGoalKg.clamp(minWeekly, maxWeekly)
        : (minWeekly + maxWeekly) / 2; // Default to middle value

    return OnboardingSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OnboardingSectionHeader(
            icon: Icons.speed,
            title: 'Hvor hurtigt?',
            subtitle: 'Vælg et realistisk tempo.',
            iconColor: AppColors.primary, // Changed from AppColors.warning
          ),
          
          KSizes.spacingVerticalM,
          
          OnboardingHelpText(
            text: recommendation,
            color: AppColors.success,
          ),
          
          KSizes.spacingVerticalL,
          
          // Weekly goal input with consistent primary color
          OnboardingInputContainer(
            color: AppColors.primary, // Changed from AppColors.warning
            isActive: state.userProfile.weeklyGoalKg > 0,
            child: TextFormField(
              initialValue: state.userProfile.weeklyGoalKg > 0 
                  ? state.userProfile.weeklyGoalKg.toStringAsFixed(1)
                  : '',
              decoration: InputDecoration(
                labelText: 'Ugentligt mål',
                suffixText: unit,
                border: InputBorder.none,
                labelStyle: TextStyle(
                  color: AppColors.primary, // Changed from AppColors.warning
                  fontWeight: KSizes.fontWeightMedium,
                ),
                suffixStyle: TextStyle(
                  color: AppColors.primary, // Changed from AppColors.warning
                  fontWeight: KSizes.fontWeightMedium,
                  fontSize: KSizes.fontSizeL,
                ),
              ),
              style: TextStyle(
                fontSize: KSizes.fontSizeXL,
                fontWeight: KSizes.fontWeightBold,
                color: AppColors.primary, // Changed from AppColors.warning
              ),
              textAlign: TextAlign.center,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                final weeklyGoal = double.tryParse(value);
                if (weeklyGoal != null && weeklyGoal > 0 && weeklyGoal <= maxWeekly) {
                  notifier.updateWeeklyGoal(weeklyGoal);
                }
              },
            ),
          ),
          
          KSizes.spacingVerticalL,
          
          // ADD SLIDER for weekly goal - consistent with other inputs
          OnboardingSlider(
            value: weeklyGoal,
            min: minWeekly,
            max: maxWeekly,
            divisions: ((maxWeekly - minWeekly) * 10).round(),
            onChanged: notifier.updateWeeklyGoal,
            color: AppColors.primary,
            minLabel: '${minWeekly.toStringAsFixed(1)} kg/uge',
            maxLabel: '${maxWeekly.toStringAsFixed(1)} kg/uge',
          ),
        ],
      ),
    );
  }
  
  Widget _buildGoalExplanation(GoalType goalType) {
    String explanationText;
    IconData icon;
    
    switch (goalType) {
      case GoalType.weightLoss:
        explanationText = 'Vi beregner et kalorieunderskud baseret på dit mål.';
        icon = Icons.trending_down;
        break;
      case GoalType.weightMaintenance:
        explanationText = 'Vi beregner kalorier til at holde din vægt stabil.';
        icon = Icons.trending_flat;
        break;
      case GoalType.weightGain:
        explanationText = 'Vi beregner et kalorieoverskud baseret på dit mål.';
        icon = Icons.trending_up;
        break;
      case GoalType.muscleGain:
        explanationText = 'Vi beregner kalorier optimeret til muskelopbygning.';
        icon = Icons.fitness_center;
        break;
    }
    
    return OnboardingHelpText(
      text: explanationText,
      icon: icon,
      color: AppColors.primary, // Consistent primary color for all explanations
    );
  }
} 