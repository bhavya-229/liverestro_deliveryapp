# LiveRestro — Screen-by-Screen UI Specifications
## All 10 Screens · Flutter Implementation Guide

---

## SCREEN 1 — Splash Screen

### Route: `/splash`
### File: `lib/screens/splash_screen.dart`

```
Layout: Stack
Background: AppColors.heroGradient (full screen)
Duration: 2.5 seconds → auto-navigate to /login
```

### Widget Tree
```
Scaffold
└── Stack (full screen)
    ├── Container (gradient background)
    │   └── LinearGradient: [#4D3346 → #714B67 → #D5B7CA]
    │       direction: topLeft → bottomRight
    │
    └── Center
        └── Column (mainAxisAlignment: center)
            ├── [ANIMATED] Logo Container
            │   ├── Size: 90×90
            │   ├── BorderRadius: 24
            │   ├── Background: rgba(255,255,255,0.15)
            │   ├── Border: 2px rgba(255,255,255,0.30)
            │   ├── Animation: ScaleTransition 0→1 (800ms, elasticOut curve)
            │   └── HugeIcon: strokeRoundedRestaurant01
            │       color: white, size: 44
            │
            ├── SizedBox(height: 16)
            │
            ├── [ANIMATED] Text "LiveRestro"
            │   ├── Style: displayMedium, color: white
            │   └── Animation: FadeTransition (delay 300ms, 600ms)
            │
            ├── SizedBox(height: 10)
            │
            ├── [ANIMATED] Tag pill
            │   ├── Container: bg rgba(255,255,255,0.18), border rgba(255,255,255,0.30)
            │   ├── BorderRadius: pillRadius
            │   ├── Padding: 5×14
            │   ├── Text: "Direct POS Ordering & Delivery"
            │   ├── Style: labelSmall, color: white
            │   └── Animation: FadeTransition (delay 600ms)
            │
            ├── SizedBox(height: 40)
            │
            └── CircularProgressIndicator
                ├── color: white
                ├── strokeWidth: 2
                └── size: 22×22
```

### Animations
```dart
// AnimationController duration: 800ms
// Logo: CurvedAnimation(curve: Curves.elasticOut)
// Text: FadeTransition with 300ms delay
// Tag: FadeTransition with 600ms delay

// Auto-navigate after 2500ms:
Future.delayed(Duration(milliseconds: 2500), () {
  Navigator.pushReplacementNamed(context, '/login');
});
```

---

## SCREEN 2 — Login & OTP Verification

### Route: `/login`
### File: `lib/screens/auth/login_screen.dart`
### State: `bool _otpSent = false` — toggles between mobile input and OTP input

```
Layout: Scaffold → Column
```

### Part A — Mobile Number Input (`_otpSent == false`)

```
Scaffold (bg: AppColors.bgPage)
└── Column
    ├── HERO HEADER (gradient)
    │   ├── Height: 180
    │   ├── Background: AppColors.heroGradient
    │   ├── BorderRadius: only bottomLeft(24), bottomRight(24)
    │   ├── Padding: 28 top, 16 horizontal
    │   └── Column (center)
    │       ├── Row (logo)
    │       │   ├── Container 30×30, radius:8, bg:rgba(white,0.20)
    │       │   │   └── HugeIcon: strokeRoundedRestaurant01, white, 18
    │       │   ├── SizedBox(width:8)
    │       │   └── Text "LiveRestro" — headlineMedium, white
    │       │
    │       ├── SizedBox(height: 12)
    │       └── Text "Order fresh food straight from kitchen POS"
    │           style: bodyMedium, white, textAlign: center
    │
    └── Expanded → SingleChildScrollView → Padding(16)
        └── Column
            ├── SizedBox(height: 20)
            │
            ├── FIELD LABEL ROW
            │   └── Row [HugeIcon:strokeRoundedCall, flame, 12]
            │         [Text "Mobile number" — labelSmall, flame]
            │
            ├── SizedBox(height: 6)
            │
            ├── MOBILE INPUT ROW
            │   └── Container (border: 1.5 flame100, radius: inputRadius, bg: white)
            │       └── Row
            │           ├── PREFIX — Container (bg: flame50, borderRight: 1 flame100)
            │           │   Padding: 12×10
            │           │   Row [Flag Image "🇮🇳"] [Text "+91" — labelMedium, flame]
            │           │
            │           └── Expanded → TextFormField
            │               keyboardType: phone
            │               maxLength: 10
            │               style: bodyLarge
            │               decoration: InputDecoration(border: none, counterText: "")
            │
            ├── SizedBox(height: 16)
            │
            ├── CTA BUTTON — "Get OTP"
            │   ├── Width: full, Height: 52
            │   ├── Background: AppColors.ctaGradient
            │   ├── BorderRadius: 12
            │   └── Row [HugeIcon:strokeRoundedArrowRight01, white, 16]
            │         [Text "Get OTP" — ctaButton]
            │
            ├── SizedBox(height: 24)
            │
            └── TRUST CARD
                ├── Container bg: flame50, radius: 10, padding: 10×12
                └── Row
                    ├── HugeIcon: strokeRoundedShieldTick, flame, 18
                    └── Expanded → Text "Zero hidden commissions — sent directly to kitchen POS"
                        style: labelSmall, color: flameDark
```

### Part B — OTP Screen (`_otpSent == true`)

```
    └── Column (same hero)
        └── Expanded → Padding(16)
            └── Column
                ├── SizedBox(height: 20)
                │
                ├── FIELD LABEL ROW
                │   └── Row [HugeIcon:strokeRoundedLockKey, flame, 12]
                │         [Text "Enter OTP" — labelSmall, flame]
                │
                ├── SizedBox(height: 6)
                │
                ├── OTP BOXES ROW
                │   └── Row (mainAxisAlignment: spaceBetween)
                │       └── × 6 OTP Box Widgets
                │           ├── Size: 44×48
                │           ├── Border: 1.5 flame100 (active: flame, filled: flame)
                │           ├── BorderRadius: 10
                │           ├── Background: white
                │           ├── Text: digit or empty
                │           ├── Style: displayLarge, flame
                │           └── [active box]: box-shadow: 0 0 0 3px rgba(flame, 0.12)
                │
                ├── SizedBox(height: 10)
                │
                ├── TIMER ROW (center)
                │   └── Row [HugeIcon:strokeRoundedClock01, flame2, 12]
                │         [Text "Resend OTP in 0:29" — labelSmall, flame2]
                │         [CountdownTimer widget]
                │
                ├── SizedBox(height: 14)
                │
                ├── CTA BUTTON — "Verify & Continue"
                │   └── [same style as Get OTP button]
                │       icon: strokeRoundedCheckmarkCircle01
                │
                └── TRUST CARD (same as above)
```

### OTP Box Widget Notes
```dart
// Auto-focus next box on digit entry
// Auto-submit when all 6 filled
// Backspace moves to previous box
// SMS autofill via sms_autofill package
```

---

## SCREEN 3 — Profile Setup

### Route: `/profile-setup`
### File: `lib/screens/auth/profile_setup_screen.dart`

```
Scaffold (bg: bgPage)
└── Column
    ├── GRADIENT HEADER (height: 80)
    │   ├── Background: heroGradient, radius: bottomLeft(24) bottomRight(24)
    │   └── Row (padding: 14×16)
    │       ├── BackButton (circle, rgba white 0.20, HugeIcon:strokeRoundedArrowLeft01)
    │       └── Text "Set up your profile" — headlineSmall, white
    │
    └── Expanded → SingleChildScrollView → Padding(14)
        └── Column
            ├── SizedBox(height: 10)
            │
            ├── INPUT LABEL [HugeIcon:strokeRoundedUser, flame, 12] "Full name"
            ├── SizedBox(height: 5)
            ├── TextFormField (style: standard input, required)
            │
            ├── SizedBox(height: 12)
            │
            ├── INPUT LABEL [HugeIcon:strokeRoundedMail01, flame, 12] "Email (optional)"
            ├── SizedBox(height: 5)
            ├── TextFormField (keyboardType: email, optional)
            │
            ├── SizedBox(height: 14)
            │
            ├── VEG MODE CARD
            │   ├── Container bg:white, border:1.5 flame100, radius:12, padding:12×14
            │   └── Row
            │       ├── Container 36×36, radius:10, bg:successBg
            │       │   └── HugeIcon: strokeRoundedLeaf01, success, 20
            │       ├── SizedBox(width:10)
            │       ├── Expanded → Column
            │       │   ├── Text "Pure Veg Mode" — labelLarge
            │       │   └── Text "Show only vegetarian options" — bodySmall
            │       └── FlutterSwitch (or CupertinoSwitch)
            │           activeColor: success
            │           onChanged: toggleVegMode
            │
            ├── SizedBox(height: 12)
            │
            ├── PROMO ACCORDION
            │   ├── Container bg:white, border:1.5 dashed flame200, radius:12, padding:12×14
            │   └── ExpansionTile (no default decoration)
            │       ├── title: Row
            │       │   ├── HugeIcon:strokeRoundedDiscount01, flame, 14
            │       │   └── Text "Have a referral or coupon code?" — labelMedium, flame
            │       └── children:
            │           ├── Row
            │           │   ├── Expanded → TextFormField (hint: "Enter code")
            │           │   └── SizedBox(width:6)
            │           │   └── ElevatedButton "Apply" (compact, flame bg)
            │           └── [if applied] Row
            │               ├── HugeIcon:strokeRoundedCheckmarkCircle01, success, 13
            │               └── Text "₹100 discount applied!" — labelSmall, success
            │
            ├── SizedBox(height: 16)
            │
            └── CTA BUTTON — "Start Exploring Food →"
                ├── Full width, height: 52, gradient bg
                └── trailing: HugeIcon:strokeRoundedArrowRight01
```

---

## SCREEN 4 — Location Picker

### Route: `/location`
### File: `lib/screens/location/location_screen.dart`

```
Scaffold (bg: bgPage)
└── Column
    ├── MAP AREA (height: 240)
    │   ├── Background: gradient (FFE8D9 → FFD0B5)
    │   ├── Grid lines overlay (subtle, rgba flame 0.10)
    │   │   └── CustomPaint — draw horizontal & vertical grid lines
    │   │
    │   ├── CENTER PIN (animated)
    │   │   ├── Column (center of stack)
    │   │   │   ├── HugeIcon: strokeRoundedMapsPin01, flame, 36
    │   │   │   │   Animation: TweenAnimationBuilder translateY -8px↔0 (2.5s, easeInOut, repeat)
    │   │   │   ├── Container (shadow dot)
    │   │   │   │   size: 6×6, bg: flame, radius: 3, opacity: 0.6
    │   │   │   └── Container (label)
    │   │   │       bg: flameDark, radius: 5, padding: 3×8
    │   │   │       Text: "Order delivered here" — labelSmall, white
    │   │   │
    │   │   └── NOTE: In production, replace with google_maps_flutter
    │   │       GoogleMap widget with custom marker & draggable pin
    │   │
    │   └── GPS BUTTON (bottom-right, position: absolute)
    │       ├── Container 36×36, bg:white, radius:50%, border:1.5 flame100
    │       └── HugeIcon: strokeRoundedGps01, flame, 18
    │           onTap: getCurrentLocation()
    │
    └── Expanded → SingleChildScrollView → Padding(14)
        └── Column
            ├── SizedBox(height: 10)
            │
            ├── ADDRESS TYPE PILLS
            │   └── Row (gap: 6)
            │       ├── Pill "Home"  [HugeIcon:strokeRoundedHome01]
            │       ├── Pill "Work"  [HugeIcon:strokeRoundedOffice]
            │       └── Pill "Other" [HugeIcon:strokeRoundedMapsPin01]
            │       Active pill: bg:flame, color:white
            │       Inactive: bg:white, border:flame100, color:flame2
            │
            ├── SizedBox(height: 10)
            │
            ├── TextFormField
            │   hint: "Flat/House no., Street, Area"
            │   prefixIcon: HugeIcon:strokeRoundedHome03, flame, 16
            │
            ├── SizedBox(height: 8)
            │
            ├── TextFormField
            │   hint: "Landmark (e.g. Near ISRO circle)"
            │   prefixIcon: HugeIcon:strokeRoundedBuilding01, flame, 16
            │
            ├── SizedBox(height: 14)
            │
            └── CTA BUTTON — "Confirm & Deliver Here"
                icon: HugeIcon:strokeRoundedCheckmarkCircle01
```

---

## SCREEN 5 — Home & Restaurant Discovery

### Route: `/home`
### File: `lib/screens/home/home_screen.dart`

```
Scaffold (bg: bgPage)
├── BODY: CustomScrollView
│   └── slivers:
│       ├── SliverToBoxAdapter → TOP BAR (sticky)
│       │   ├── bg: bgPage, padding: 10×16
│       │   └── Row
│       │       ├── LOGO ROW
│       │       │   ├── Container 28×28, radius:8, gradient bg
│       │       │   │   └── HugeIcon:strokeRoundedRestaurant01, white, 16
│       │       │   └── Text "LiveRestro" — headlineSmall, flame
│       │       │
│       │       ├── Expanded → CENTER: LOCATION PILL
│       │       │   ├── GestureDetector → navigate to /location
│       │       │   ├── Container bg:flame50, radius:pill, padding:4×8
│       │       │   └── Row
│       │       │       ├── AnimatedDot (6px, flame, pulsing opacity)
│       │       │       ├── Text "Ahmedabad, GJ" — labelSmall, flame
│       │       │       └── HugeIcon:strokeRoundedArrowDown01, flame, 10
│       │       │
│       │       └── TRAILING ROW (gap: 8)
│       │           ├── IconButton: HugeIcon:strokeRoundedMoon01/Sun01
│       │           │   (theme toggle)
│       │           └── CircleAvatar (gradient bg, initials, size: 32)
│       │
│       ├── SliverToBoxAdapter → SEARCH BAR
│       │   ├── Margin: 6×16
│       │   ├── Container bg:white, border:1.5 flame100, radius:12
│       │   └── TextField
│       │       prefixIcon: HugeIcon:strokeRoundedSearch01, txtMuted, 18
│       │       hint: "Search restaurants, dishes, cuisines…"
│       │       onChanged: filterRestaurants
│       │
│       ├── SliverToBoxAdapter → VEG TOGGLE ROW
│       │   ├── Padding: 6×16
│       │   └── Row (spaceBetween)
│       │       ├── Row
│       │       │   ├── VEG SQUARE ICON
│       │       │   │   Container 14×14, border:1.5 success, radius:2
│       │       │   │   └── Container 7×7, bg:success, radius:50%
│       │       │   └── Text "Pure Veg Mode" — labelMedium, success
│       │       └── CupertinoSwitch (activeColor: success)
│       │
│       ├── SliverToBoxAdapter → OFFER BANNERS
│       │   └── SizedBox(height: 96)
│       │       └── ListView.builder (horizontal, scrollDirection: Axis.horizontal)
│       │           padding: EdgeInsets.symmetric(horizontal: 16)
│       │           itemExtent: 220 + 10 (gap)
│       │           └── OfferBannerCard (see components)
│       │
│       ├── SliverToBoxAdapter → STORY SECTION
│       │   ├── Padding(left:16) Text "Restaurant Stories" — labelLarge
│       │   └── SizedBox(height: 86)
│       │       └── ListView.builder (horizontal)
│       │           └── StoryBubbleWidget (see components)
│       │
│       ├── SliverToBoxAdapter → CUISINE PILLS
│       │   └── SizedBox(height: 44)
│       │       └── ListView.builder (horizontal)
│       │           padding: 16 horizontal
│       │           └── CuisinePillWidget
│       │
│       ├── SliverToBoxAdapter → SECTION HEADER
│       │   └── Row(spaceBetween) padding:14×16
│       │       ├── Text "All Restaurants" — headlineSmall
│       │       └── Text "See all →" — labelSmall, flame
│       │
│       ├── [LOADING STATE] SliverList → SkeletonRestaurantCard × 3
│       │
│       └── SliverList.builder
│           └── RestaurantCard (see components)
│               itemCount: filtered restaurants
│               padding: EdgeInsets.only(bottom: 16)
│
└── FLOATING ELEMENTS (Stack overlay)
    ├── CART BAR (if cart not empty)
    │   ├── position: bottom 80, left 16, right 16
    │   └── CartBarWidget (see components)
    │
    └── FLOATING NAV BAR
        ├── position: bottom 16, centered
        └── FloatingNavBar (see components)
```

---

## SCREEN 6 — Restaurant Menu

### Route: `/restaurant/:id`
### File: `lib/screens/restaurant/restaurant_screen.dart`

```
Scaffold (bg: bgPage)
└── CustomScrollView
    ├── SliverAppBar (pinned, expandedHeight: 140)
    │   ├── Background: heroGradient
    │   ├── leading: back button (circle, rgba white 0.20)
    │   ├── flexibleSpace: FlexibleSpaceBar
    │   │   └── Stack
    │   │       ├── Gradient background
    │   │       ├── CENTER: Container 48×48, bg:rgba(white,0.15), radius:13
    │   │       │   └── HugeIcon: strokeRoundedRestaurant01, white, 28
    │   │       └── BOTTOM INFO (padding: 12)
    │   │           ├── Text: restaurant name — headlineSmall, white
    │   │           ├── Text: cuisine types — bodySmall, white 0.80
    │   │           └── Row: [star icon gold] [rating] [·] [reviews] [·] [time]
    │   │               style: labelSmall, white
    │   │
    │   └── bottom: POS ASSURANCE BAR
    │       ├── Container bg:successBg, padding:8×14
    │       └── Row
    │           ├── AnimatedDot (6px, success, blinking)
    │           ├── HugeIcon:strokeRoundedComputerDesk, success, 14
    │           └── Text "Direct POS Synchronized Kitchen — live order sync"
    │               style: labelSmall, success
    │
    ├── SliverPersistentHeader (pinned) → CATEGORY TABS
    │   ├── Height: 42
    │   ├── bg: white, borderBottom: 1.5 flame100
    │   └── TabBar (custom)
    │       indicator: underline, flame, 2px
    │       labelColor: flame
    │       unselectedLabelColor: txtMuted
    │       tabs: [Starters, Main Course, Breads, Combos, Beverages]
    │
    └── SliverList → MENU SECTIONS
        └── per category:
            ├── SECTION HEADER
            │   padding: 14×12, borderBottom: 1 flame50
            │   Text: category name — labelLarge, txtPrimary
            │
            └── DishItemCard × n (see components)
```

### Dish Item Card
```
Container (borderBottom: 1 flame50, padding: 12×0)
└── Row (crossAxisAlignment: start)
    ├── Expanded → Column
    │   ├── DIET ROW
    │   │   └── Row (gap: 5)
    │   │       ├── VEG/NON-VEG ICON (14×14 square with inner dot)
    │   │       └── [if bestseller] BestsellerTag
    │   │           Container bg:#FFF3E0, radius:3, padding:1×4
    │   │           Text "Bestseller" — style: 9px, #E65100, bold
    │   │
    │   ├── Text: dish name — labelLarge
    │   ├── Text: "₹{price}" — priceTagSmall
    │   ├── Text: description (maxLines:2, overflow:ellipsis) — bodySmall
    │   └── [if customizable] Text "Customizable" — 10px, flame2, italic
    │
    └── Column (alignItems: end, gap: 6)
        └── DISH IMAGE CONTAINER (80×76, radius:10, bg:flame50)
            ├── HugeIcon: relevant food icon, flame2, 32, opacity:0.65
            └── ADD BUTTON (positioned, bottom:-10, centerX)
                if qty == 0:
                    Container bg:flame, radius:7, padding:4×10
                    Text "+ ADD" — 11px, white, bold
                if qty > 0:
                    Container bg:flame, radius:7
                    Row:
                        [IconButton −] [Text qty] [IconButton +]
```

---

## SCREEN 7 — Item Customization Bottom Sheet

### File: `lib/screens/restaurant/customization_sheet.dart`
### Trigger: showModalBottomSheet when tapping "+ ADD" on customizable dish

```
DraggableScrollableSheet
├── initialChildSize: 0.65
├── maxChildSize: 0.92
└── Container (bg:white, radius: topLeft(20) topRight(20))
    ├── HANDLE BAR (4×40, bg:flame100, radius:2, center, margin:10)
    │
    ├── DISH HEADER ROW (padding:14×16)
    │   ├── Container 56×52, radius:10, bg:flame50
    │   │   └── HugeIcon: food icon, flame2, 28
    │   ├── SizedBox(8)
    │   └── Column
    │       ├── Text: dish name — headlineSmall
    │       └── Text: "₹{basePrice}" — priceTagSmall
    │
    ├── Divider (color: flame100)
    │
    ├── Expanded → SingleChildScrollView → Padding(16)
    │   ├── RADIO GROUP — "Choose Portion"
    │   │   ├── Text "Choose Portion" — labelLarge, margin-bottom:8
    │   │   ├── required badge: "Required" — 9px, white, bg:flame, radius:4
    │   │   └── Column
    │   │       └── × options (Regular / Double / Family)
    │   │           ListTile
    │   │           ├── leading: Radio (activeColor: flame)
    │   │           ├── title: Text option name — labelMedium
    │   │           └── trailing: Text "+₹{extra}" — priceTagSmall
    │   │
    │   ├── SizedBox(height: 14)
    │   │
    │   ├── CHECKBOX GROUP — "Add Extras"
    │   │   ├── Text "Add Extras (Optional)" — labelLarge
    │   │   └── Column
    │   │       └── × extras (Extra Cheese, Crispy Strips, etc.)
    │   │           CheckboxListTile
    │   │           ├── activeColor: flame
    │   │           ├── title: Text — labelMedium
    │   │           └── secondary: Text "+₹{price}" — priceTagSmall
    │   │
    │   ├── SizedBox(height: 14)
    │   │
    │   └── COOKING INSTRUCTIONS
    │       ├── Text "Special instructions" — labelLarge
    │       └── TextFormField (multiline, maxLines:3)
    │           hint: "e.g. Less spicy, extra crunchy"
    │           prefixIcon: HugeIcon:strokeRoundedNoteEdit, flame, 16
    │
    └── BOTTOM BAR (padding:14×16, borderTop:1 flame100)
        └── Row (spaceBetween)
            ├── Column
            │   ├── Text "Total" — labelSmall, txtMuted
            │   └── Text "₹{dynamicTotal}" — priceTag
            └── ElevatedButton "Add to Order"
                width: 150, gradient bg
                leading: HugeIcon:strokeRoundedShoppingBag01
```

---

## SCREEN 8 — Cart & Bill Summary

### Route: `/cart`
### File: `lib/screens/cart/cart_screen.dart`

```
Scaffold (bg:bgPage)
└── Column
    ├── APP BAR
    │   └── Row (padding:12×16, bg:white, borderBottom:1 flame50)
    │       ├── Column
    │       │   ├── Text: restaurant name — headlineSmall
    │       │   └── Text: "{n} items in cart" — bodySmall, txtMuted
    │       └── Row (gap:8)
    │           ├── HugeIcon:strokeRoundedDelete01, red, 16
    │           └── Text "Clear all" — labelSmall, red
    │
    └── Expanded → SingleChildScrollView
        └── Column
            ├── CART ITEMS LIST
            │   └── ListView (shrinkWrap, physics:NeverScroll)
            │       └── CartItemRow per item
            │           Row (padding:10×12, borderBottom:1 flame50)
            │           ├── DietSquareIcon
            │           ├── SizedBox(8)
            │           ├── Expanded → Column
            │           │   ├── Text: name — labelLarge
            │           │   ├── [if customized] Text: options — bodySmall, txtMuted
            │           │   └── Text: "₹{price} each" — priceTagSmall
            │           └── QtyController (− val +) bg:flame, white text
            │
            ├── COUPON SECTION
            │   └── GestureDetector → showCouponDrawer()
            │       Container margin:10×12, border:1.5 dashed flame200, radius:12
            │       padding:10×14, bg:white
            │       Row (spaceBetween)
            │       ├── Row [HugeIcon:strokeRoundedDiscount01, flame, 14]
            │       │     [Text "Apply a coupon code" — labelMedium, flame]
            │       └── HugeIcon:strokeRoundedArrowRight01, flame, 14
            │       [if applied]: show green success state with code + savings
            │
            ├── TIP SECTION
            │   ├── Padding(12×14)
            │   ├── Row [HugeIcon:strokeRoundedFavourite, flame, 14]
            │   │     [Text "Tip your delivery partner" — labelMedium]
            │   └── SizedBox(height:8)
            │       └── Row (gap:6)
            │           ├── TipChip "No tip"
            │           ├── TipChip "₹20"
            │           ├── TipChip "₹30"
            │           └── TipChip "₹50"
            │           Active: bg:flame, color:white
            │           Inactive: bg:white, border:flame100, color:txtSecondary
            │
            ├── BILL BREAKDOWN
            │   └── Container margin:8×12, bg:flame50, radius:12, padding:12×14
            │       ├── Row [HugeIcon:strokeRoundedReceipt, flame,13]
            │       │     [Text "Bill breakdown" — labelLarge] margin-bottom:10
            │       ├── BillRow "Item total"       → "₹{itemTotal}"
            │       ├── BillRow "Delivery fee"     → "FREE" (green)
            │       ├── BillRow "Platform fee"     → "₹5"
            │       ├── BillRow "GST (5%)"         → "₹{gst}"
            │       ├── [if coupon] BillRow "Discount" → "−₹{disc}" (green)
            │       ├── Divider (flame100)
            │       └── Row (spaceBetween)
            │           ├── Text "Total payable" — labelLarge
            │           └── Text "₹{total}" — priceTag
            │
            └── SizedBox(height:100) [space for bottom CTA]
    │
    └── BOTTOM CTA BAR (position: bottom, padding:14×16, bg:white, borderTop:1 flame100)
        └── GradientButton full-width
            Row (spaceBetween)
            ├── Text "Select payment" — ctaButton
            └── Row [Text "₹{total}"] [HugeIcon:strokeRoundedArrowRight01]
```

---

## SCREEN 9 — Payment Selection

### Route: `/payment`
### File: `lib/screens/payment/payment_screen.dart`

```
Scaffold (bg:bgPage)
└── SingleChildScrollView
    └── Column
        ├── AMOUNT SUMMARY CARD
        │   ├── Container margin:14, bg:heroGradient, radius:16, padding:16
        │   └── Row (spaceBetween)
        │       ├── Column
        │       │   ├── Text "Total payable" — 10px, white 0.80
        │       │   └── Text "₹{total}" — displayMedium, white
        │       └── Container 42×42, bg:rgba(white,0.18), radius:50%
        │           └── HugeIcon:strokeRoundedShieldTick, white, 22
        │
        ├── PAYMENT GROUP — "INSTANT UPI"
        │   ├── Group label: Text "INSTANT UPI" — labelSmall, txtMuted, letterSpacing:0.5
        │   └── Column (gap:6, margin:0×14)
        │       └── PaymentOptionTile × 3
        │           ├── Google Pay  [HugeIcon:strokeRoundedFlash, flame]
        │           ├── PhonePe     [HugeIcon:strokeRoundedMobilePayment, flame]
        │           └── Paytm       [HugeIcon:strokeRoundedWallet01, flame]
        │
        │   PaymentOptionTile:
        │   Container bg:white, border:1.5 flame100, radius:11, padding:11×13
        │   [selected] border:flame, bg:flame50
        │   Row:
        │   ├── Container 32×32, radius:9, bg:flame50 → HugeIcon, flame, 17
        │   ├── SizedBox(9)
        │   ├── Expanded → Column
        │   │   ├── Text: name — labelLarge
        │   │   └── Text: subtitle — bodySmall
        │   └── Radio widget (activeColor: flame)
        │
        ├── PAYMENT GROUP — "ONLINE PAYMENT"
        │   └── PaymentOptionTile
        │       └── Razorpay [HugeIcon:strokeRoundedCreditCard, flame]
        │
        ├── PAYMENT GROUP — "CASH"
        │   └── PaymentOptionTile
        │       └── Cash on Delivery [HugeIcon:strokeRoundedMoney01, flame]
        │
        └── PLACE ORDER CTA
            ├── Margin: 14, full width, height:54
            ├── Background: heroGradient
            ├── BorderRadius: 14
            └── Row [HugeIcon:strokeRoundedShieldTick, white, 16]
                  [Text "Pay ₹{total} & Place POS Order" — ctaButton]
```

---

## SCREEN 10 — Live Order Tracking

### Route: `/tracking/:orderId`
### File: `lib/screens/tracking/tracking_screen.dart`

```
Scaffold (bg:bgPage)
└── SingleChildScrollView
    └── Column
        ├── GRADIENT HEADER
        │   ├── Container bg:heroGradient, padding:12×16
        │   ├── Text "Live order tracking" — labelLarge, white
        │   └── Row [AnimatedDot green] [Text "POS kitchen confirmed" — 9px, white 0.75]
        │
        ├── ETA RING SECTION (center)
        │   ├── Padding: 14 all
        │   └── Center
        │       └── Stack (size: 160×160)
        │           ├── RING TRACK — CustomPaint
        │           │   (circle stroke, flame100, width:10)
        │           ├── RING PROGRESS — CustomPaint / CircularProgressIndicator
        │           │   ├── gradient stroke: flame → mango
        │           │   ├── strokeWidth: 10
        │           │   ├── strokeCap: round
        │           │   └── value: (totalSeconds - remaining) / totalSeconds
        │           │   Animation: animateFrom 0→value on enter (1000ms, easeOut)
        │           ├── PULSE RING (outer, animated)
        │           │   AnimationController repeat
        │           │   scale: 1.0→1.06, opacity: 0.5→0.0
        │           └── CENTER CONTENT
        │               └── Column (center)
        │                   ├── Text "{minutes}" — 32px, flame, w800
        │                   └── Text "minutes" — labelSmall, txtMuted
        │
        ├── STATUS CHIP (center)
        │   └── Container bg:flame50, border:1.5 flame100, radius:pill, padding:6×16
        │       Row [AnimatedDot flame] [HugeIcon:strokeRoundedCookingPot, flame, 13]
        │            [Text "Food being prepared in kitchen" — labelSmall, flame]
        │
        ├── MILESTONE STRIP
        │   ├── Container margin:12×14, bg:white, border:1.5 flame100, radius:13, padding:12
        │   └── Row (spaceBetween, crossAxis:start)
        │       Repeat for each milestone:
        │       [MilestoneNode] ── [ConnectorLine] ── [MilestoneNode] ...
        │
        │   MilestoneNode:
        │   Column (center)
        │   ├── Container 28×28, radius:50%
        │   │   done: bg:flame, icon:white
        │   │   active: bg:flame50, border:2 flame, pulsing glow animation
        │   │   pending: bg:flame50
        │   │   └── HugeIcon (relevant per stage), size:14
        │   └── Text: stage label — 7px, done:flame, active:flame, pending:txtMuted
        │
        │   Stages: "3.2 km" / "Kitchen" / "On way" / "Your door"
        │   ConnectorLine: height:2, done:flame, pending:flame100
        │
        ├── RIDER CARD
        │   ├── Container margin:10×14, bg:white, border:1.5 flame100, radius:13, padding:12
        │   └── Row
        │       ├── CircleAvatar (size:42, gradient bg, initials)
        │       ├── SizedBox(10)
        │       ├── Expanded → Column
        │       │   ├── Text: rider name — labelLarge
        │       │   ├── Text: "vehicle reg · model" — bodySmall
        │       │   └── Container (rating badge)
        │       │       bg:successBg, radius:5, padding:2×7
        │       │       Row [HugeIcon:strokeRoundedStar, success, 10] [Text "4.9 Top Rated"]
        │       └── GestureDetector → url_launcher call
        │           Container 34×34, bg:successBg, radius:50%
        │           └── HugeIcon:strokeRoundedCall, success, 17
        │
        └── 5-STAGE LIVE STEPPER
            ├── Padding: 12×14
            └── Column (gap:0)
                └── StepItem × 5
                    Row (crossAxisAlignment: start)
                    ├── LEFT COLUMN (step indicator)
                    │   ├── StepCircle (26×26, radius:50%)
                    │   │   done:   bg:flame, icon: HugeIcon:strokeRoundedCheckmark, white
                    │   │   active: bg:flame50, border:2 flame, HugeIcon relevant, flame
                    │   │          + glowing pulse animation
                    │   │   pending: bg:transparent, border:2 flame100, relevant icon, txtMuted
                    │   └── [not last] ConnectorLine (width:2, flex:1)
                    │       done: flame, pending: flame100
                    │
                    └── RIGHT CONTENT (padding: 4 top, flex:1)
                        ├── Text: step label — labelMedium
                        │   done/active: flame, w800
                        │   pending: txtMuted
                        └── [active] Text: sub-label / live timer — 9px, txtMuted

            Stages:
            1. "Order placed & sent to kitchen POS"  → checkmark
            2. "Food is being prepared"              → cookingPot icon + live timer
            3. "Order ready & rider assigned"        → clock icon
            4. "Out for delivery"                    → motorbike icon
            5. "Delivered!"                          → checkmarkCircle
```

---

## SCREEN 11 — My Profile & Order History

### Route: `/profile`
### File: `lib/screens/profile/profile_screen.dart`

```
Scaffold (bg:bgPage)
└── SingleChildScrollView
    └── Column
        ├── HERO HEADER
        │   ├── Container bg:heroGradient, padding:22×16 30bottom
        │   └── Column (center)
        │       ├── CircleAvatar
        │       │   size:60, bg:rgba(white,0.22), border:2 rgba(white,0.40)
        │       │   child: Text initials — 20px, white, w800
        │       ├── SizedBox(8)
        │       ├── Text: user name — headlineMedium, white
        │       └── Text: "+91 XXXXX · email" — bodySmall, white 0.75
        │
        ├── SETTINGS CARD
        │   ├── Container margin:14, bg:white, border:1.5 flame100, radius:13
        │   └── Column
        │       ├── ProfileRow "Pure Veg Mode"
        │       │   icon: HugeIcon:strokeRoundedLeaf01
        │       │   trailing: CupertinoSwitch (activeColor:success)
        │       │
        │       ├── ProfileRow "Dark Mode"
        │       │   icon: HugeIcon:strokeRoundedMoon01
        │       │   trailing: CupertinoSwitch (activeColor:flame)
        │       │
        │       ├── ProfileRow "Saved Addresses"
        │       │   icon: HugeIcon:strokeRoundedMapsPin01
        │       │   trailing: Row [Text "2 saved"] [HugeIcon:strokeRoundedArrowRight01]
        │       │
        │       └── ProfileRow "Payment Methods"
        │           icon: HugeIcon:strokeRoundedCreditCard
        │           trailing: Row [Text "GPay"] [HugeIcon:strokeRoundedArrowRight01]
        │
        │   ProfileRow structure:
        │   Container (borderBottom: 1 flame50, padding:10×14)
        │   Row:
        │   ├── Container 30×30, radius:9, bg:flame50
        │   │   └── HugeIcon, flame, 16
        │   ├── SizedBox(10)
        │   ├── Expanded → Text: label — labelMedium
        │   └── trailing widget
        │
        ├── SECTION LABEL (padding:14×14)
        │   Text "Order history" — labelLarge
        │
        ├── ORDER HISTORY CARDS
        │   └── Column (margin:0×14, gap:8)
        │       └── OrderHistoryCard × n
        │           Container bg:white, border:1.5 flame100, radius:12, padding:11×13
        │           ├── Text: restaurant name — labelLarge
        │           ├── Row [HugeIcon:strokeRoundedCalendar01, txtMuted, 11]
        │           │     [Text: date/time — bodySmall]
        │           ├── Text: items summary — bodySmall, txtSecondary (maxLines:1)
        │           └── Row (spaceBetween, marginTop:8)
        │               ├── Text "₹{amount}" — priceTagSmall
        │               └── ElevatedButton compact
        │                   if active: "Track Live →" bg:flame
        │                   if past:   "Reorder"      bg:flame
        │                   Row [HugeIcon relevant, white, 12] [Text]
        │
        └── LOGOUT
            ├── Container margin:0×14, bg:white, border:1.5 nonVegBg, radius:13, padding:13
            └── Row (center)
                ├── HugeIcon:strokeRoundedLogout01, nonVeg, 17
                └── Text "Log out" — labelLarge, nonVeg
```
