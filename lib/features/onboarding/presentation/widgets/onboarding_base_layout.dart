import 'package:flutter/material.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';

/// Standardized base layout for all onboarding screens
/// Ensures consistent design patterns and spacing
class OnboardingBaseLayout extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets? padding;
  final bool useScrollView;

  const OnboardingBaseLayout({
    super.key,
    required this.children,
    this.padding,
    this.useScrollView = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KSizes.spacingVerticalM,
        ...children,
        KSizes.spacingVerticalXL,
      ],
    );

    return Container(
      decoration: BoxDecoration(
        gradient: AppDesign.backgroundGradient,
      ),
      child: useScrollView
          ? SingleChildScrollView(
              padding: padding ?? const EdgeInsets.all(KSizes.margin4x),
              child: content,
            )
          : Padding(
              padding: padding ?? const EdgeInsets.all(KSizes.margin4x),
              child: content,
            ),
    );
  }
}

/// Standardized section container for onboarding screens
class OnboardingSection extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const OnboardingSection({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDesign.sectionDecoration,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(KSizes.margin4x),
        child: child,
      ),
    );
  }
}

/// Standardized section header for onboarding screens
class OnboardingSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;

  const OnboardingSectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: KSizes.iconM,
              color: iconColor ?? AppColors.primary,
            ),
            KSizes.spacingHorizontalS,
            Flexible(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          KSizes.spacingVerticalS,
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

/// Standardized input field container for onboarding screens
class OnboardingInputContainer extends StatelessWidget {
  final Widget child;
  final Color color;
  final EdgeInsets? padding;

  const OnboardingInputContainer({
    super.key,
    required this.child,
    this.color = AppColors.primary,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: child,
    );
  }
}

/// Standardized metric display for onboarding screens
class OnboardingMetricDisplay extends StatelessWidget {
  final String value;
  final String unit;
  final Color color;
  final VoidCallback? onTap;

  const OnboardingMetricDisplay({
    super.key,
    required this.value,
    required this.unit,
    this.color = AppColors.primary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: OnboardingInputContainer(
        color: color,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: KSizes.fontWeightBold,
              ),
            ),
            Text(
              ' $unit',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Standardized slider theme for onboarding screens
class OnboardingSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;
  final Color color;
  final String? minLabel;
  final String? maxLabel;

  const OnboardingSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
    this.color = AppColors.primary,
    this.minLabel,
    this.maxLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: color.withOpacity(0.3),
            thumbColor: color,
            overlayColor: color.withOpacity(0.2),
            trackHeight: 6,
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
        if (minLabel != null && maxLabel != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: KSizes.margin2x),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  minLabel!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                Text(
                  maxLabel!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
} 