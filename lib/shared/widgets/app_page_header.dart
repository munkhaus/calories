import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../core/constants/k_sizes.dart';
import '../../core/theme/app_theme.dart';

/// Universal header widget matching onboarding design pattern
class AppPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? greeting;
  final String? userName;
  final bool showInfoButton;
  final bool showNotificationButton;
  final VoidCallback? onInfoTap;
  final VoidCallback? onNotificationTap;
  final IconData? titleIcon;
  final Color? titleIconColor;

  const AppPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.greeting,
    this.userName,
    this.showInfoButton = true,
    this.showNotificationButton = false,
    this.onInfoTap,
    this.onNotificationTap,
    this.titleIcon,
    this.titleIconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KSizes.margin4x),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main header content
          Row(
            children: [
              // Icon and title section
              Expanded(
                child: Row(
                  children: [
                    if (titleIcon != null) ...[
                      Container(
                        padding: const EdgeInsets.all(KSizes.margin3x),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              titleIconColor ?? AppColors.primary,
                              (titleIconColor ?? AppColors.primary).withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(KSizes.radiusM),
                          boxShadow: [
                            BoxShadow(
                              color: (titleIconColor ?? AppColors.primary).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          titleIcon!,
                          color: Colors.white,
                          size: KSizes.iconL,
                        ),
                      ),
                      const SizedBox(width: KSizes.margin4x),
                    ],
                    
                    // Title and subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (greeting != null && userName != null) ...[
                            Text(
                              greeting!,
                              style: TextStyle(
                                fontSize: KSizes.fontSizeS,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              userName!,
                              style: TextStyle(
                                fontSize: KSizes.fontSizeXXL,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ] else ...[
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: KSizes.fontSizeXXL,
                                fontWeight: KSizes.fontWeightBold,
                                color: AppColors.textPrimary,
                                height: 1.2,
                              ),
                            ),
                            if (subtitle != null) ...[
                              const SizedBox(height: KSizes.margin2x),
                              Text(
                                subtitle!,
                                style: TextStyle(
                                  fontSize: KSizes.fontSizeL,
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Action buttons
              Row(
                children: [
                  if (showInfoButton) ...[
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(KSizes.radiusL),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: onInfoTap,
                        icon: Icon(
                          MdiIcons.informationOutline,
                          color: AppColors.info,
                          size: KSizes.iconM,
                        ),
                      ),
                    ),
                    if (showNotificationButton)
                      const SizedBox(width: KSizes.margin2x),
                  ],
                  
                  if (showNotificationButton)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(KSizes.radiusL),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: onNotificationTap,
                        icon: Icon(
                          MdiIcons.bellOutline,
                          color: AppColors.primary,
                          size: KSizes.iconM,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Header specifically for dashboard with greeting
class DashboardHeader extends StatelessWidget {
  final String greeting;
  final String userName;
  final VoidCallback? onInfoTap;
  final VoidCallback? onNotificationTap;

  const DashboardHeader({
    super.key,
    required this.greeting,
    required this.userName,
    this.onInfoTap,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppPageHeader(
      title: '', // Not used for dashboard
      greeting: greeting,
      userName: userName,
      showInfoButton: true,
      showNotificationButton: true,
      onInfoTap: onInfoTap,
      onNotificationTap: onNotificationTap,
    );
  }
}

/// Header for other pages with title and subtitle
class StandardPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onInfoTap;

  const StandardPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.onInfoTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppPageHeader(
      title: title,
      subtitle: subtitle,
      titleIcon: icon,
      titleIconColor: iconColor,
      showInfoButton: true,
      showNotificationButton: false,
      onInfoTap: onInfoTap,
    );
  }
} 