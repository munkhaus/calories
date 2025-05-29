import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../application/onboarding_notifier.dart';
import '../../domain/user_profile_model.dart';

/// Activity step widget for setting activity level
class ActivityStepWidget extends ConsumerWidget {
  const ActivityStepWidget({super.key});

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
            'Dit aktivitetsniveau',
            style: TextStyle(
              fontSize: KSizes.fontSizeXL,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: KSizes.margin2x),
          
          Text(
            'Hvor aktiv er du i din hverdag?',
            style: TextStyle(
              fontSize: KSizes.fontSizeM,
              color: AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: KSizes.margin6x),
          
          // Activity level options
          _ActivityOption(
            icon: MdiIcons.seatReclineNormal,
            title: 'Stillesiddende',
            description: 'Kontorarbejde, lidt motion',
            isSelected: state.userProfile.activityLevel == ActivityLevel.sedentary,
            onTap: () => notifier.updateActivityLevel(ActivityLevel.sedentary),
          ),
          
          const SizedBox(height: KSizes.margin3x),
          
          _ActivityOption(
            icon: MdiIcons.walk,
            title: 'Let aktiv',
            description: '1-3 dage træning om ugen',
            isSelected: state.userProfile.activityLevel == ActivityLevel.lightlyActive,
            onTap: () => notifier.updateActivityLevel(ActivityLevel.lightlyActive),
          ),
          
          const SizedBox(height: KSizes.margin3x),
          
          _ActivityOption(
            icon: MdiIcons.run,
            title: 'Moderat aktiv',
            description: '3-5 dage træning om ugen',
            isSelected: state.userProfile.activityLevel == ActivityLevel.moderatelyActive,
            onTap: () => notifier.updateActivityLevel(ActivityLevel.moderatelyActive),
          ),
          
          const SizedBox(height: KSizes.margin3x),
          
          _ActivityOption(
            icon: MdiIcons.bike,
            title: 'Meget aktiv',
            description: '6-7 dage træning om ugen',
            isSelected: state.userProfile.activityLevel == ActivityLevel.veryActive,
            onTap: () => notifier.updateActivityLevel(ActivityLevel.veryActive),
          ),
          
          const SizedBox(height: KSizes.margin3x),
          
          _ActivityOption(
            icon: MdiIcons.dumbbell,
            title: 'Ekstra aktiv',
            description: 'Daglig træning + fysisk job',
            isSelected: state.userProfile.activityLevel == ActivityLevel.extraActive,
            onTap: () => notifier.updateActivityLevel(ActivityLevel.extraActive),
          ),
          
          const SizedBox(height: KSizes.margin6x),
        ],
      ),
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