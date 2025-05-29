import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../application/onboarding_notifier.dart';
import '../../domain/user_profile_model.dart';

/// Goal step widget for setting user goals
class GoalStepWidget extends ConsumerWidget {
  const GoalStepWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: KSizes.margin4x),
          
          Text(
            'Hvad er dit mål?',
            style: TextStyle(
              fontSize: KSizes.fontSizeXL,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: KSizes.margin2x),
          
          Text(
            'Vælg dit primære mål for at få den bedste oplevelse',
            style: TextStyle(
              fontSize: KSizes.fontSizeM,
              color: AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: KSizes.margin6x),
          
          // Goal options
          _GoalOption(
            icon: MdiIcons.trendingDown,
            title: 'Tab vægt',
            description: 'Skab et kalorieunderskud',
            isSelected: state.userProfile.goalType == GoalType.weightLoss,
            onTap: () => notifier.updateGoalType(GoalType.weightLoss),
          ),
          
          const SizedBox(height: KSizes.margin3x),
          
          _GoalOption(
            icon: MdiIcons.scale,
            title: 'Vedligehold vægt',
            description: 'Hold din nuværende vægt',
            isSelected: state.userProfile.goalType == GoalType.weightMaintenance,
            onTap: () => notifier.updateGoalType(GoalType.weightMaintenance),
          ),
          
          const SizedBox(height: KSizes.margin3x),
          
          _GoalOption(
            icon: MdiIcons.trendingUp,
            title: 'Øg vægt',
            description: 'Skab et kalorieoverskud',
            isSelected: state.userProfile.goalType == GoalType.weightGain,
            onTap: () => notifier.updateGoalType(GoalType.weightGain),
          ),
          
          const SizedBox(height: KSizes.margin3x),
          
          _GoalOption(
            icon: MdiIcons.dumbbell,
            title: 'Byg muskler',
            description: 'Fokus på muskelopbygning',
            isSelected: state.userProfile.goalType == GoalType.muscleGain,
            onTap: () => notifier.updateGoalType(GoalType.muscleGain),
          ),
          
          const SizedBox(height: KSizes.margin6x),
        ],
      ),
    );
  }
}

class _GoalOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(KSizes.margin4x),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(KSizes.radiusL),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(KSizes.radiusM),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.textSecondary,
                size: 24,
              ),
            ),
            
            const SizedBox(width: KSizes.margin3x),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: KSizes.fontSizeL,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: KSizes.fontSizeM,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
} 