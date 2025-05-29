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
    return Container(
      decoration: BoxDecoration(
        gradient: AppDesign.backgroundGradient,
      ),
      child: Column(
        children: [
          // Main content area with scroll
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(KSizes.margin4x),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: KSizes.margin4x),
                  
                  // Hero section with proper container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(KSizes.margin6x),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(KSizes.radiusXL),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.08),
                          blurRadius: KSizes.blurRadiusXL,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.8),
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Heart icon with proper container
                        Container(
                          width: 80,
                          height: 80,
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
                                blurRadius: KSizes.blurRadiusL,
                                offset: KSizes.shadowOffsetM,
                              ),
                            ],
                          ),
                          child: Icon(
                            MdiIcons.heart,
                            size: KSizes.iconXL,
                            color: Colors.white,
                          ),
                        ),
                        
                        const SizedBox(height: KSizes.margin4x),
                        
                        // Welcome text
                        Text(
                          'Velkommen til din\nsunde rejse! 🎯',
                          style: TextStyle(
                            fontSize: KSizes.fontSizeXXL,
                            fontWeight: KSizes.fontWeightBold,
                            color: AppColors.textPrimary,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: KSizes.margin2x),
                        
                        Text(
                          'Lad os komme i gang med at opsætte din personlige kalorietræker.',
                          style: TextStyle(
                            fontSize: KSizes.fontSizeL,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: KSizes.margin6x),
                  
                  // Feature highlights in container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(KSizes.margin4x),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(KSizes.radiusXL),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.08),
                          blurRadius: KSizes.blurRadiusL,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _buildFeatureCards(),
                  ),
                  
                  const SizedBox(height: KSizes.margin4x),
                  
                  // Call to action in container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(KSizes.margin4x),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.success.withOpacity(0.1),
                          AppColors.primary.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(KSizes.radiusL),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(KSizes.margin2x),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(KSizes.radiusM),
                          ),
                          child: Icon(
                            MdiIcons.checkCircle,
                            color: Colors.white,
                            size: KSizes.iconM,
                          ),
                        ),
                        const SizedBox(width: KSizes.margin3x),
                        Expanded(
                          child: Text(
                            'Det tager kun 2-3 minutter',
                            style: TextStyle(
                              fontSize: KSizes.fontSizeL,
                              fontWeight: KSizes.fontWeightSemiBold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: KSizes.margin6x),
                ],
              ),
            ),
          ),
          
          // Bottom button area - fixed at bottom
          Container(
            padding: const EdgeInsets.all(KSizes.margin4x),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              border: Border(
                top: BorderSide(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: CustomButton(
                text: 'Kom i gang',
                variant: ButtonVariant.primary,
                onPressed: () => ref.read(onboardingProvider.notifier).nextStep(),
                icon: MdiIcons.arrowRight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCards() {
    final features = [
      _FeatureData(
        icon: MdiIcons.target,
        title: 'Personlige mål',
        description: 'Sæt realistiske mål baseret på dine behov',
        color: AppColors.primary,
      ),
      _FeatureData(
        icon: MdiIcons.chartLine,
        title: 'Smart tracking',
        description: 'Nem og hurtig logging af mad og aktivitet',
        color: AppColors.info,
      ),
      _FeatureData(
        icon: MdiIcons.trophy,
        title: 'Se resultater',
        description: 'Følg din fremgang mod dine mål',
        color: AppColors.success,
      ),
    ];

    return Column(
      children: [
        Text(
          'Hvad kan du forvente?',
          style: TextStyle(
            fontSize: KSizes.fontSizeL,
            fontWeight: KSizes.fontWeightSemiBold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: KSizes.margin4x),
        ...features.asMap().entries.map((entry) {
          final index = entry.key;
          final feature = entry.value;
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(KSizes.margin3x),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      feature.color.withOpacity(0.08),
                      feature.color.withOpacity(0.02),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(KSizes.radiusL),
                  border: Border.all(
                    color: feature.color.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            feature.color,
                            feature.color.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(KSizes.radiusL),
                      ),
                      child: Icon(
                        feature.icon,
                        color: Colors.white,
                        size: KSizes.iconM,
                      ),
                    ),
                    const SizedBox(width: KSizes.margin3x),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            feature.title,
                            style: TextStyle(
                              fontSize: KSizes.fontSizeL,
                              fontWeight: KSizes.fontWeightSemiBold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            feature.description,
                            style: TextStyle(
                              fontSize: KSizes.fontSizeM,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (index < features.length - 1) const SizedBox(height: KSizes.margin2x),
            ],
          );
        }).toList(),
      ],
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