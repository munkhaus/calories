import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../application/onboarding_notifier.dart';

/// Welcome step widget for onboarding
class WelcomeStepWidget extends ConsumerWidget {
  const WelcomeStepWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          
          // Hero section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.primary.withOpacity(0.05),
                  Colors.transparent,
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.secondary,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                MdiIcons.heart,
                size: 32,
                color: Colors.white,
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Welcome text
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  AppColors.primary.withOpacity(0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(KSizes.radiusL),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.white,
                  blurRadius: 6,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Velkommen til din\nsunde rejse! 🎯',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Lad os komme i gang med at opsætte din personlige kalorietræker.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Feature highlights
          _buildFeatureCards(),
          
          const SizedBox(height: 16),
          
          // Call to action
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.success.withOpacity(0.1),
                  AppColors.primary.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(KSizes.radiusM),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(KSizes.radiusS),
                  ),
                  child: Icon(
                    MdiIcons.checkCircle,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Det tager kun 2-3 minutter',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Start button
          CustomButton(
            text: 'Kom i gang',
            variant: ButtonVariant.primary,
            onPressed: () => ref.read(onboardingProvider.notifier).nextStep(),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFeatureCards() {
    final features = [
      _FeatureData(
        icon: MdiIcons.target,
        title: 'Personlige mål',
        description: 'Sæt realistiske mål',
        color: AppColors.primary,
      ),
      _FeatureData(
        icon: MdiIcons.chartLine,
        title: 'Smart tracking',
        description: 'Nem logging',
        color: AppColors.info,
      ),
      _FeatureData(
        icon: MdiIcons.trophy,
        title: 'Resultater',
        description: 'Se din fremgang',
        color: AppColors.success,
      ),
    ];

    return Column(
      children: features.map((feature) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                feature.color.withOpacity(0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(KSizes.radiusL),
            boxShadow: [
              BoxShadow(
                color: feature.color.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      feature.color,
                      feature.color.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                ),
                child: Icon(
                  feature.icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      feature.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }
}

class _FeatureData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  _FeatureData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
} 