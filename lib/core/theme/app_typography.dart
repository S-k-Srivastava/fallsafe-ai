import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography styles using Inter font family
abstract class AppTypography {
  static TextStyle get _baseStyle => GoogleFonts.inter();

  // Headings
  static TextStyle get displayLarge => _baseStyle.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  static TextStyle get displayMedium => _baseStyle.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
  );

  static TextStyle get headlineMedium =>
      _baseStyle.copyWith(fontSize: 20, fontWeight: FontWeight.w600);

  static TextStyle get titleLarge =>
      _baseStyle.copyWith(fontSize: 18, fontWeight: FontWeight.w600);

  static TextStyle get titleMedium =>
      _baseStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w500);

  // Body text
  static TextStyle get bodyLarge =>
      _baseStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w400);

  static TextStyle get bodyMedium =>
      _baseStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w400);

  static TextStyle get bodySmall =>
      _baseStyle.copyWith(fontSize: 12, fontWeight: FontWeight.w400);

  // Labels
  static TextStyle get labelLarge => _baseStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  static TextStyle get labelMedium => _baseStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  static TextStyle get labelSmall => _baseStyle.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  // Special styles
  static TextStyle get mono =>
      GoogleFonts.jetBrainsMono(fontSize: 14, fontWeight: FontWeight.w400);

  static TextStyle get valueLarge => _baseStyle.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );
}
