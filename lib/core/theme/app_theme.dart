import 'package:flutter/material.dart';
import '../constants/k_sizes.dart';

/// App color palette and theme configuration
abstract class AppColors {
  // Primary colors - Deep teal for health/wellness
  static const Color primary = Color(0xFF008080);
  static const Color primaryDark = Color(0xFF006666);
  static const Color primaryLight = Color(0xFF4DB8B8);
  
  // Secondary colors - Warm orange/amber for accents
  static const Color secondary = Color(0xFFFFB74D);
  static const Color secondaryDark = Color(0xFFFF8F00);
  static const Color secondaryLight = Color(0xFFFFE082);
  
  // Neutral colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  
  // Text colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textTertiary = Color(0xFF9E9E9E);
  
  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Borders and dividers
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);
  
  // Shadows
  static const Color shadow = Color(0x1A000000);
}

/// Standardized design elements used throughout the app
abstract class AppDesign {
  // Standard gradients
  static LinearGradient primaryGradient = LinearGradient(
    colors: [AppColors.primary, AppColors.secondary],
  );
  
  static LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white,
      AppColors.primary.withOpacity(0.02),
    ],
  );
  
  static LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.primary.withOpacity(0.05),
      AppColors.background,
      AppColors.secondary.withOpacity(0.03),
    ],
    stops: const [0.0, 0.5, 1.0],
  );
  
  // Standard shadows
  static List<BoxShadow> cardShadow = [
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
  ];
  
  static List<BoxShadow> smallShadow = [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> iconShadow = [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.3),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  // Standard container decorations
  static BoxDecoration cardDecoration = BoxDecoration(
    gradient: cardGradient,
    borderRadius: BorderRadius.circular(KSizes.radiusXL),
    boxShadow: cardShadow,
  );
  
  static BoxDecoration sectionDecoration = BoxDecoration(
    gradient: cardGradient,
    borderRadius: BorderRadius.circular(KSizes.radiusXL),
    boxShadow: cardShadow,
  );
  
  // Icon container decorations
  static BoxDecoration iconContainerDecoration(Color color) => BoxDecoration(
    gradient: LinearGradient(
      colors: [
        color,
        color.withOpacity(0.8),
      ],
    ),
    borderRadius: BorderRadius.circular(KSizes.radiusM),
    boxShadow: [
      BoxShadow(
        color: color.withOpacity(0.3),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );
  
  // Quick action card decoration
  static BoxDecoration quickActionDecoration(List<Color> gradient) => BoxDecoration(
    gradient: LinearGradient(
      colors: gradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(KSizes.radiusL),
    boxShadow: [
      BoxShadow(
        color: gradient.first.withOpacity(0.3),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );
  
  // Progress indicator decoration
  static BoxDecoration progressBarDecoration = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(KSizes.radiusS),
  );
}

/// App theme configuration
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryLight,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryLight,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
        onError: Colors.white,
      ),
      
      // Typography
      textTheme: _buildTextTheme(),
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: KSizes.fontSizeXL,
          fontWeight: KSizes.fontWeightSemiBold,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: KSizes.cardElevation,
        shadowColor: AppColors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KSizes.radiusM),
        ),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, KSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KSizes.radiusM),
          ),
          textStyle: const TextStyle(
            fontSize: KSizes.fontSizeL,
            fontWeight: KSizes.fontWeightMedium,
          ),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, KSizes.buttonHeight),
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KSizes.radiusM),
          ),
          textStyle: const TextStyle(
            fontSize: KSizes.fontSizeL,
            fontWeight: KSizes.fontWeightMedium,
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(
            fontSize: KSizes.fontSizeL,
            fontWeight: KSizes.fontWeightMedium,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KSizes.radiusM),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KSizes.radiusM),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KSizes.radiusM),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KSizes.radiusM),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: KSizes.margin4x,
          vertical: KSizes.margin3x,
        ),
        hintStyle: const TextStyle(
          color: AppColors.textTertiary,
          fontSize: KSizes.fontSizeL,
        ),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
  
  static TextTheme _buildTextTheme() {
    return const TextTheme(
      // Headlines
      headlineLarge: TextStyle(
        fontSize: KSizes.fontSizeLarge,
        fontWeight: KSizes.fontWeightBold,
        color: AppColors.textPrimary,
        height: 1.2,
      ),
      headlineMedium: TextStyle(
        fontSize: KSizes.fontSizeHeading,
        fontWeight: KSizes.fontWeightBold,
        color: AppColors.textPrimary,
        height: 1.3,
      ),
      headlineSmall: TextStyle(
        fontSize: KSizes.fontSizeTitle,
        fontWeight: KSizes.fontWeightSemiBold,
        color: AppColors.textPrimary,
        height: 1.3,
      ),
      
      // Titles
      titleLarge: TextStyle(
        fontSize: KSizes.fontSizeXXL,
        fontWeight: KSizes.fontWeightSemiBold,
        color: AppColors.textPrimary,
        height: 1.4,
      ),
      titleMedium: TextStyle(
        fontSize: KSizes.fontSizeXL,
        fontWeight: KSizes.fontWeightMedium,
        color: AppColors.textPrimary,
        height: 1.4,
      ),
      titleSmall: TextStyle(
        fontSize: KSizes.fontSizeL,
        fontWeight: KSizes.fontWeightMedium,
        color: AppColors.textPrimary,
        height: 1.4,
      ),
      
      // Body text
      bodyLarge: TextStyle(
        fontSize: KSizes.fontSizeL,
        fontWeight: KSizes.fontWeightRegular,
        color: AppColors.textPrimary,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: KSizes.fontSizeM,
        fontWeight: KSizes.fontWeightRegular,
        color: AppColors.textPrimary,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: KSizes.fontSizeS,
        fontWeight: KSizes.fontWeightRegular,
        color: AppColors.textSecondary,
        height: 1.5,
      ),
      
      // Labels
      labelLarge: TextStyle(
        fontSize: KSizes.fontSizeL,
        fontWeight: KSizes.fontWeightMedium,
        color: AppColors.textPrimary,
      ),
      labelMedium: TextStyle(
        fontSize: KSizes.fontSizeM,
        fontWeight: KSizes.fontWeightMedium,
        color: AppColors.textSecondary,
      ),
      labelSmall: TextStyle(
        fontSize: KSizes.fontSizeS,
        fontWeight: KSizes.fontWeightMedium,
        color: AppColors.textTertiary,
      ),
    );
  }
} 