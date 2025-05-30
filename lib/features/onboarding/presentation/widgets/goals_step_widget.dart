import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../application/onboarding_notifier.dart';
import '../../domain/user_profile_model.dart';

class GoalsStepWidget extends ConsumerWidget {
  const GoalsStepWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hvad er dit mål?',
          style: TextStyle(
            fontSize: KSizes.fontSizeL,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: KSizes.margin2x),
        Text(
          'Vælg det mål, der passer bedst til dig',
          style: TextStyle(
            fontSize: KSizes.fontSizeM,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: KSizes.margin6x),
        
        // Goal selection cards
        _buildGoalCard(
          context: context,
          goalType: GoalType.weightLoss,
          title: 'Tabe vægt',
          description: 'Jeg vil gerne tabe vægt på en sund måde',
          icon: Icons.trending_down,
          color: Colors.red,
          isSelected: state.userProfile.goalType == GoalType.weightLoss,
          onTap: () => notifier.updateGoalType(GoalType.weightLoss),
        ),
        SizedBox(height: KSizes.margin4x),
        
        _buildGoalCard(
          context: context,
          goalType: GoalType.weightMaintenance,
          title: 'Vedligeholde vægt',
          description: 'Jeg vil gerne holde min nuværende vægt',
          icon: Icons.trending_flat,
          color: Colors.blue,
          isSelected: state.userProfile.goalType == GoalType.weightMaintenance,
          onTap: () => notifier.updateGoalType(GoalType.weightMaintenance),
        ),
        SizedBox(height: KSizes.margin4x),
        
        _buildGoalCard(
          context: context,
          goalType: GoalType.weightGain,
          title: 'Tage på',
          description: 'Jeg vil gerne tage på på en sund måde',
          icon: Icons.trending_up,
          color: Colors.green,
          isSelected: state.userProfile.goalType == GoalType.weightGain,
          onTap: () => notifier.updateGoalType(GoalType.weightGain),
        ),
        SizedBox(height: KSizes.margin4x),
        
        _buildGoalCard(
          context: context,
          goalType: GoalType.muscleGain,
          title: 'Bygge muskler',
          description: 'Jeg vil gerne opbygge muskelmasse',
          icon: Icons.fitness_center,
          color: Colors.orange,
          isSelected: state.userProfile.goalType == GoalType.muscleGain,
          onTap: () => notifier.updateGoalType(GoalType.muscleGain),
        ),
        
        // Target weight input (if goal is not maintenance)
        if (state.userProfile.goalType != null && 
            state.userProfile.goalType != GoalType.weightMaintenance) ...[
          SizedBox(height: KSizes.margin6x),
          _buildTargetWeightSection(context, state, notifier),
        ],
      ],
    );
  }

  Widget _buildGoalCard({
    required BuildContext context,
    required GoalType goalType,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        side: BorderSide(
          color: isSelected ? color : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        child: Padding(
          padding: EdgeInsets.all(KSizes.margin4x),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(KSizes.margin3x),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: KSizes.iconL,
                ),
              ),
              SizedBox(width: KSizes.margin4x),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: KSizes.fontSizeM,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? color : null,
                      ),
                    ),
                    SizedBox(height: KSizes.margin1x),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: KSizes.fontSizeS,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: color,
                  size: KSizes.iconM,
                ),
            ],
          ),
        ),
      ),
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
    String hint;
    
    switch (goalType) {
      case GoalType.weightLoss:
        title = 'Hvad er din målvægt?';
        hint = 'Indtast din ønskede vægt';
        break;
      case GoalType.weightGain:
      case GoalType.muscleGain:
        title = 'Hvad er din målvægt?';
        hint = 'Indtast din ønskede vægt';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: KSizes.fontSizeM,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: KSizes.margin2x),
        TextFormField(
          initialValue: state.userProfile.targetWeightKg > 0 
              ? state.userProfile.targetWeightKg.toStringAsFixed(1)
              : '',
          decoration: InputDecoration(
            labelText: hint,
            suffixText: 'kg',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(KSizes.radiusM),
            ),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (value) {
            final weight = double.tryParse(value);
            if (weight != null && weight > 0) {
              notifier.updateTargetWeight(weight);
            }
          },
        ),
        if (currentWeight > 0) ...[
          SizedBox(height: KSizes.margin2x),
          Text(
            'Din nuværende vægt: ${currentWeight.toStringAsFixed(1)} kg',
            style: TextStyle(
              fontSize: KSizes.fontSizeS,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }
} 