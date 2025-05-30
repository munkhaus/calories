import 'package:flutter/material.dart';
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

/// Simplified step header - removed icon clutter
class OnboardingStepHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const OnboardingStepHeader({
    super.key,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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

/// Simplified section container - removed unnecessary card styling
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
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(
          color: AppColors.border.withOpacity(0.1),
        ),
      ),
      child: child,
    );
  }
}

/// Simplified section header - removed redundant icons
class OnboardingSectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const OnboardingSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: KSizes.fontWeightSemiBold,
            color: AppColors.textPrimary,
          ),
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

/// Simplified input container - only primary color, reduced styling
class OnboardingInputContainer extends StatelessWidget {
  final Widget child;
  final bool isActive;

  const OnboardingInputContainer({
    super.key,
    required this.child,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(
          color: isActive 
            ? AppColors.primary
            : AppColors.primary.withOpacity(0.2),
          width: isActive ? 2 : 1,
        ),
      ),
      child: child,
    );
  }
}

/// Simplified slider - only primary color with value indicators
class OnboardingSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;
  final String? minLabel;
  final String? maxLabel;
  final String? unit; // Add unit parameter for better formatting

  const OnboardingSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
    this.minLabel,
    this.maxLabel,
    this.unit,
  });

  String _formatValue(double value) {
    if (unit != null) {
      if (unit == 'kg' || unit == 'cm') {
        return '${value.round()} $unit';
      } else if (unit == 'kg/uge') {
        return '${value.toStringAsFixed(1)} $unit';
      }
    }
    
    // Default formatting
    if (value % 1 == 0) {
      return value.round().toString();
    } else {
      return value.toStringAsFixed(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.primary.withOpacity(0.2),
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withOpacity(0.1),
            valueIndicatorColor: AppColors.primary,
            valueIndicatorTextStyle: TextStyle(
              color: Colors.white,
              fontSize: KSizes.fontSizeS,
              fontWeight: KSizes.fontWeightMedium,
            ),
            showValueIndicator: ShowValueIndicator.always,
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
            label: _formatValue(value),
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

/// Simplified help text - with color categorization based on function
class OnboardingHelpText extends StatelessWidget {
  final String text;
  final OnboardingHelpType type;

  const OnboardingHelpText({
    super.key,
    required this.text,
    this.type = OnboardingHelpType.neutral,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    
    switch (type) {
      case OnboardingHelpType.neutral:
        // Blue - professional and trustworthy (factual explanations)
        backgroundColor = const Color(0xFF2196F3).withOpacity(0.1);
        textColor = const Color(0xFF1565C0);
        break;
      case OnboardingHelpType.positive:
        // Green - health and natural (positive health messages)
        backgroundColor = const Color(0xFF4CAF50).withOpacity(0.1);
        textColor = const Color(0xFF2E7D32);
        break;
      case OnboardingHelpType.motivational:
        // Orange - energetic and motivating (goals and recommendations)
        backgroundColor = const Color(0xFFFF9800).withOpacity(0.1);
        textColor = const Color(0xFFE65100);
        break;
      case OnboardingHelpType.warning:
        // Red-Orange - important warnings, disclaimers, medical notices
        backgroundColor = const Color(0xFFFF5722).withOpacity(0.15);
        textColor = const Color(0xFFD84315);
        break;
    }

    return Container(
      width: double.infinity, // Full width for symmetry
      padding: EdgeInsets.all(KSizes.margin3x),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(KSizes.radiusS),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: textColor,
          height: 1.3,
          fontWeight: KSizes.fontWeightMedium,
        ),
      ),
    );
  }
}

/// Types of help text based on function
enum OnboardingHelpType {
  neutral,      // Blue - factual explanations, technical info
  positive,     // Green - health benefits, positive outcomes
  motivational, // Orange - goals, motivation, recommendations
  warning,      // Red/Orange - disclaimers, important warnings, medical notices
}

/// Simplified option card - cleaner design, less visual noise
class OnboardingOptionCard extends StatelessWidget {
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const OnboardingOptionCard({
    super.key,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: KSizes.margin2x),
      child: Material(
        color: isSelected 
          ? AppColors.primary.withOpacity(0.1)
          : AppColors.surface,
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(KSizes.radiusM),
          child: Container(
            padding: EdgeInsets.all(KSizes.margin4x),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(KSizes.radiusM),
              border: Border.all(
                color: isSelected 
                  ? AppColors.primary
                  : AppColors.border.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: KSizes.fontWeightSemiBold,
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                      KSizes.spacingVerticalXS,
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected) ...[
                  KSizes.spacingHorizontalM,
                  Container(
                    padding: EdgeInsets.all(KSizes.margin1x),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: KSizes.iconS,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
} 