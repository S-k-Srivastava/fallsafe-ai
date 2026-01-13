import 'package:flutter/material.dart';

/// App raw color palette - defining the design tokens
abstract class AppPalette {
  // Primary brand colors
  static const Color primary = Color(0xFF818CF8); // Indigo 400
  static const Color primaryLight = Color(0xFFA5B4FC); // Indigo 300
  static const Color primaryDark = Color(0xFF6366F1); // Indigo 500

  // Neutral Colors (Dark Theme)
  static const Color backgroundDark = Color(0xFF0F0F0F);
  static const Color surfaceDark = Color(0xFF1A1A1A);
  static const Color surfaceLightDark = Color(0xFF262626);
  static const Color surfaceBorderDark = Color(0xFF333333);

  // Neutral Colors (Light Theme)
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceLightVariant = Color(0xFFF0F0F0);
  static const Color surfaceBorderLight = Color(0xFFE0E0E0);

  // Text Colors (Dark)
  static const Color textPrimaryDark = Color(0xFFFAFAFA);
  static const Color textSecondaryDark = Color(0xFFB8B8B8);
  static const Color textMutedDark = Color(0xFF8F8F8F);

  // Text Colors (Light)
  static const Color textPrimaryLight = Color(0xFF1A1A1A);
  static const Color textSecondaryLight = Color(0xFF666666);
  static const Color textMutedLight = Color(0xFF999999);

  // Status colors (Semantic - shared)
  static const Color safe = Color(0xFF10B981); // Emerald
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color danger = Color(0xFFEF4444); // Red

  // Chart colors (distinct for visibility)
  static const Color chartX = Color(0xFFF87171);
  static const Color chartY = Color(0xFF4ADE80);
  static const Color chartZ = Color(0xFF60A5FA);
  static const Color chartMagnitude = Color(0xFFFBBF24);
}
