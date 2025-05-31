import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../core/constants/k_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../onboarding/application/onboarding_notifier.dart';
import '../../onboarding/domain/user_profile_model.dart';

/// Separate widget for daily settings toggles
class DailySettingsWidget extends ConsumerWidget {
  const DailySettingsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingProvider);
    final userProfile = onboardingState.userProfile;

    // Don't show if no new activity system
    if (userProfile.workActivityLevel == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(KSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.info.withOpacity(0.08),
            blurRadius: KSizes.blurRadiusL,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(KSizes.margin3x),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.info,
                      AppColors.info.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.info.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  MdiIcons.tune,
                  color: Colors.white,
                  size: KSizes.iconL,
                ),
              ),
              const SizedBox(width: KSizes.margin4x),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dagens indstillinger ⚙️',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeXL,
                        fontWeight: KSizes.fontWeightBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Juster for dagens aktivitetsniveau',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeM,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: KSizes.margin6x),
          
          // Toggle sections
          Column(
            children: [
              _WorkDayToggleSection(userProfile: userProfile),
              
              const SizedBox(height: KSizes.margin4x),
              
              if (_shouldShowLeisureToggle(userProfile))
                _LeisureActivityToggleSection(userProfile: userProfile),
            ],
          ),
        ],
      ),
    );
  }

  bool _shouldShowLeisureToggle(UserProfileModel profile) {
    return profile.activityTrackingPreference != ActivityTrackingPreference.manual;
  }
}

/// Work day toggle section
class _WorkDayToggleSection extends ConsumerWidget {
  final UserProfileModel userProfile;

  const _WorkDayToggleSection({required this.userProfile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(onboardingProvider.notifier);
    
    final isWorkDay = userProfile.useAutomaticWeekdayDetection 
        ? (DateTime.now().weekday >= 1 && DateTime.now().weekday <= 5)
        : userProfile.isCurrentlyWorkDay;
    
    return Container(
      padding: const EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(
          color: AppColors.border.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon and labels
          Container(
            padding: const EdgeInsets.all(KSizes.margin2x),
            decoration: BoxDecoration(
              color: (isWorkDay ? AppColors.primary : AppColors.secondary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(KSizes.radiusS),
            ),
            child: Icon(
              isWorkDay ? MdiIcons.briefcase : MdiIcons.home,
              color: isWorkDay ? AppColors.primary : AppColors.secondary,
              size: KSizes.iconM,
            ),
          ),
          
          const SizedBox(width: KSizes.margin3x),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isWorkDay ? 'Arbejdsdag' : 'Hjemme/fridag',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeM,
                    fontWeight: KSizes.fontWeightBold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  isWorkDay 
                      ? 'Højere aktivitetsniveau på arbejde'
                      : 'Lavere aktivitetsniveau derhjemme',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeS,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Toggle switch
          GestureDetector(
            onTap: () {
              notifier.updateWeekdayDetection(false);
              notifier.updateCurrentWorkDayStatus(!isWorkDay);
            },
            child: Container(
              width: 48,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: isWorkDay 
                    ? AppColors.primary 
                    : AppColors.border.withOpacity(0.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: isWorkDay ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Leisure activity toggle section
class _LeisureActivityToggleSection extends ConsumerWidget {
  final UserProfileModel userProfile;

  const _LeisureActivityToggleSection({required this.userProfile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(onboardingProvider.notifier);
    final isLeisureEnabled = userProfile.isLeisureActivityEnabledToday;
    
    return Container(
      padding: const EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(
          color: AppColors.border.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon and labels
          Container(
            padding: const EdgeInsets.all(KSizes.margin2x),
            decoration: BoxDecoration(
              color: (isLeisureEnabled ? AppColors.success : AppColors.textSecondary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(KSizes.radiusS),
            ),
            child: Icon(
              isLeisureEnabled ? MdiIcons.run : MdiIcons.sleep,
              color: isLeisureEnabled ? AppColors.success : AppColors.textSecondary,
              size: KSizes.iconM,
            ),
          ),
          
          const SizedBox(width: KSizes.margin3x),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLeisureEnabled ? 'Fritidsaktivitet tæller' : 'Ingen fritidsaktivitet',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeM,
                    fontWeight: KSizes.fontWeightBold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  isLeisureEnabled 
                      ? 'Motion og fritidsaktiviteter medregnes'
                      : 'Kun hvile og grundaktiviteter i dag',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeS,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Toggle switch
          GestureDetector(
            onTap: () {
              notifier.updateLeisureActivityForToday(!isLeisureEnabled);
            },
            child: Container(
              width: 48,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: isLeisureEnabled 
                    ? AppColors.success 
                    : AppColors.border.withOpacity(0.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: isLeisureEnabled ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 