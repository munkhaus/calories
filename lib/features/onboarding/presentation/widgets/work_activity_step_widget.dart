import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../application/onboarding_notifier.dart';
import '../../domain/user_profile_model.dart';
import 'onboarding_base_layout.dart';

class WorkActivityStepWidget extends ConsumerWidget {
  const WorkActivityStepWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return OnboardingBaseLayout(
      title: '💼 Hvor fysisk krævende er dit arbejde?',
      subtitle: 'Dit arbejde påvirker hvor mange kalorier du forbrænder dagligt',
      children: [
        OnboardingSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OnboardingSectionHeader(
                icon: Icons.business_center,
                title: 'Vælg dit aktivitetsniveau',
                subtitle: 'Hvad laver du mest på arbejde?',
                iconColor: AppColors.primary,
              ),
              
              KSizes.spacingVerticalL,
              
              // Work activity level cards with consistent primary color
              OnboardingOptionCard(
                title: 'Stillesiddende',
                description: 'Kontorarbejde, mest ved skrivebord',
                icon: Icons.computer,
                color: AppColors.primary,
                isSelected: state.userProfile.workActivityLevel == WorkActivityLevel.sedentary,
                onTap: () => notifier.updateWorkActivityLevel(WorkActivityLevel.sedentary),
              ),
              
              KSizes.spacingVerticalM,
              
              OnboardingOptionCard(
                title: 'Let aktivitet',
                description: 'Lærere, butiksassistenter, let fysisk arbejde',
                icon: Icons.person_2,
                color: AppColors.primary,
                isSelected: state.userProfile.workActivityLevel == WorkActivityLevel.light,
                onTap: () => notifier.updateWorkActivityLevel(WorkActivityLevel.light),
              ),
              
              KSizes.spacingVerticalM,
              
              OnboardingOptionCard(
                title: 'Moderat aktivitet',
                description: 'Sygeplejersker, håndværkere, service',
                icon: Icons.build,
                color: AppColors.primary,
                isSelected: state.userProfile.workActivityLevel == WorkActivityLevel.moderate,
                onTap: () => notifier.updateWorkActivityLevel(WorkActivityLevel.moderate),
              ),
              
              KSizes.spacingVerticalM,
              
              OnboardingOptionCard(
                title: 'Tung aktivitet',
                description: 'Byggearbejdere, landmænd, flyttemænd',
                icon: Icons.fitness_center,
                color: AppColors.primary,
                isSelected: state.userProfile.workActivityLevel == WorkActivityLevel.heavy,
                onTap: () => notifier.updateWorkActivityLevel(WorkActivityLevel.heavy),
              ),
              
              KSizes.spacingVerticalM,
              
              OnboardingOptionCard(
                title: 'Meget tung aktivitet',
                description: 'Meget krævende fysisk arbejde, tungt løft',
                icon: Icons.construction,
                color: AppColors.primary,
                isSelected: state.userProfile.workActivityLevel == WorkActivityLevel.veryHeavy,
                onTap: () => notifier.updateWorkActivityLevel(WorkActivityLevel.veryHeavy),
              ),
            ],
          ),
        ),
        
        KSizes.spacingVerticalL,
        
        // Information help text
        OnboardingHelpText(
          text: 'Dit arbejdsniveau påvirker dit daglige kalorieforbrug.',
          icon: Icons.info_outline,
          color: AppColors.info,
        ),
      ],
    );
  }
} 