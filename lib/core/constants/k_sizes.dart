import 'package:flutter/material.dart';

/// Constants for all UI measurements in the app
/// Follow consistent scaling system and semantic naming
abstract class KSizes {
  // Base measurements
  static const double baseUnit = 4.0;
  
  // Margins and Padding (base unit multiplication)
  static const double margin1x = baseUnit;
  static const double margin2x = baseUnit * 2;
  static const double margin3x = baseUnit * 3;
  static const double margin4x = baseUnit * 4;
  static const double margin6x = baseUnit * 6;
  static const double margin8x = baseUnit * 8;
  static const double margin12x = baseUnit * 12;
  static const double margin16x = baseUnit * 16;
  static const double margin20x = baseUnit * 20;
  
  // Font Sizes (semantic naming)
  static const double fontSizeXS = 10.0;
  static const double fontSizeS = 12.0;
  static const double fontSizeM = 14.0;
  static const double fontSizeL = 16.0;
  static const double fontSizeXL = 18.0;
  static const double fontSizeXXL = 20.0;
  static const double fontSizeTitle = 24.0;
  static const double fontSizeHeading = 28.0;
  static const double fontSizeLarge = 32.0;
  
  // Font Weights
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;
  
  // Border Radius
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusRound = 50.0;
  
  // Icon Sizes
  static const double iconXS = 16.0;
  static const double iconS = 20.0;
  static const double iconM = 24.0;
  static const double iconL = 28.0;
  static const double iconXL = 32.0;
  static const double iconXXL = 48.0;
  
  // Component Sizes
  static const double buttonHeight = 48.0;
  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightLarge = 56.0;
  static const double textFieldHeight = 48.0;
  static const double appBarHeight = 56.0;
  static const double cardElevation = 2.0;
  
  // Progress Indicators
  static const double progressCircleSize = 120.0;
  static const double progressCircleStroke = 8.0;
  static const double progressBarHeight = 8.0;
  
  // Spacing helpers
  static const Widget spacingXS = SizedBox(height: margin1x, width: margin1x);
  static const Widget spacingS = SizedBox(height: margin2x, width: margin2x);
  static const Widget spacingM = SizedBox(height: margin4x, width: margin4x);
  static const Widget spacingL = SizedBox(height: margin8x, width: margin8x);
  static const Widget spacingXL = SizedBox(height: margin12x, width: margin12x);
  
  // Horizontal spacing
  static const Widget spacingHorizontalXS = SizedBox(width: margin1x);
  static const Widget spacingHorizontalS = SizedBox(width: margin2x);
  static const Widget spacingHorizontalM = SizedBox(width: margin4x);
  static const Widget spacingHorizontalL = SizedBox(width: margin8x);
  
  // Vertical spacing
  static const Widget spacingVerticalXS = SizedBox(height: margin1x);
  static const Widget spacingVerticalS = SizedBox(height: margin2x);
  static const Widget spacingVerticalM = SizedBox(height: margin4x);
  static const Widget spacingVerticalL = SizedBox(height: margin8x);
  static const Widget spacingVerticalXL = SizedBox(height: margin12x);
  
  // Standard card heights for consistency
  static const double cardHeightS = 100.0;
  static const double cardHeightM = 120.0;
  static const double cardHeightL = 140.0;
  static const double cardHeightXL = 180.0;
  
  // Standard card widths for grid layouts
  static const double cardWidthS = 100.0;
  static const double cardWidthM = 120.0;
  static const double cardWidthL = 140.0;
  
  // Standard container heights for main sections
  static const double sectionHeightS = 140.0;
  static const double sectionHeightM = 180.0;
  static const double sectionHeightL = 220.0;
  static const double sectionHeightXL = 260.0;
  
  // Circular progress indicator dimensions
  static const double circularProgressSize = 120.0;
  static const double circularProgressBackground = 140.0;
  static const double circularProgressStroke = 12.0;
  
  // Standard opacity values
  static const double opacityLight = 0.1;
  static const double opacityMedium = 0.3;
  static const double opacityHeavy = 0.8;
  
  // Standard blur radius values
  static const double blurRadiusS = 6.0;
  static const double blurRadiusM = 8.0;
  static const double blurRadiusL = 12.0;
  static const double blurRadiusXL = 20.0;
  
  // Standard offset values for shadows
  static const Offset shadowOffsetS = Offset(0, 2);
  static const Offset shadowOffsetM = Offset(0, 4);
  static const Offset shadowOffsetL = Offset(0, 8);
  static const Offset shadowOffsetReverse = Offset(0, -2);
  
  // Standard border widths
  static const double borderWidthThin = 1.0;
  static const double borderWidthMedium = 2.0;
  static const double borderWidthThick = 4.0;
} 