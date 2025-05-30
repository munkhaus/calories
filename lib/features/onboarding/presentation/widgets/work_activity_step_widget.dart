import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../application/onboarding_notifier.dart';
import '../../domain/user_profile_model.dart';

/// Step for selecting work activity level
class WorkActivityStepWidget extends ConsumerWidget {
  const WorkActivityStepWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Text(
          'Dit arbejde',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: KSizes.fontWeightBold,
            color: AppColors.textPrimary,
          ),
        ),
        
        SizedBox(height: KSizes.margin2x),
        
        Text(
          'Hvor fysisk krævende er dit arbejde? Dette påvirker din daglige kalorieforbrug.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        
        SizedBox(height: KSizes.margin8x),
        
        // Work activity selection
        Container(
          padding: EdgeInsets.all(KSizes.margin4x),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(KSizes.radiusL),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Column(
            children: [
              _buildWorkActivityOption(
                context,
                notifier,
                state.userProfile.workActivityLevel,
                WorkActivityLevel.sedentary,
                'Kontorarbejde',
                'Sidder hovedsageligt ved skrivebord',
                MdiIcons.laptop,
                AppColors.info,
              ),
              
              SizedBox(height: KSizes.margin4x),
              
              _buildWorkActivityOption(
                context,
                notifier,
                state.userProfile.workActivityLevel,
                WorkActivityLevel.light,
                'Let fysisk arbejde',
                'Lidt gang og stående arbejde',
                MdiIcons.walk,
                AppColors.primary,
              ),
              
              SizedBox(height: KSizes.margin4x),
              
              _buildWorkActivityOption(
                context,
                notifier,
                state.userProfile.workActivityLevel,
                WorkActivityLevel.moderate,
                'Moderat fysisk arbejde',
                'Regelmæssig gang og lettere løft',
                MdiIcons.hammer,
                AppColors.warning,
              ),
              
              SizedBox(height: KSizes.margin4x),
              
              _buildWorkActivityOption(
                context,
                notifier,
                state.userProfile.workActivityLevel,
                WorkActivityLevel.heavy,
                'Hård fysisk arbejde',
                'Meget gang, løft og fysisk aktivitet',
                MdiIcons.dumbbell,
                AppColors.secondary,
              ),
              
              SizedBox(height: KSizes.margin4x),
              
              _buildWorkActivityOption(
                context,
                notifier,
                state.userProfile.workActivityLevel,
                WorkActivityLevel.veryHeavy,
                'Meget hård fysisk arbejde',
                'Konstant tung fysisk aktivitet',
                MdiIcons.weightLifter,
                AppColors.error,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWorkActivityOption(
    BuildContext context,
    OnboardingNotifier notifier,
    WorkActivityLevel? currentLevel,
    WorkActivityLevel level,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    final isSelected = currentLevel == level;
    
    return GestureDetector(
      onTap: () {
        notifier.updateWorkActivityLevel(level);
        // Always enable automatic weekday detection - no user choice
        notifier.updateWeekdayDetection(true);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.all(KSizes.margin4x),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(KSizes.radiusM),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.2) : AppColors.background,
                borderRadius: BorderRadius.circular(KSizes.radiusM),
              ),
              child: Icon(
                icon,
                color: isSelected ? color : AppColors.textSecondary,
                size: KSizes.iconM,
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
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: KSizes.margin1x),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: KSizes.fontSizeS,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            if (isSelected)
              Icon(
                MdiIcons.checkCircle,
                color: color,
                size: KSizes.iconM,
              ),
          ],
        ),
      ),
    );
  }
} 