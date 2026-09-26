# LiveRestro — Flutter Design System
## "Deep Plum & Mauve Mist" Theme, with an Emerald Accent

---

## 1. COLOR PALETTE

### Primary Brand Colors
```dart
// lib/theme/app_colors.dart
// Palette source: "UI Color Palette: Deep Plum Series"

class AppColors {
  // === PRIMARY PLUM (Primary) ===
  static const Color flame        = Color(0xFF714B67); // Headers, secondary brand color, badges (Primary Plum)
  static const Color flameDark    = Color(0xFF4D3346); // Gradient start, pressed states (Dark Plum)
  static const Color flameMedium  = Color(0xFFA17E9A); // Secondary accents (Medium Lavender)
  static const Color flame50      = Color(0xFFF6EEF2); // Light tint backgrounds
  static const Color flame100     = Color(0xFFD5B7CA); // Border colors, dividers (Light Pinkish-Mauve)
  static const Color flame200     = Color(0xFFBB9AB2); // Disabled states, soft accents

  // === MAUVE MIST (Secondary) ===
  static const Color mango        = Color(0xFFD5B7CA); // Gradient end, highlights (Light Pinkish-Mauve)
  static const Color mangoLight   = Color(0xFFE3CCDA); // Soft mauve accents
  static const Color mango50      = Color(0xFFFBF6F9); // Very light mauve tint

  // === EMERALD ACCENT (NEW — the "alive" color) ===
  // Deliberately teal-leaning so it never reads as the same green as `success`
  // (veg badge / POS live, #16A34A). Reserve this for things the user should
  // notice or act on: primary CTAs, price tags, the active nav pill, live/
  // in-progress badges. Do NOT use it for passive backgrounds or borders —
  // it only "pops" if it stays rare.
  static const Color accent       = Color(0xFF0E7C66); // CTAs, price tags, active states
  static const Color accentDark   = Color(0xFF0A5C4C); // Gradient partner, pressed states
  static const Color accentLight  = Color(0xFF3FA98C); // Hover / soft emerald accents
  static const Color accentBg     = Color(0xFFE3F3EF); // Light emerald tint (badges, chips)
  static const Color accentBorder = Color(0xFFBFE3D9); // Emerald focus rings / active borders

  // === BACKGROUND & SURFACES ===
  static const Color bgPage       = Color(0xFFF5F0F3); // App background (soft off-white)
  static const Color bgCard       = Color(0xFFFFFFFF); // Card surfaces
  static const Color bgDivider    = Color(0xFFEFDEE7); // Section dividers

  // === TEXT ===
  static const Color txtPrimary   = Color(0xFF241820); // Headlines, primary text (near-black plum)
  static const Color txtSecondary = Color(0xFF5C4B57); // Body text, descriptions
  static const Color txtMuted     = Color(0xFF948593); // Placeholders, meta info
  static const Color txtOnFlame   = Color(0xFFFFFFFF); // Text on flame-colored surfaces

  // === SEMANTIC (unchanged — kept legible against the new palette) ===
  static const Color success      = Color(0xFF16A34A); // Veg badge, success states
  static const Color successBg    = Color(0xFFDCFCE7); // Success background tint
  static const Color nonVeg       = Color(0xFFDC2626); // Non-veg badge
  static const Color nonVegBg     = Color(0xFFFEE2E2); // Non-veg background tint
  static const Color warning      = Color(0xFFF59E0B); // Star ratings, warnings
  static const Color posLive      = Color(0xFF4AFF91); // POS live indicator dot

  // === DARK MODE OVERRIDES ===
  static const Color darkBg       = Color(0xFF1E1420); // Dark app background
  static const Color darkCard     = Color(0xFF2B1E27); // Dark card surface
  static const Color darkBorder   = Color(0xFF4D3346); // Dark borders (Dark Plum)
  static const Color darkTxt      = Color(0xFFF5F0F3); // Dark mode primary text
  static const Color darkTxt2     = Color(0xFFD5B7CA); // Dark mode secondary text

  // === GRADIENTS ===
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4D3346), Color(0xFF714B67), Color(0xFFD5B7CA)],
    stops: [0.0, 0.5, 1.0],
  );

  // CTA buttons now use the emerald accent instead of plum, so the one
  // element the user must tap on every screen is the loudest thing in the UI.
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
    color: AppColors.accent, // emerald — was flame, makes prices pop off the plum cards
  );
  static const TextStyle priceTagSmall = TextStyle(
    fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w800,
    color: AppColors.accent,
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
    primary:    AppColors.accent, // emerald — was flame; drives default Material CTAs
    secondary:  AppColors.flame,  // plum now sits as the secondary/structural brand color
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
      backgroundColor: AppColors.accent, // emerald — matches GradientButton
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
      borderSide: BorderSide(color: AppColors.accent, width: 1.5),
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
    primary:    AppColors.accent, // emerald — was flame
    secondary:  AppColors.flame,
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
