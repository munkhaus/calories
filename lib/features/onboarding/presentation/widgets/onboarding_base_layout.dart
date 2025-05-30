import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';

/// Base layout for onboarding steps with consistent styling
class OnboardingBaseLayout extends StatelessWidget {
  final List<Widget> children;
  final String? title;
  final String? subtitle;
  final IconData? titleIcon;

  const OnboardingBaseLayout({
    super.key,
    required this.children,
    this.title,
    this.subtitle,
    this.titleIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppDesign.backgroundGradient,
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(KSizes.margin4x),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              OnboardingStepHeader(
                title: title!,
                subtitle: subtitle,
                icon: titleIcon,
              ),
              KSizes.spacingVerticalL,
            ],
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Standardized step header with consistent styling
class OnboardingStepHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;

  const OnboardingStepHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null)
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(KSizes.margin2x),
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.primary).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(KSizes.radiusS),
                ),
                child: Icon(
                  icon,
                  size: KSizes.iconM,
                  color: iconColor ?? AppColors.primary,
                ),
              ),
              KSizes.spacingHorizontalM,
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: KSizes.fontWeightBold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        if (icon == null)
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: KSizes.fontWeightBold,
              color: AppColors.textPrimary,
            ),
          ),
        if (subtitle != null) ...[
          KSizes.spacingVerticalS,
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}

/// Standardized section container for onboarding content
class OnboardingSection extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final bool showCard;

  const OnboardingSection({
    super.key,
    required this.child,
    this.padding,
    this.showCard = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!showCard) return child;

    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(
          color: AppColors.border.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: KSizes.blurRadiusS,
            offset: KSizes.shadowOffsetS,
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Standardized section header for individual sections within steps
class OnboardingSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? iconColor;

  const OnboardingSectionHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppColors.primary;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: KSizes.iconM,
              color: color,
            ),
            KSizes.spacingHorizontalS,
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: KSizes.fontWeightSemiBold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        KSizes.spacingVerticalXS,
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

/// Standardized input container with consistent styling
class OnboardingInputContainer extends StatelessWidget {
  final Widget child;
  final Color? color;
  final bool isActive;

  const OnboardingInputContainer({
    super.key,
    required this.child,
    this.color,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final containerColor = color ?? AppColors.primary;
    
    return Container(
      padding: EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: containerColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(
          color: isActive 
            ? containerColor
            : containerColor.withOpacity(0.2),
          width: isActive ? 2 : 1,
        ),
      ),
      child: child,
    );
  }
}

/// Standardized slider component for onboarding
class OnboardingSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;
  final Color? color;
  final String? minLabel;
  final String? maxLabel;

  const OnboardingSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
    this.color,
    this.minLabel,
    this.maxLabel,
  });

  @override
  Widget build(BuildContext context) {
    final sliderColor = color ?? AppColors.primary;
    
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: sliderColor,
            inactiveTrackColor: sliderColor.withOpacity(0.2),
            thumbColor: sliderColor,
            overlayColor: sliderColor.withOpacity(0.1),
            valueIndicatorColor: sliderColor,
            valueIndicatorTextStyle: TextStyle(
              color: Colors.white,
              fontSize: KSizes.fontSizeS,
              fontWeight: KSizes.fontWeightMedium,
            ),
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
            label: value > 0 ? value.round().toString() : null,
          ),
        ),
        if (minLabel != null || maxLabel != null)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: KSizes.margin2x),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  minLabel ?? '',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  maxLabel ?? '',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Standardized help text component
class OnboardingHelpText extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color? color;

  const OnboardingHelpText({
    super.key,
    required this.text,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final helpColor = color ?? AppColors.info;
    
    return Container(
      padding: EdgeInsets.all(KSizes.margin3x),
      decoration: BoxDecoration(
        color: helpColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(KSizes.radiusS),
        border: Border.all(
          color: helpColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon ?? MdiIcons.lightbulbOutline,
            size: KSizes.iconS,
            color: helpColor,
          ),
          KSizes.spacingHorizontalS,
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: helpColor,
                fontWeight: KSizes.fontWeightMedium,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Standardized option card for selections
class OnboardingOptionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const OnboardingOptionCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 1,
      shadowColor: color.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        side: BorderSide(
          color: isSelected ? color : AppColors.border.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        child: Container(
          constraints: BoxConstraints(minHeight: 80), // Ensure consistent height
          padding: EdgeInsets.all(KSizes.margin4x),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                padding: EdgeInsets.all(KSizes.margin2x),
                decoration: BoxDecoration(
                  color: color.withOpacity(isSelected ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(KSizes.radiusS),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: KSizes.iconM,
                ),
              ),
              KSizes.spacingHorizontalM,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: KSizes.fontWeightSemiBold,
                        color: isSelected ? color : AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    KSizes.spacingVerticalXS,
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              KSizes.spacingHorizontalS,
              if (isSelected)
                Icon(
                  MdiIcons.checkCircle,
                  color: color,
                  size: KSizes.iconM,
                ),
            ],
          ),
        ),
      ),
    );
  }
} 