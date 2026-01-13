import 'package:flutter/material.dart';

/// App color palette - dark theme optimized for modern, minimal look
abstract class AppColors {
  // Primary brand colors
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);

  // Surface colors
  static const Color background = Color(0xFF0F0F0F);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color surfaceLight = Color(0xFF262626);
  static const Color surfaceBorder = Color(0xFF333333);

  // Status colors
  static const Color safe = Color(0xFF10B981); // Emerald green
  static const Color safeLight = Color(0xFF34D399);
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color danger = Color(0xFFEF4444); // Red
  static const Color dangerLight = Color(0xFFF87171);

  // Text colors
  static const Color textPrimary = Color(0xFFFAFAFA);
  static const Color textSecondary = Color(0xFFA3A3A3);
  static const Color textMuted = Color(0xFF737373);

  // Chart colors for sensor data
  static const Color chartX = Color(0xFFEF4444); // Red for X axis
  static const Color chartY = Color(0xFF22C55E); // Green for Y axis
  static const Color chartZ = Color(0xFF3B82F6); // Blue for Z axis
  static const Color chartMagnitude = Color(0xFFF59E0B); // Amber for magnitude
}
