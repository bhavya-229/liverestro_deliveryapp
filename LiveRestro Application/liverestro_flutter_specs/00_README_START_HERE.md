# LiveRestro Flutter App — Developer Handoff Package
## START HERE

---

## WHAT'S IN THIS PACKAGE

| File | Contents |
|------|----------|
| `00_README_START_HERE.md` | This file — overview and quick reference |
| `01_design_system.md` | Colors, typography, spacing, icons, theme config |
| `02_screen_specifications.md` | All 10 screens — widget tree, layout, components |
| `03_components.md` | 15 reusable widget specs with Dart pseudocode |
| `04_animations_data_navigation.md` | Animations, data models, routing, packages, folder structure |

---

## APP OVERVIEW

**App Name:** LiveRestro  
**Platform:** Flutter (iOS + Android)  
**Theme:** Electric Flame & Mango Chili  
**Font:** Plus Jakarta Sans  
**Icon Library:** Hugeicons (stroke rounded variant only)  
**State Management:** Riverpod (recommended)  
**Navigation:** go_router  

---

## COLOR QUICK REFERENCE

```
PRIMARY FLAME    #FF4500   → CTAs, active states, prices, badges
FLAME DARK       #CC2D00   → Gradient start, pressed states
MANGO            #FF9500   → Gradient end, highlights, star ratings
FLAME TINT       #FFF3EE   → Card backgrounds, input fills
FLAME BORDER     #FFD9C8   → Card borders, dividers, input borders
PAGE BG          #FFF8F5   → App background (light cream)
CARD BG          #FFFFFF   → All card surfaces
TEXT PRIMARY     #1A1A1A   → Headlines, dish names
TEXT SECONDARY   #555555   → Descriptions, meta
TEXT MUTED       #999999   → Placeholders, timestamps
SUCCESS GREEN    #16A34A   → Veg badge, POS live, success states
NON VEG RED      #DC2626   → Non-veg badge, error states
STAR GOLD        #F59E0B   → Ratings
POS LIVE DOT     #4AFF91   → Live tracking pulse dot
WHITE ON FLAME   #FFFFFF   → All text on flame-colored surfaces
```

---

## GRADIENT RECIPES

```dart
// HERO GRADIENT (headers, splash, tracking)
LinearGradient(
  begin: Alignment.topLeft, end: Alignment.bottomRight,
  colors: [Color(0xFFCC2D00), Color(0xFFFF4500), Color(0xFFFF9500)],
  stops: [0.0, 0.5, 1.0],
)

// CTA BUTTON GRADIENT
LinearGradient(
  begin: Alignment.centerLeft, end: Alignment.centerRight,
  colors: [Color(0xFFCC2D00), Color(0xFFFF4500)],
)

// STORY RING GRADIENT
LinearGradient(
  begin: Alignment.topLeft, end: Alignment.bottomRight,
  colors: [Color(0xFFFF4500), Color(0xFFFF9500)],
)
```

---

## SCREENS CHECKLIST

```
[ ] Screen 1  — Splash
[ ] Screen 2  — Login & OTP
[ ] Screen 3  — Profile Setup
[ ] Screen 4  — Location Picker
[ ] Screen 5  — Home Discovery (most complex)
[ ] Screen 6  — Restaurant Menu
[ ] Screen 7  — Item Customization Bottom Sheet
[ ] Screen 8  — Cart & Bill
[ ] Screen 9  — Payment Selection
[ ] Screen 10 — Live Order Tracking (ETA ring, no map)
[ ] Screen 11 — My Profile & Order History
```

---

## COMPONENTS CHECKLIST

```
[ ] FloatingNavBar       — glassmorphism pill, 4 tabs
[ ] StoryBubble          — gradient ring, seen/unseen state
[ ] StoryViewer          — full screen with progress bars
[ ] RestaurantCard       — image, badges, meta, hover animation
[ ] SkeletonCard         — shimmer loading placeholder
[ ] GradientButton       — primary CTA, press animation
[ ] FloatingCartBar      — slide-up bar above nav
[ ] OfferBannerCard      — 3 variants (flame/green/red)
[ ] CuisinePill          — active/inactive with animation
[ ] DietIcon             — veg/non-veg square with dot
[ ] QtyController        — ADD → (− qty +) animated transition
[ ] POSLiveIndicator     — blinking dot + kitchen text
[ ] ETARingTimer         — gradient ring with countdown
[ ] StepIndicator        — done/active/pending states + glow
[ ] AnimatedDot          — pulsing opacity dot
[ ] CouponDrawer         — bottom sheet with coupon tiles
```

---

## ICON USAGE RULE

```
Package:  hugeicons ^0.0.7
Style:    strokeRounded ONLY (never solid, never duotone)
Usage:    HugeIcon(icon: HugeIcons.strokeRounded[Name], color: ..., size: ...)
Sizes:    Nav=22, Section headers=18, Inline labels=14-16, Dense UI=12-13
Color:    AppColors.flame for primary, white for on-flame, txtMuted for inactive
```

---

## CRITICAL RULES FOR DEVELOPER

```
1. NO emojis anywhere in the UI — use Hugeicons exclusively
2. All primary buttons MUST use GradientButton widget (not ElevatedButton)
3. Floating nav MUST use BackdropFilter for glassmorphism
4. Minimum touch target: 48×48px on ALL interactive elements
5. Story ring gradient: always flame→mango (never reverse)
6. Veg icon: green border + green dot | Non-veg: red border + red dot
7. POS Live badge MUST appear on every restaurant card
8. Cart bar animates UP from below when first item added
9. ETA ring timer: no map, just the animated ring + milestone strip
10. Font weight scale: body=400, label=700, headline=800, price=800
```

---

## QUICK COMPONENT USAGE EXAMPLES

```dart
// PRIMARY CTA BUTTON
GradientButton(
  label: 'Place Order',
  leadingIcon: HugeIcons.strokeRoundedShieldTick,
  onTap: () => placeOrder(),
)

// DIET ICON
DietIcon(isVeg: dish.isVeg)

// ANIMATED DOT
AnimatedDot(size: 6, color: AppColors.posLive)

// QTY CONTROLLER
QtyController(
  quantity: cart.getQty(dish.id),
  onAdd: () => cart.add(dish),
  onRemove: () => cart.remove(dish),
)

// POS LIVE BAR
POSLiveIndicator(text: 'Direct POS Synchronized Kitchen')

// ETA RING
ETARingTimer(
  totalMinutes: 18,
  remainingMinutes: etaMinutes,
)

// FLOATING NAV
FloatingNavBar(
  currentIndex: _navIndex,
  onTap: (i) => setState(() => _navIndex = i),
)
```

---

## ANIMATION QUICK REFERENCE

```
Splash logo      → ScaleTransition (800ms, elasticOut)
Card entrance    → FadeIn + SlideUp, stagger n×80ms
Cart bar         → SlideUp from bottom (400ms, easeOut)
ADD → qty ctrl   → AnimatedSwitcher (250ms, spring)
Story tap        → Scale 1.0→1.07 (150ms)
ETA ring         → Arc sweep 0→progress (1000ms, easeOut)
Step complete    → Scale 0.6→1.15→1.0 (400ms, elasticOut)
Active step glow → BoxShadow pulse (2000ms, repeat)
Location pin     → TranslateY 0↔-7px (2500ms, easeInOut, repeat)
Pulse dot        → Opacity 1.0↔0.25 (1500ms, repeat)
CTA press        → Scale 1.0→0.97 (100ms)
```

---

*Generated for LiveRestro Flutter development handoff.*  
*Design: Electric Flame & Mango Chili · Icons: Hugeicons Stroke Rounded*
