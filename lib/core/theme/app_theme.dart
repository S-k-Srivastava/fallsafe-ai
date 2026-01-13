import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

/// Light mode colors

/// Main app theme using Material 3
class AppTheme {
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppPalette.backgroundDark,
    colorScheme: const ColorScheme.dark(
      primary: AppPalette.primary,
      onPrimary: AppPalette.textPrimaryDark,
      secondary: AppPalette.primaryLight,
      surface: AppPalette.surfaceDark,
      onSurface: AppPalette.textPrimaryDark,
      surfaceContainerHighest: AppPalette.surfaceLightDark,
      error: AppPalette.danger,
      outline: AppPalette.surfaceBorderDark,
    ),
    dividerColor: AppPalette.surfaceBorderDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPalette.backgroundDark,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppPalette.textPrimaryDark,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppPalette.surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: const BorderSide(color: AppPalette.surfaceBorderDark, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppPalette.primary,
        foregroundColor: AppPalette.textPrimaryDark,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppPalette.surfaceBorderDark,
      thickness: 1,
    ),
  );

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppPalette.backgroundLight,
    colorScheme: const ColorScheme.light(
      primary: AppPalette.primary,
      onPrimary: Colors.white,
      secondary: AppPalette.primaryLight,
      surface: AppPalette.surfaceLight,
      onSurface: AppPalette.textPrimaryLight,
      surfaceContainerHighest: AppPalette.surfaceLightVariant,
      error: AppPalette.danger,
      outline: AppPalette.surfaceBorderLight,
    ),
    dividerColor: AppPalette.surfaceBorderLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPalette.backgroundLight,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppPalette.textPrimaryLight,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: AppPalette.textSecondaryLight),
    ),
    cardTheme: CardThemeData(
      color: AppPalette.surfaceLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: const BorderSide(color: AppPalette.surfaceBorderLight, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppPalette.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppPalette.surfaceBorderLight,
      thickness: 1,
    ),
  );
}
