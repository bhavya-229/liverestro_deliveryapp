import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    textTheme: GoogleFonts.plusJakartaSansTextTheme(),
    colorScheme: const ColorScheme.light(
      primary: AppColors.accent, // emerald — drives default Material CTAs
      secondary: AppColors.flame, // plum now sits as the secondary/structural brand color
      surface: AppColors.bgCard,
      onPrimary: AppColors.txtOnFlame,
      onSurface: AppColors.txtPrimary,
      error: AppColors.nonVeg,
    ),
    scaffoldBackgroundColor: AppColors.bgPage,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: AppColors.txtPrimary,
      titleTextStyle: AppTypography.headlineMedium,
    ),
    cardTheme: CardThemeData(
      color: AppColors.bgCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.cardRadius,
        side: const BorderSide(color: AppColors.flame100, width: 1.0),
      ),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent, // emerald — matches GradientButton
        foregroundColor: AppColors.txtOnFlame,
        minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.buttonRadius),
        textStyle: AppTypography.ctaButton,
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bgCard,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: AppSpacing.inputRadius,
        borderSide: const BorderSide(color: AppColors.flame100, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppSpacing.inputRadius,
        borderSide: const BorderSide(color: AppColors.flame100, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppSpacing.inputRadius,
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.txtMuted),
    ),
    dividerColor: AppColors.flame100,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      selectedItemColor: AppColors.txtOnFlame,
      unselectedItemColor: AppColors.txtMuted,
      elevation: 0,
    ),
  );

  static ThemeData get darkTheme {
    final light = lightTheme;
    return light.copyWith(
      scaffoldBackgroundColor: AppColors.darkBg,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent, // emerald
        secondary: AppColors.flame,
        surface: AppColors.darkCard,
        onPrimary: AppColors.txtOnFlame,
        onSurface: AppColors.darkTxt,
        error: AppColors.nonVeg,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.darkTxt,
        titleTextStyle: AppTypography.headlineMedium.copyWith(color: AppColors.darkTxt),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.cardRadius,
          side: const BorderSide(color: AppColors.darkBorder, width: 1.0),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: AppSpacing.inputRadius,
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.inputRadius,
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.inputRadius,
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.txtMuted),
      ),
    );
  }
}
