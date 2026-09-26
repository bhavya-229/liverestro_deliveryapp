import 'package:flutter/material.dart';

class AppColors {
  // === PRIMARY PLUM (Primary) ===
  static const Color flame = Color(0xFF714B67); // Primary CTA, active states (Primary Plum)
  static const Color flameDark = Color(0xFF4D3346); // Gradient start, pressed states (Dark Plum)
  static const Color flameMedium = Color(0xFFA17E9A); // Secondary accents (Medium Lavender)
  static const Color flame50 = Color(0xFFF6EEF2); // Light tint backgrounds
  static const Color flame100 = Color(0xFFD5B7CA); // Border colors, dividers (Light Pinkish-Mauve)
  static const Color flame200 = Color(0xFFBB9AB2); // Disabled states, soft accents

  // === MAUVE MIST (Secondary) ===
  static const Color mango = Color(0xFFD5B7CA); // Gradient end, highlights (Light Pinkish-Mauve)
  static const Color mangoLight = Color(0xFFE3CCDA); // Soft mauve accents
  static const Color mango50 = Color(0xFFFBF6F9); // Very light mauve tint

  // === EMERALD ACCENT (NEW — the "alive" color) ===
  static const Color accent = Color(0xFF0E7C66); // CTAs, price tags, active states
  static const Color accentDark = Color(0xFF0A5C4C); // Gradient partner, pressed states
  static const Color accentLight = Color(0xFF3FA98C); // Hover / soft emerald accents
  static const Color accentBg = Color(0xFFE3F3EF); // Light emerald tint (badges, chips)
  static const Color accentBorder = Color(0xFFBFE3D9); // Emerald focus rings / active borders

  // === BACKGROUND & SURFACES ===
  static const Color bgPage = Color(0xFFF5F0F3); // App background (soft off-white)
  static const Color bgCard = Color(0xFFFFFFFF); // Card surfaces
  static const Color bgDivider = Color(0xFFEFDEE7); // Section dividers

  // === TEXT ===
  static const Color txtPrimary = Color(0xFF241820); // Headlines, primary text (near-black plum)
  static const Color txtSecondary = Color(0xFF5C4B57); // Body text, descriptions
  static const Color txtMuted = Color(0xFF948593); // Placeholders, meta info
  static const Color txtOnFlame = Color(0xFFFFFFFF); // Text on flame-colored surfaces

  // === SEMANTIC (kept clear & recognizable) ===
  static const Color success = Color(0xFF16A34A); // Veg badge, success states
  static const Color successBg = Color(0xFFDCFCE7); // Success background tint
  static const Color nonVeg = Color(0xFFDC2626); // Non-veg badge
  static const Color nonVegBg = Color(0xFFFEE2E2); // Non-veg background tint
  static const Color warning = Color(0xFFF59E0B); // Star ratings, warnings
  static const Color posLive = Color(0xFF4AFF91); // POS live indicator dot
  static const Color error = Color(0xFFDC2626);

  // === DARK MODE OVERRIDES ===
  static const Color darkBg = Color(0xFF1E1420); // Dark app background
  static const Color darkCard = Color(0xFF2B1E27); // Dark card surface
  static const Color darkBorder = Color(0xFF4D3346); // Dark borders (Dark Plum)
  static const Color darkTxt = Color(0xFFF5F0F3); // Dark mode primary text
  static const Color darkTxt2 = Color(0xFFD5B7CA); // Dark mode secondary text

  // === GRADIENTS ===
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4D3346), Color(0xFF714B67), Color(0xFFD5B7CA)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient ctaGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF0A5C4C), Color(0xFF0E7C66)],
  );

  static const LinearGradient storyRingGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF714B67), Color(0xFFD5B7CA)],
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
