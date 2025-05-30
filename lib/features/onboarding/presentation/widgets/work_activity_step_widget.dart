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
      title: 'Hvor fysisk krævende er dit arbejde?',
      subtitle: 'Dit arbejde påvirker hvor mange kalorier du forbrænder dagligt',
      children: [
        OnboardingSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OnboardingSectionHeader(
                title: 'Vælg dit aktivitetsniveau',
                subtitle: 'Hvad laver du mest på arbejde?',
              ),
              
              KSizes.spacingVerticalL,
              
              // Work activity level cards - simplified without icons
              OnboardingOptionCard(
                title: 'Stillesiddende',
                description: 'Kontorarbejde, mest ved skrivebord',
                isSelected: state.userProfile.workActivityLevel == WorkActivityLevel.sedentary,
                onTap: () => notifier.updateWorkActivityLevel(WorkActivityLevel.sedentary),
              ),
              
              OnboardingOptionCard(
                title: 'Let aktivitet',
                description: 'Lærere, butiksassistenter, let fysisk arbejde',
                isSelected: state.userProfile.workActivityLevel == WorkActivityLevel.light,
                onTap: () => notifier.updateWorkActivityLevel(WorkActivityLevel.light),
              ),
              
              OnboardingOptionCard(
                title: 'Moderat aktivitet',
                description: 'Sygeplejersker, håndværkere, service',
                isSelected: state.userProfile.workActivityLevel == WorkActivityLevel.moderate,
                onTap: () => notifier.updateWorkActivityLevel(WorkActivityLevel.moderate),
              ),
              
              OnboardingOptionCard(
                title: 'Tung aktivitet',
                description: 'Byggearbejdere, landmænd, flyttemænd',
                isSelected: state.userProfile.workActivityLevel == WorkActivityLevel.heavy,
                onTap: () => notifier.updateWorkActivityLevel(WorkActivityLevel.heavy),
              ),
              
              OnboardingOptionCard(
                title: 'Meget tung aktivitet',
                description: 'Meget krævende fysisk arbejde, tungt løft',
                isSelected: state.userProfile.workActivityLevel == WorkActivityLevel.veryHeavy,
                onTap: () => notifier.updateWorkActivityLevel(WorkActivityLevel.veryHeavy),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 