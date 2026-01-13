import 'package:flutter/material.dart';

/// App color palette - dark theme optimized for modern, minimal look
abstract class AppColors {
  // Primary brand colors - brighter for dark bg visibility
  static const Color primary = Color(0xFF818CF8); // Brighter Indigo
  static const Color primaryLight = Color(0xFFA5B4FC); // Even brighter
  static const Color primaryDark = Color(0xFF6366F1);

  // Surface colors
  static const Color background = Color(0xFF0F0F0F);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color surfaceLight = Color(0xFF262626);
  static const Color surfaceBorder = Color(0xFF333333);

  // Status colors - these stay the same in both themes
  static const Color safe = Color(0xFF10B981); // Emerald green
  static const Color safeLight = Color(0xFF34D399);
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color danger = Color(0xFFEF4444); // Red
  static const Color dangerLight = Color(0xFFF87171);

  // Text colors
  static const Color textPrimary = Color(0xFFFAFAFA);
  static const Color textSecondary = Color(0xFFB8B8B8); // Brighter
  static const Color textMuted = Color(0xFF8F8F8F); // Brighter

  // Chart colors for sensor data - brighter for visibility
  static const Color chartX = Color(0xFFF87171); // Brighter Red for X axis
  static const Color chartY = Color(0xFF4ADE80); // Brighter Green for Y axis
  static const Color chartZ = Color(0xFF60A5FA); // Brighter Blue for Z axis
  static const Color chartMagnitude = Color(0xFFFBBF24); // Brighter Amber
}

/// Extension to get theme-aware colors
extension ThemeColors on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get surfaceColor => colors.surface;
  Color get backgroundColor => Theme.of(this).scaffoldBackgroundColor;
  Color get borderColor => Theme.of(this).dividerColor;
  Color get textPrimary => colors.onSurface;
  Color get textSecondary =>
      isDark ? AppColors.textSecondary : const Color(0xFF666666);
  Color get textMuted => isDark ? AppColors.textMuted : const Color(0xFF999999);

  // Status colors are the same for both themes (semantic colors)
  Color get safeColor => AppColors.safe;
  Color get dangerColor => AppColors.danger;
  Color get warningColor => AppColors.warning;
  Color get primaryColor => colors.primary;
}
