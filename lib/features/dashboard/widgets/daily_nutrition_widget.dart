import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../core/constants/k_sizes.dart';
import '../../../core/theme/app_theme.dart';

/// Widget showing daily nutrition/macro breakdown
class DailyNutritionWidget extends ConsumerWidget {
  const DailyNutritionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppColors.primary.withOpacity(0.02),
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
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.success, AppColors.primary],
                    ),
                    borderRadius: BorderRadius.circular(KSizes.radiusM),
                  ),
                  child: Icon(
                    MdiIcons.nutrition,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Dagens makroer',
                    style: TextStyle(
                      fontSize: KSizes.fontSizeL,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(KSizes.radiusS),
                  ),
                  child: Text(
                    'På sporet',
                    style: TextStyle(
                      fontSize: KSizes.fontSizeXS,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: KSizes.margin3x),
            
            // Macro cards
            Row(
              children: [
                Expanded(
                  child: _MacroCard(
                    title: 'Protein',
                    consumed: 45,
                    target: 150,
                    unit: 'g',
                    color: AppColors.error,
                    icon: MdiIcons.food,
                  ),
                ),
                const SizedBox(width: KSizes.margin2x),
                Expanded(
                  child: _MacroCard(
                    title: 'Kulhydrat',
                    consumed: 120,
                    target: 200,
                    unit: 'g',
                    color: AppColors.warning,
                    icon: MdiIcons.foodVariant,
                  ),
                ),
                const SizedBox(width: KSizes.margin2x),
                Expanded(
                  child: _MacroCard(
                    title: 'Fedt',
                    consumed: 25,
                    target: 67,
                    unit: 'g',
                    color: AppColors.success,
                    icon: MdiIcons.foodApple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String title;
  final int consumed;
  final int target;
  final String unit;
  final Color color;
  final IconData icon;

  const _MacroCard({
    required this.title,
    required this.consumed,
    required this.target,
    required this.unit,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (consumed / target).clamp(0.0, 1.0);
    final remaining = (target - consumed).clamp(0, double.infinity);

    return Container(
      padding: const EdgeInsets.all(KSizes.margin2x),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(KSizes.radiusL),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon and title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 10,
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 6),
          
          // Progress circle
          SizedBox(
            width: 35,
            height: 35,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 35,
                  height: 35,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 3,
                    backgroundColor: color.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 6),
          
          // Current value
          Text(
            '$consumed$unit',
            style: TextStyle(
              fontSize: KSizes.fontSizeM,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          
          // Target info - simplified
          Text(
            'af $target$unit',
            style: TextStyle(
              fontSize: 9,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
} 