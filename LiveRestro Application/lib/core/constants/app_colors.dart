import 'package:flutter/material.dart';

class AppColors {
  // === FLAME ORANGE (Primary) ===
  static const Color flame = Color(0xFFFF4500); // Primary CTA, active states
  static const Color flameDark = Color(0xFFCC2D00); // Gradient start, pressed states
  static const Color flameMedium = Color(0xFFFF6B2B); // Secondary accents
  static const Color flame50 = Color(0xFFFFF3EE); // Light tint backgrounds
  static const Color flame100 = Color(0xFFFFD9C8); // Border colors, dividers
  static const Color flame200 = Color(0xFFFFB89A); // Disabled states, soft accents

  // === MANGO ORANGE (Secondary) ===
  static const Color mango = Color(0xFFFF9500); // Gradient end, highlights
  static const Color mangoLight = Color(0xFFFFB84D); // Soft mango accents
  static const Color mango50 = Color(0xFFFFF8F0); // Very light mango tint

  // === BACKGROUND & SURFACES ===
  static const Color bgPage = Color(0xFFFFF8F5); // App background (light cream)
  static const Color bgCard = Color(0xFFFFFFFF); // Card surfaces
  static const Color bgDivider = Color(0xFFFEEEE8); // Section dividers

  // === TEXT ===
  static const Color txtPrimary = Color(0xFF1A1A1A); // Headlines, primary text
  static const Color txtSecondary = Color(0xFF555555); // Body text, descriptions
  static const Color txtMuted = Color(0xFF999999); // Placeholders, meta info
  static const Color txtOnFlame = Color(0xFFFFFFFF); // Text on flame-colored surfaces

  // === SEMANTIC ===
  static const Color success = Color(0xFF16A34A); // Veg badge, success states
  static const Color successBg = Color(0xFFDCFCE7); // Success background tint
  static const Color nonVeg = Color(0xFFDC2626); // Non-veg badge
  static const Color nonVegBg = Color(0xFFFEE2E2); // Non-veg background tint
  static const Color warning = Color(0xFFF59E0B); // Star ratings, warnings
  static const Color posLive = Color(0xFF4AFF91); // POS live indicator dot
  static const Color error = Color(0xFFDC2626);

  // === DARK MODE OVERRIDES ===
  static const Color darkBg = Color(0xFF1A1008); // Dark app background
  static const Color darkCard = Color(0xFF2A1A0E); // Dark card surface
  static const Color darkBorder = Color(0xFF3D2010); // Dark borders
  static const Color darkTxt = Color(0xFFFFF3EE); // Dark mode primary text
  static const Color darkTxt2 = Color(0xFFFFB89A); // Dark mode secondary text

  // === GRADIENTS ===
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFCC2D00), Color(0xFFFF4500), Color(0xFFFF9500)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient ctaGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFCC2D00), Color(0xFFFF4500)],
  );

  static const LinearGradient storyRingGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF4500), Color(0xFFFF9500)],
  );

  static const LinearGradient cardImgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0x80000000)],
  );

  // Compatibility aliases
  static const Color primary = flame;
  static const Color primaryDark = flameDark;
  static const Color primaryLight = flameMedium;
  static const Color primarySoft = flame50;
  static const Color primaryMuted = flame100;
  static const Color accent = mango;
  static const Color ratingGold = warning;
  static const Color vegGreen = success;
  static const Color vegGreenLight = successBg;
  static const Color backgroundLight = bgPage;
  static const Color surfaceLight = bgCard;
  static const Color cardLight = bgCard;
  static const Color textPrimaryLight = txtPrimary;
  static const Color textSecondaryLight = txtSecondary;
  static const Color textMutedLight = txtMuted;
  static const Color borderLight = flame100;
  static const Color dividerLight = bgDivider;
  static const Color surfaceDark = darkCard;
  static const Color backgroundDark = darkBg;
  static const Color cardDark = darkCard;
  static const Color textPrimaryDark = darkTxt;
  static const Color textSecondaryDark = darkTxt2;
  static const Color textMutedDark = txtMuted;
  static const Color borderDark = darkBorder;
  static const Color dividerDark = darkBorder;
}
