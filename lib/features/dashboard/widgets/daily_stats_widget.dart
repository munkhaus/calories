import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../core/constants/k_sizes.dart';
import '../../../core/theme/app_theme.dart';

/// Widget showing daily macros breakdown
class DailyStatsWidget extends ConsumerWidget {
  const DailyStatsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Get actual macro data from food log
    const proteinConsumed = 65;
    const proteinTarget = 120;
    const carbsConsumed = 180;
    const carbsTarget = 250;
    const fatConsumed = 45;
    const fatTarget = 80;

    return Container(
      height: KSizes.sectionHeightXL,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppColors.secondary.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(KSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(KSizes.margin4x),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(KSizes.margin2x),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.secondary.withOpacity(0.2),
                        AppColors.primary.withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(KSizes.radiusM),
                  ),
                  child: Icon(
                    MdiIcons.chartDonut,
                    color: AppColors.secondary,
                    size: KSizes.iconS,
                  ),
                ),
                KSizes.spacingHorizontalM,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Næringsstoffer',
                        style: TextStyle(
                          fontSize: KSizes.fontSizeL,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Protein • Kulhydrater • Fedt',
                        style: TextStyle(
                          fontSize: KSizes.fontSizeXS,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            KSizes.spacingVerticalL,
            
            // Enhanced macro items with cards - expanded to fill remaining space
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _MacroCard(
                      icon: MdiIcons.fishOff,
                      label: 'Protein',
                      consumed: proteinConsumed,
                      target: proteinTarget,
                      unit: 'g',
                      color: AppColors.error,
                      backgroundColor: AppColors.error.withOpacity(0.1),
                    ),
                  ),
                  KSizes.spacingHorizontalM,
                  Expanded(
                    child: _MacroCard(
                      icon: MdiIcons.grain,
                      label: 'Kulhydrater',
                      consumed: carbsConsumed,
                      target: carbsTarget,
                      unit: 'g',
                      color: AppColors.warning,
                      backgroundColor: AppColors.warning.withOpacity(0.1),
                    ),
                  ),
                  KSizes.spacingHorizontalM,
                  Expanded(
                    child: _MacroCard(
                      icon: MdiIcons.water,
                      label: 'Fedt',
                      consumed: fatConsumed,
                      target: fatTarget,
                      unit: 'g',
                      color: AppColors.info,
                      backgroundColor: AppColors.info.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int consumed;
  final int target;
  final String unit;
  final Color color;
  final Color backgroundColor;

  const _MacroCard({
    required this.icon,
    required this.label,
    required this.consumed,
    required this.target,
    required this.unit,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final progress = target > 0 ? (consumed / target).clamp(0.0, 1.0) : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(KSizes.radiusL),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(KSizes.margin2x),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Icon and label
            Icon(
              icon,
              color: color,
              size: KSizes.iconS,
            ),
            
            Text(
              label,
              style: TextStyle(
                fontSize: KSizes.fontSizeXS,
                color: color,
                fontWeight: KSizes.fontWeightMedium,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Values
            Column(
              children: [
                Text(
                  '$consumed',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeL,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Text(
                  '/ $target $unit',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeXS,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            
            // Progress bar
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(2),
                border: Border.all(
                  color: color.withOpacity(0.3),
                  width: 0.5,
                ),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(KSizes.radiusS),
                  ),
                ),
              ),
            ),
            
            KSizes.spacingVerticalXS,
            
            // Percentage
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: KSizes.fontSizeXS,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 