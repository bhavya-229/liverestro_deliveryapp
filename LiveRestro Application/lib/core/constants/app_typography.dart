import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  static const String fontFamily = 'PlusJakartaSans';

  // === DISPLAY ===
  static TextStyle get displayLarge => GoogleFonts.plusJakartaSans(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.txtPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle get displayMedium => GoogleFonts.plusJakartaSans(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColors.txtPrimary,
    letterSpacing: -0.5,
  );

  // === HEADLINES ===
  static TextStyle get headlineLarge => GoogleFonts.plusJakartaSans(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: AppColors.txtPrimary,
  );

  static TextStyle get headlineMedium => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: AppColors.txtPrimary,
  );

  static TextStyle get headlineSmall => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.txtPrimary,
  );

  // === BODY ===
  static TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.txtSecondary,
    height: 1.5,
  );

  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.txtSecondary,
    height: 1.45,
  );

  static TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.txtMuted,
    height: 1.4,
  );

  // === LABELS ===
  static TextStyle get labelLarge => GoogleFonts.plusJakartaSans(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.txtPrimary,
  );

  static TextStyle get labelMedium => GoogleFonts.plusJakartaSans(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.txtSecondary,
  );

  static TextStyle get labelSmall => GoogleFonts.plusJakartaSans(
    fontSize: 9,
    fontWeight: FontWeight.w700,
    color: AppColors.txtMuted,
    letterSpacing: 0.5,
  );

  // === PRICE TAG ===
  static TextStyle get priceTag => GoogleFonts.plusJakartaSans(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: AppColors.accent, // emerald — was flame, makes prices pop off the plum cards
  );

  static TextStyle get priceTagSmall => GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    color: AppColors.accent,
  );

  // === CTA BUTTON ===
  static TextStyle get ctaButton => GoogleFonts.plusJakartaSans(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: AppColors.txtOnFlame,
    letterSpacing: 0.2,
  );

  static TextStyle get ctaButtonSmall => GoogleFonts.plusJakartaSans(
    fontSize: 13,
    fontWeight: FontWeight.w800,
    color: AppColors.txtOnFlame,
  );

  // === DYNAMIC HELPER METHODS (Backward Compatibility) ===
  static TextStyle heading1({required Color color}) => GoogleFonts.plusJakartaSans(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: color,
    letterSpacing: -0.5,
  );

  static TextStyle heading2({required Color color}) => GoogleFonts.plusJakartaSans(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: color,
    letterSpacing: -0.3,
  );

  static TextStyle heading3({required Color color}) => GoogleFonts.plusJakartaSans(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: color,
  );

  static TextStyle customBodyLarge({required Color color, FontWeight weight = FontWeight.w500}) => GoogleFonts.plusJakartaSans(
    fontSize: 15,
    fontWeight: weight,
    color: color,
    height: 1.4,
  );

  static TextStyle customBodyMedium({required Color color, FontWeight weight = FontWeight.w400}) => GoogleFonts.plusJakartaSans(
    fontSize: 13,
    fontWeight: weight,
    color: color,
    height: 1.35,
  );

  static TextStyle customBodySmall({required Color color, FontWeight weight = FontWeight.w400}) => GoogleFonts.plusJakartaSans(
    fontSize: 11,
    fontWeight: weight,
    color: color,
  );

  static TextStyle button({required Color color}) => GoogleFonts.plusJakartaSans(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: color,
    letterSpacing: 0.2,
  );
}
