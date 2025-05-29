import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../application/onboarding_notifier.dart';
import '../../domain/user_profile_model.dart';
import 'onboarding_base_layout.dart';

/// Activity step widget for setting activity level
class ActivityStepWidget extends ConsumerWidget {
  const ActivityStepWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return OnboardingBaseLayout(
      children: [
        OnboardingSectionHeader(
          icon: MdiIcons.run,
          title: 'Dit aktivitetsniveau',
          subtitle: 'Hvor aktiv er du i din hverdag?',
        ),
        
        KSizes.spacingVerticalL,
        
        // Activity level options
        OnboardingSection(
          child: Column(
            children: [
              _ActivityOption(
                icon: MdiIcons.seatReclineNormal,
                title: 'Stillesiddende',
                description: 'Kontorarbejde, lidt motion',
                isSelected: state.userProfile.activityLevel == ActivityLevel.sedentary,
                onTap: () => notifier.updateActivityLevel(ActivityLevel.sedentary),
              ),
              
              KSizes.spacingVerticalM,
              
              _ActivityOption(
                icon: MdiIcons.walk,
                title: 'Let aktiv',
                description: '1-3 dage træning om ugen',
                isSelected: state.userProfile.activityLevel == ActivityLevel.lightlyActive,
                onTap: () => notifier.updateActivityLevel(ActivityLevel.lightlyActive),
              ),
              
              KSizes.spacingVerticalM,
              
              _ActivityOption(
                icon: MdiIcons.run,
                title: 'Moderat aktiv',
                description: '3-5 dage træning om ugen',
                isSelected: state.userProfile.activityLevel == ActivityLevel.moderatelyActive,
                onTap: () => notifier.updateActivityLevel(ActivityLevel.moderatelyActive),
              ),
              
              KSizes.spacingVerticalM,
              
              _ActivityOption(
                icon: MdiIcons.bike,
                title: 'Meget aktiv',
                description: '6-7 dage træning om ugen',
                isSelected: state.userProfile.activityLevel == ActivityLevel.veryActive,
                onTap: () => notifier.updateActivityLevel(ActivityLevel.veryActive),
              ),
              
              KSizes.spacingVerticalM,
              
              _ActivityOption(
                icon: MdiIcons.dumbbell,
                title: 'Ekstra aktiv',
                description: 'Daglig træning + fysisk job',
                isSelected: state.userProfile.activityLevel == ActivityLevel.extraActive,
                onTap: () => notifier.updateActivityLevel(ActivityLevel.extraActive),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivityOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _ActivityOption({
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
        decoration: AppDesign.sectionDecoration.copyWith(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
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
            
            KSizes.spacingHorizontalM,
            
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