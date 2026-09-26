# LiveRestro Flutter App — Developer Handoff Package v2
## START HERE — Updated with Nav Pages

---

## WHAT'S IN THIS PACKAGE

| File | Contents |
|------|----------|
| `00_README_START_HERE.md` | This file — overview, quick ref, changelog |
| `01_design_system.md` | Colors, typography, spacing, icons, theme config |
| `02_screen_specifications.md` | All 11 screens + 3 new nav pages spec |
| `03_components.md` | 15+ reusable widget specs with Dart pseudocode |
| `04_animations_data_navigation.md` | Animations, data models, routing, packages, folder structure |
| `05_new_nav_pages.md` | Search, Orders, Profile — detailed new page specs |

---

## CHANGELOG v2

```
NEW SCREENS ADDED:
  ✅ Search Page      — dedicated search with live filtering, recent chips, category browse
  ✅ Orders Page      — live order banner + past orders with filter tabs
  ✅ Profile Page     — focused profile (no order history — moved to Orders page)

NAV ROUTING CHANGES:
  OLD: Bottom nav tabs opened sections within Home screen
  NEW: Each nav tab is a full independent route/screen

  Home    (index 0) → /home          (no change)
  Search  (index 1) → /search        (NEW dedicated page)
  Orders  (index 2) → /orders        (NEW dedicated page)
  Profile (index 3) → /profile       (SIMPLIFIED — profile only, no order history)

HOME SCREEN CHANGE:
  Search bar on Home is now a TAPPABLE SHORTCUT → routes to /search
  It is NOT an actual TextInput anymore — just a tap target
```

---

## APP OVERVIEW

**App Name:** LiveRestro
**Platform:** Flutter (iOS + Android)
**Theme:** Electric Flame & Mango Chili
**Font:** Plus Jakarta Sans
**Icon Library:** Hugeicons (stroke rounded variant only)
**State Management:** Riverpod
**Navigation:** go_router

---

## COLOR QUICK REFERENCE

```
PRIMARY FLAME    #FF4500   → CTAs, active states, prices, badges
FLAME DARK       #CC2D00   → Gradient start, pressed states
MANGO            #FF9500   → Gradient end, highlights
FLAME TINT       #FFF3EE   → Card backgrounds, input fills
FLAME BORDER     #FFD9C8   → Card borders, dividers
PAGE BG          #FFF8F5   → App background (light cream)
CARD BG          #FFFFFF   → All card surfaces
TEXT PRIMARY     #1A1A1A   → Headlines, dish names
TEXT SECONDARY   #555555   → Descriptions, meta
TEXT MUTED       #999999   → Placeholders, timestamps
SUCCESS GREEN    #16A34A   → Veg badge, POS live, success states
NON VEG RED      #DC2626   → Non-veg badge, cancelled orders
STAR GOLD        #F59E0B   → Ratings
POS LIVE DOT     #4AFF91   → Live tracking pulse dot
```

---

## GRADIENT RECIPES

```dart
// HERO GRADIENT (headers, splash, tracking, orders hero)
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

## ALL SCREENS CHECKLIST

```
[ ] Screen 1  — Splash
[ ] Screen 2  — Login & OTP
[ ] Screen 3  — Profile Setup
[ ] Screen 4  — Location Picker
[ ] Screen 5  — Home Discovery  ← search bar is now a tap shortcut only
[ ] Screen 6  — Restaurant Menu
[ ] Screen 7  — Item Customization Bottom Sheet
[ ] Screen 8  — Cart & Bill
[ ] Screen 9  — Payment Selection
[ ] Screen 10 — Live Order Tracking
[ ] Screen 11 — My Profile       ← simplified, no order history section
[ ] Screen 12 — Search Page      ← NEW
[ ] Screen 13 — Orders Page      ← NEW
```

---

## UPDATED NAV ROUTING

```dart
// go_router routes — UPDATED

GoRoute(path: '/home',     builder: (_, __) => HomeScreen()),
GoRoute(path: '/search',   builder: (_, __) => SearchScreen()),   // NEW
GoRoute(path: '/orders',   builder: (_, __) => OrdersScreen()),   // NEW
GoRoute(path: '/profile',  builder: (_, __) => ProfileScreen()),  // UPDATED

// Bottom nav index → route mapping:
// 0 → /home
// 1 → /search        (was: open search field in home)
// 2 → /orders        (was: section in profile)
// 3 → /profile       (was: full profile with order history)

// Home screen search bar:
// NOT a TextInput — it's a GestureDetector that pushes /search
GestureDetector(
  onTap: () => context.push('/search'),
  child: SearchBarPlaceholder(), // visual only, no keyboard
)
```

---

## ICON USAGE RULE

```
Package:  hugeicons ^0.0.7
Style:    strokeRounded ONLY
Usage:    HugeIcon(icon: HugeIcons.strokeRounded[Name], color: ..., size: ...)
Sizes:    Nav=22, Section headers=18, Inline=14-16, Dense=12-13
```

---

## CRITICAL RULES FOR DEVELOPER

```
1.  NO emojis anywhere — Hugeicons stroke only
2.  Home search bar = GestureDetector → push /search (not a TextField)
3.  Search page has its own TextField with autofocus: true
4.  Orders page shows live order banner ONLY if active order exists
5.  Profile page has NO order history list (moved to /orders)
6.  All primary buttons use GradientButton (not ElevatedButton)
7.  Floating nav glassmorphism: BackdropFilter blur(20)
8.  Active nav tab: bg:flame pill, white text/icon
9.  Inactive nav tab: transparent bg, txtMuted color
10. Min touch target 48×48px on ALL interactive elements
```
