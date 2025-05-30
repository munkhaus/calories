import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../core/constants/k_sizes.dart';
import '../../core/theme/app_theme.dart';

/// Enhanced option card matching onboarding design pattern
class AppOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback onTap;
  final bool showArrow;
  final Widget? trailingWidget;

  const AppOptionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.backgroundColor,
    this.showArrow = true,
    this.trailingWidget,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? AppColors.primary;
    
    return Container(
      margin: EdgeInsets.only(bottom: KSizes.margin3x),
      child: Material(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(KSizes.radiusXL),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(KSizes.radiusXL),
          child: Container(
            padding: EdgeInsets.all(KSizes.margin4x),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(KSizes.radiusXL),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.08),
                  blurRadius: KSizes.blurRadiusL,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: AppColors.border.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        effectiveIconColor,
                        effectiveIconColor.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(KSizes.radiusM),
                    boxShadow: [
                      BoxShadow(
                        color: effectiveIconColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: KSizes.iconL,
                  ),
                ),
                
                SizedBox(width: KSizes.margin4x),
                
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: KSizes.fontWeightBold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: KSizes.margin1x),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Trailing widget or arrow
                if (trailingWidget != null)
                  trailingWidget!
                else if (showArrow)
                  Icon(
                    MdiIcons.chevronRight,
                    color: AppColors.textTertiary,
                    size: KSizes.iconM,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Meal type option card
class MealTypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const MealTypeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppOptionCard(
      title: title,
      subtitle: subtitle,
      icon: icon,
      iconColor: iconColor,
      onTap: onTap,
    );
  }
}

/// Activity option card with calories display
class ActivityOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final String? caloriesInfo;

  const ActivityOptionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.caloriesInfo,
  });

  @override
  Widget build(BuildContext context) {
    return AppOptionCard(
      title: title,
      subtitle: subtitle,
      icon: icon,
      iconColor: AppColors.secondary,
      onTap: onTap,
      trailingWidget: caloriesInfo != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  caloriesInfo!,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: KSizes.fontWeightBold,
                    color: AppColors.secondary,
                  ),
                ),
                Icon(
                  MdiIcons.chevronRight,
                  color: AppColors.textTertiary,
                  size: KSizes.iconM,
                ),
              ],
            )
          : null,
    );
  }
}

/// Profile option card with optional info
class ProfileOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final String? infoText;
  final Color? infoColor;

  const ProfileOptionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.infoText,
    this.infoColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppOptionCard(
      title: title,
      subtitle: subtitle,
      icon: icon,
      iconColor: AppColors.primary,
      onTap: onTap,
      trailingWidget: infoText != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  infoText!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: KSizes.fontWeightMedium,
                    color: infoColor ?? AppColors.textSecondary,
                  ),
                ),
                Icon(
                  MdiIcons.chevronRight,
                  color: AppColors.textTertiary,
                  size: KSizes.iconM,
                ),
              ],
            )
          : null,
    );
  }
} 