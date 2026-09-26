# LiveRestro — Flutter Design System
## "Electric Flame & Mango Chili" Theme

---

## 1. COLOR PALETTE

### Primary Brand Colors
```dart
// lib/theme/app_colors.dart

class AppColors {
  // === FLAME ORANGE (Primary) ===
  static const Color flame        = Color(0xFFFF4500); // Primary CTA, active states
  static const Color flameDark    = Color(0xFFCC2D00); // Gradient start, pressed states
  static const Color flameMedium  = Color(0xFFFF6B2B); // Secondary accents
  static const Color flame50      = Color(0xFFFFF3EE); // Light tint backgrounds
  static const Color flame100     = Color(0xFFFFD9C8); // Border colors, dividers
  static const Color flame200     = Color(0xFFFFB89A); // Disabled states, soft accents

  // === MANGO ORANGE (Secondary) ===
  static const Color mango        = Color(0xFFFF9500); // Gradient end, highlights
  static const Color mangoLight   = Color(0xFFFFB84D); // Soft mango accents
  static const Color mango50      = Color(0xFFFFF8F0); // Very light mango tint

  // === BACKGROUND & SURFACES ===
  static const Color bgPage       = Color(0xFFFFF8F5); // App background (light cream)
  static const Color bgCard       = Color(0xFFFFFFFF); // Card surfaces
  static const Color bgDivider    = Color(0xFFFEEEE8); // Section dividers

  // === TEXT ===
  static const Color txtPrimary   = Color(0xFF1A1A1A); // Headlines, primary text
  static const Color txtSecondary = Color(0xFF555555); // Body text, descriptions
  static const Color txtMuted     = Color(0xFF999999); // Placeholders, meta info
  static const Color txtOnFlame   = Color(0xFFFFFFFF); // Text on flame-colored surfaces

  // === SEMANTIC ===
  static const Color success      = Color(0xFF16A34A); // Veg badge, success states
  static const Color successBg    = Color(0xFFDCFCE7); // Success background tint
  static const Color nonVeg       = Color(0xFFDC2626); // Non-veg badge
  static const Color nonVegBg     = Color(0xFFFEE2E2); // Non-veg background tint
  static const Color warning      = Color(0xFFF59E0B); // Star ratings, warnings
  static const Color posLive      = Color(0xFF4AFF91); // POS live indicator dot

  // === DARK MODE OVERRIDES ===
  static const Color darkBg       = Color(0xFF1A1008); // Dark app background
  static const Color darkCard     = Color(0xFF2A1A0E); // Dark card surface
  static const Color darkBorder   = Color(0xFF3D2010); // Dark borders
  static const Color darkTxt      = Color(0xFFFFF3EE); // Dark mode primary text
  static const Color darkTxt2     = Color(0xFFFFB89A); // Dark mode secondary text

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
}
```

---

## 2. TYPOGRAPHY

```dart
// lib/theme/app_typography.dart

// Font Family: Plus Jakarta Sans
// Import in pubspec.yaml:
// fonts:
//   - family: PlusJakartaSans
//     fonts:
//       - asset: assets/fonts/PlusJakartaSans-Regular.ttf    weight: 400
//       - asset: assets/fonts/PlusJakartaSans-Medium.ttf     weight: 500
//       - asset: assets/fonts/PlusJakartaSans-SemiBold.ttf   weight: 600
//       - asset: assets/fonts/PlusJakartaSans-Bold.ttf       weight: 700
//       - asset: assets/fonts/PlusJakartaSans-ExtraBold.ttf  weight: 800

class AppTypography {
  static const String fontFamily = 'PlusJakartaSans';

  // === DISPLAY ===
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily, fontSize: 28, fontWeight: FontWeight.w800,
    color: AppColors.txtPrimary, letterSpacing: -0.5,
  );
  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily, fontSize: 22, fontWeight: FontWeight.w800,
    color: AppColors.txtPrimary, letterSpacing: -0.5,
  );

  // === HEADLINES ===
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily, fontSize: 18, fontWeight: FontWeight.w800,
    color: AppColors.txtPrimary,
  );
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w800,
    color: AppColors.txtPrimary,
  );
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w700,
    color: AppColors.txtPrimary,
  );

  // === BODY ===
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w400,
    color: AppColors.txtSecondary, height: 1.5,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w400,
    color: AppColors.txtSecondary, height: 1.45,
  );
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily, fontSize: 11, fontWeight: FontWeight.w400,
    color: AppColors.txtMuted, height: 1.4,
  );

  // === LABELS ===
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily, fontSize: 13, fontWeight: FontWeight.w700,
    color: AppColors.txtPrimary,
  );
  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily, fontSize: 11, fontWeight: FontWeight.w700,
    color: AppColors.txtSecondary,
  );
  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily, fontSize: 9, fontWeight: FontWeight.w700,
    color: AppColors.txtMuted, letterSpacing: 0.5,
  );

  // === PRICE TAG ===
  static const TextStyle priceTag = TextStyle(
    fontFamily: fontFamily, fontSize: 15, fontWeight: FontWeight.w800,
    color: AppColors.flame,
  );
  static const TextStyle priceTagSmall = TextStyle(
    fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w800,
    color: AppColors.flame,
  );

  // === CTA BUTTON ===
  static const TextStyle ctaButton = TextStyle(
    fontFamily: fontFamily, fontSize: 15, fontWeight: FontWeight.w800,
    color: AppColors.txtOnFlame, letterSpacing: 0.2,
  );
  static const TextStyle ctaButtonSmall = TextStyle(
    fontFamily: fontFamily, fontSize: 13, fontWeight: FontWeight.w800,
    color: AppColors.txtOnFlame,
  );
}
```

---

## 3. SPACING & SIZING TOKENS

```dart
// lib/theme/app_spacing.dart

class AppSpacing {
  // === BASE UNIT: 4px ===
  static const double xs   = 4.0;
  static const double sm   = 8.0;
  static const double md   = 12.0;
  static const double lg   = 16.0;
  static const double xl   = 20.0;
  static const double xxl  = 24.0;
  static const double xxxl = 32.0;

  // === SCREEN PADDING ===
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 16.0);
  static const EdgeInsets cardPadding   = EdgeInsets.all(14.0);
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0);

  // === BORDER RADIUS ===
  static const double radiusXs   = 4.0;
  static const double radiusSm   = 8.0;
  static const double radiusMd   = 12.0;
  static const double radiusLg   = 16.0;
  static const double radiusXl   = 20.0;
  static const double radiusPill = 100.0;

  static const BorderRadius cardRadius   = BorderRadius.all(Radius.circular(12.0));
  static const BorderRadius buttonRadius = BorderRadius.all(Radius.circular(12.0));
  static const BorderRadius pillRadius   = BorderRadius.all(Radius.circular(100.0));
  static const BorderRadius inputRadius  = BorderRadius.all(Radius.circular(10.0));

  // === ICON SIZES ===
  static const double iconXs  = 14.0;
  static const double iconSm  = 16.0;
  static const double iconMd  = 20.0;
  static const double iconLg  = 24.0;
  static const double iconXl  = 28.0;

  // === TOUCH TARGETS (min 48px) ===
  static const double minTouchTarget = 48.0;

  // === COMPONENT HEIGHTS ===
  static const double inputHeight       = 48.0;
  static const double buttonHeight      = 52.0;
  static const double buttonHeightSm    = 40.0;
  static const double navBarHeight      = 64.0;
  static const double heroHeight        = 200.0;
  static const double menuHeroHeight    = 140.0;
  static const double storyRingSize     = 64.0;
  static const double storyRingSizeSm   = 44.0;
  static const double restaurantCardImg = 160.0;
  static const double dishImgSize       = 80.0;
  static const double avatarSizeLg      = 60.0;
  static const double avatarSizeMd      = 46.0;
  static const double avatarSizeSm      = 36.0;
}
```

---

## 4. ICON SYSTEM — Hugeicons Stroke

```yaml
# pubspec.yaml dependency
dependencies:
  hugeicons: ^0.0.7
```

```dart
// lib/theme/app_icons.dart
// All icons use HugeIcons stroke style (strokeRounded variant)
// Usage: HugeIcon(icon: HugeIcons.strokeRoundedHome01, color: AppColors.flame, size: 24.0)

import 'package:hugeicons/hugeicons.dart';

class AppIcons {
  // === NAVIGATION ===
  static const home        = HugeIcons.strokeRoundedHome01;
  static const search      = HugeIcons.strokeRoundedSearch01;
  static const orders      = HugeIcons.strokeRoundedShoppingBag01;
  static const profile     = HugeIcons.strokeRoundedUser;

  // === FOOD & RESTAURANT ===
  static const restaurant  = HugeIcons.strokeRoundedRestaurant01;
  static const food        = HugeIcons.strokeRoundedFoodNoodles;
  static const burger      = HugeIcons.strokeRoundedBurger;
  static const pizza       = HugeIcons.strokeRoundedPizza01;
  static const leaf        = HugeIcons.strokeRoundedLeaf01;        // Pure veg
  static const pot         = HugeIcons.strokeRoundedCookingPot;

  // === ORDERING & CART ===
  static const cart        = HugeIcons.strokeRoundedShoppingCart01;
  static const add         = HugeIcons.strokeRoundedPlusSign;
  static const remove      = HugeIcons.strokeRoundedMinusSign;
  static const delete      = HugeIcons.strokeRoundedDelete01;
  static const coupon      = HugeIcons.strokeRoundedDiscount01;
  static const tag         = HugeIcons.strokeRoundedTag01;

  // === PAYMENT ===
  static const payment     = HugeIcons.strokeRoundedCreditCard;
  static const upi         = HugeIcons.strokeRoundedMobilePayment;
  static const cash        = HugeIcons.strokeRoundedMoney01;
  static const secure      = HugeIcons.strokeRoundedShieldTick;
  static const wallet      = HugeIcons.strokeRoundedWallet01;

  // === TRACKING ===
  static const location    = HugeIcons.strokeRoundedLocation01;
  static const pin         = HugeIcons.strokeRoundedMapsPin01;
  static const delivery    = HugeIcons.strokeRoundedDeliveryBox01;
  static const motorbike   = HugeIcons.strokeRoundedMotorbike01;
  static const clock       = HugeIcons.strokeRoundedClock01;
  static const checkCircle = HugeIcons.strokeRoundedCheckmarkCircle01;
  static const route       = HugeIcons.strokeRoundedRoute01;

  // === UI CONTROLS ===
  static const back        = HugeIcons.strokeRoundedArrowLeft01;
  static const forward     = HugeIcons.strokeRoundedArrowRight01;
  static const chevronDown = HugeIcons.strokeRoundedArrowDown01;
  static const chevronRight= HugeIcons.strokeRoundedArrowRight01;
  static const close       = HugeIcons.strokeRoundedCancel01;
  static const menu        = HugeIcons.strokeRoundedMenu01;
  static const darkMode    = HugeIcons.strokeRoundedMoon01;
  static const lightMode   = HugeIcons.strokeRoundedSun01;
  static const settings    = HugeIcons.strokeRoundedSettings01;
  static const edit        = HugeIcons.strokeRoundedEdit01;
  static const share       = HugeIcons.strokeRoundedShare01;

  // === USER & PROFILE ===
  static const user        = HugeIcons.strokeRoundedUser;
  static const email       = HugeIcons.strokeRoundedMail01;
  static const phone       = HugeIcons.strokeRoundedCall;
  static const address     = HugeIcons.strokeRoundedHome01;
  static const work        = HugeIcons.strokeRoundedOffice;
  static const logout      = HugeIcons.strokeRoundedLogout01;

  // === MISC ===
  static const star        = HugeIcons.strokeRoundedStar;
  static const starFilled  = HugeIcons.strokeRoundedStar;       // Fill manually
  static const shield      = HugeIcons.strokeRoundedShieldTick;
  static const gift        = HugeIcons.strokeRoundedGift;
  static const pos         = HugeIcons.strokeRoundedComputerDesk;
  static const refresh     = HugeIcons.strokeRoundedRefresh;
  static const notification= HugeIcons.strokeRoundedNotification01;
}
```

---

## 5. THEME CONFIGURATION

```dart
// lib/theme/app_theme.dart

ThemeData get lightTheme => ThemeData(
  useMaterial3: true,
  fontFamily: AppTypography.fontFamily,
  colorScheme: ColorScheme.light(
    primary:    AppColors.flame,
    secondary:  AppColors.mango,
    surface:    AppColors.bgCard,
    background: AppColors.bgPage,
    onPrimary:  AppColors.txtOnFlame,
    onSurface:  AppColors.txtPrimary,
    error:      AppColors.nonVeg,
  ),
  scaffoldBackgroundColor: AppColors.bgPage,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    foregroundColor: AppColors.txtPrimary,
    titleTextStyle: AppTypography.headlineMedium,
  ),
  cardTheme: CardTheme(
    color: AppColors.bgCard,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: AppSpacing.cardRadius,
      side: BorderSide(color: AppColors.flame100, width: 1.0),
    ),
    margin: EdgeInsets.zero,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.flame,
      foregroundColor: AppColors.txtOnFlame,
      minimumSize: Size(double.infinity, AppSpacing.buttonHeight),
      shape: RoundedRectangleBorder(borderRadius: AppSpacing.buttonRadius),
      textStyle: AppTypography.ctaButton,
      elevation: 0,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.bgCard,
    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: AppSpacing.inputRadius,
      borderSide: BorderSide(color: AppColors.flame100, width: 1.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: AppSpacing.inputRadius,
      borderSide: BorderSide(color: AppColors.flame100, width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: AppSpacing.inputRadius,
      borderSide: BorderSide(color: AppColors.flame, width: 1.5),
    ),
    hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.txtMuted),
  ),
  dividerColor: AppColors.flame100,
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.transparent,
    selectedItemColor: AppColors.txtOnFlame,
    unselectedItemColor: AppColors.txtMuted,
    elevation: 0,
  ),
);

ThemeData get darkTheme => lightTheme.copyWith(
  scaffoldBackgroundColor: AppColors.darkBg,
  colorScheme: ColorScheme.dark(
    primary:    AppColors.flame,
    secondary:  AppColors.mango,
    surface:    AppColors.darkCard,
    background: AppColors.darkBg,
    onPrimary:  AppColors.txtOnFlame,
    onSurface:  AppColors.darkTxt,
  ),
  cardTheme: CardTheme(
    color: AppColors.darkCard,
    shape: RoundedRectangleBorder(
      borderRadius: AppSpacing.cardRadius,
      side: BorderSide(color: AppColors.darkBorder, width: 1.0),
    ),
  ),
);
```
