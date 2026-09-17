import 'package:flutter/material.dart';

class AppSpacing {
  // === BASE UNIT: 4px ===
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  // === SCREEN PADDING ===
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 16.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(14.0);
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0);

  // === BORDER RADIUS ===
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusPill = 100.0;

  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(12.0));
  static const BorderRadius buttonRadius = BorderRadius.all(Radius.circular(12.0));
  static const BorderRadius pillRadius = BorderRadius.all(Radius.circular(100.0));
  static const BorderRadius inputRadius = BorderRadius.all(Radius.circular(10.0));

  // === ICON SIZES ===
  static const double iconXs = 14.0;
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double iconXl = 28.0;

  // === TOUCH TARGETS (min 48px) ===
  static const double minTouchTarget = 48.0;

  // === COMPONENT HEIGHTS ===
  static const double inputHeight = 48.0;
  static const double buttonHeight = 52.0;
  static const double buttonHeightSm = 40.0;
  static const double navBarHeight = 64.0;
  static const double heroHeight = 200.0;
  static const double menuHeroHeight = 140.0;
  static const double storyRingSize = 64.0;
  static const double storyRingSizeSm = 44.0;
  static const double restaurantCardImg = 160.0;
  static const double dishImgSize = 80.0;
  static const double avatarSizeLg = 60.0;
  static const double avatarSizeMd = 46.0;
  static const double avatarSizeSm = 36.0;
}
