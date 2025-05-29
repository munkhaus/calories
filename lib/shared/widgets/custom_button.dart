import 'package:flutter/material.dart';
import '../../core/constants/k_sizes.dart';
import '../../core/theme/app_theme.dart';

/// Button variant enum for different button styles
enum ButtonVariant {
  primary,
  outline,
  secondary,
}

/// Custom button widget with consistent styling
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final bool isExpanded;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.isExpanded = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (isExpanded) {
      return SizedBox(
        width: double.infinity,
        height: KSizes.buttonHeight,
        child: _buildButton(context),
      );
    }
    return SizedBox(
      height: KSizes.buttonHeight,
      child: _buildButton(context),
    );
  }

  Widget _buildButton(BuildContext context) {
    switch (variant) {
      case ButtonVariant.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(KSizes.radiusL),
            ),
          ),
          child: _buildButtonChild(),
        );
      case ButtonVariant.outline:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(color: AppColors.primary, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(KSizes.radiusL),
            ),
          ),
          child: _buildButtonChild(),
        );
      case ButtonVariant.secondary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(KSizes.radiusL),
            ),
          ),
          child: _buildButtonChild(),
        );
    }
  }

  Widget _buildButtonChild() {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            variant == ButtonVariant.primary ? Colors.white : AppColors.primary,
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: KSizes.iconM),
          SizedBox(width: KSizes.margin2x),
          Text(
            text,
            style: TextStyle(
              fontSize: KSizes.fontSizeM,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: KSizes.fontSizeM,
        fontWeight: FontWeight.w600,
      ),
    );
  }
} 