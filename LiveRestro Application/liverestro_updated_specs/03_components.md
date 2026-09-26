# LiveRestro — Reusable Component Specifications
## Flutter Widget Library

---

## 1. FLOATING GLASSMORPHISM NAVBAR

### File: `lib/widgets/floating_nav_bar.dart`

```dart
// Design Spec:
// - Glassmorphism pill: frosted glass effect
// - Position: fixed bottom 16px, horizontally centered
// - Background: rgba(255,255,255,0.55) with blur
// - Border: 1px rgba(255,69,0,0.20)
// - BorderRadius: 36px (pill)
// - Padding: 8px vertical, 10px horizontal
// - Shadow: 0 8px 32px rgba(0,0,0,0.12)

Widget build(BuildContext context) {
  return Positioned(
    bottom: 16,
    left: 0,
    right: 0,
    child: Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.55),
              borderRadius: BorderRadius.circular(36),
              border: Border.all(
                color: AppColors.flame.withOpacity(0.20),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 32,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                NavItem(icon: AppIcons.home,   label: 'Home',   index: 0),
                NavItem(icon: AppIcons.search, label: 'Search', index: 1),
                NavItem(icon: AppIcons.orders, label: 'Orders', index: 2),
                NavItem(icon: AppIcons.profile,label: 'Profile',index: 3),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

// ACTIVE NAV ITEM:
// Container: bg:flame, borderRadius:28, padding: 8×18
// Column: icon (white) + label (white, 9px, bold)
// Transition: AnimatedContainer (200ms)

// INACTIVE NAV ITEM:
// Container: transparent, borderRadius:28, padding: 8×14
// Column: icon (txtMuted) + label (txtMuted, 9px, bold)
// onHover/onTap: bg:flame50, icon:flame
```

---

## 2. STORY BUBBLE WIDGET

### File: `lib/widgets/story_bubble.dart`

```dart
// UNSEEN STORY:
// Outer ring: 64×64, gradient border (flame→mango), padding:2.5
// Inner circle: white border 2.5, overflow:hidden
// Content: restaurant icon (HugeIcon, flame, 26)
// Badge: absolute bottom-right, bg:flame, 8×radius, "2" count
// Label: restaurant name below, 10px, txtSecondary, maxWidth:64, overflow:ellipsis

// SEEN STORY:
// Outer ring: gradient replaced with Color(0xFFCCCCCC)
// All else same

// ANIMATION on tap:
// ScaleTransition: 1.0 → 1.07 (150ms)

// STORY VIEWER (Full screen overlay):
// Navigator.push with custom PageRouteBuilder
// slideInFrom: right (translateX 60→0, opacity 0→1, 300ms)
// See story_viewer.dart below
```

### Story Viewer
```dart
// File: lib/widgets/story_viewer.dart

// Layout: Stack full-screen, bg:black 0.92
// Container: 320px wide, radius:20, bg:#1a1a1a
// 
// PROGRESS BARS (top):
// Row of thin bars (3px height, gap:4)
// Active bar: white fill, animated width 0→100% in 5000ms
// Completed bars: white full width
// Pending bars: rgba(white,0.30)
//
// STORY HEADER (absolute top):
// Row: [CircleAvatar restaurant] [name+time] [close X button]
//
// STORY CONTENT (480px tall):
// Background: gradient (flameDark → plum dark)
// Center Column:
// ├── Restaurant icon container (70×70, radius:18, flame bg, shadow)
// ├── Chip: offer type (glass effect, floating animation -4px ↔ 0, 3s loop)
// ├── Title (22px, white, bold)
// ├── Subtitle (13px, white 0.75)
// └── CTA Button (flame bg)
//
// GESTURE: swipe left→next story, swipe right→prev, tap right 70%→next, tap left 30%→prev
// AUTO-ADVANCE: 5 seconds per story slide
```

---

## 3. RESTAURANT CARD

### File: `lib/widgets/restaurant_card.dart`

```dart
// CARD CONTAINER:
// bg: white
// borderRadius: 12
// border: 1px flame100
// margin-bottom: 16
// shadow: 0 0 0 transparent (hover: 0 12px 32px rgba(flame,0.15))
// 
// ANIMATION on mount:
// FadeTransition + SlideTransition(dy: 0.08→0)
// staggerDelay: index * 80ms
//
// HOVER/TAP animation:
// AnimatedContainer: transform translateY(0→-3px), shadow increase
// Duration: 200ms

// IMAGE SECTION (height: 160):
// Container with gradient overlay (transparent→black 0.5)
// Background: heroGradient (placeholder until real images)
// Center: HugeIcon restaurant/food icon, white 0.45, size:52
//
// IMAGE BADGES (top-left, Row gap:5):
// BadgeChip "⚡ POS Live"  — bg:rgba(flame,0.85), white, 9px
// BadgeChip "🥬 PURE VEG" — bg:rgba(success,0.85), white, 9px  [if veg]
// BadgeChip "50% OFF"     — bg:rgba(mango,0.90), white, 9px    [if offer]
//
// RATING BADGE (bottom-left):
// Container bg:rgba(0,0,0,0.65), radius:7, padding:2×6
// Row [HugeIcon:strokeRoundedStar, filled gold, 9] [Text "4.8 (2.1k)" white 8px bold]
//
// TIME BADGE (bottom-right):
// Container bg:rgba(white,0.90), radius:7
// Row [HugeIcon:strokeRoundedClock01, txtSecondary, 9] [Text "30 min" 8px bold]
//
// BODY SECTION (padding: 10×12):
// Text: restaurant name — headlineSmall
// Text: cuisine types — bodySmall, txtMuted, marginTop:2
// Row (gap:10, marginTop:5):
// ├── Row [HugeIcon:strokeRoundedLocation01,txtMuted,10] [Text "2.3 km" bodySmall]
// ├── Text "·" txtMuted
// ├── Text "₹600 for two" bodySmall
// ├── Text "·" txtMuted  
// └── Text "POS Synced" bodySmall, flame, w700
// DietIcons row (marginTop:6)
```

---

## 4. SKELETON LOADING CARD

### File: `lib/widgets/skeleton_card.dart`

```dart
// Shimmer animation:
// Use shimmer package or custom AnimatedBuilder
// Colors: flame50 → flame100 → flame50
// Duration: 1500ms, repeat

// SKELETON CARD:
// Container (same dimensions as RestaurantCard)
// ├── Shimmer box: 160px height (image placeholder)
// └── Padding(10×12):
//     ├── Shimmer line: height:14, width:80%, radius:7, marginBottom:8
//     ├── Shimmer line: height:10, width:60%, radius:5, marginBottom:6
//     └── Row: shimmer line 40px + shimmer line 60px + shimmer line 50px
```

---

## 5. GRADIENT BUTTON (Primary CTA)

### File: `lib/widgets/gradient_button.dart`

```dart
// Full width, height: 52px
// Background: LinearGradient [#CC2D00 → #FF4500]
// BorderRadius: 12
// Elevation: 0 (flat)
// Shadow: 0 6px 20px rgba(255,69,0,0.35)
// 
// STATES:
// Default: gradient bg, white text
// Pressed: scale(0.97), opacity(0.90), duration:100ms
// Disabled: bg:flame100, text:white 0.60
// Loading: CircularProgressIndicator (white, size:20) replaces text

Widget build(BuildContext context) {
  return GestureDetector(
    onTapDown: (_) => setState(() => _pressed = true),
    onTapUp: (_) => setState(() => _pressed = false),
    child: AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: Duration(milliseconds: 100),
      child: Container(
        height: 52,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColors.ctaGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.flame.withOpacity(0.35),
              blurRadius: 20,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Center(child: _isLoading
          ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (leadingIcon != null) ...[
                  HugeIcon(icon: leadingIcon!, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                ],
                Text(label, style: AppTypography.ctaButton),
                if (trailingIcon != null) ...[
                  SizedBox(width: 8),
                  HugeIcon(icon: trailingIcon!, color: Colors.white, size: 18),
                ],
              ],
            ),
        ),
      ),
    ),
  );
}
```

---

## 6. FLOATING CART BAR

### File: `lib/widgets/floating_cart_bar.dart`

```dart
// POSITION: above floating navbar
// bottom: 80px, left: 16, right: 16
//
// ENTRANCE ANIMATION:
// SlideTransition: dy: 1.0→0.0 (400ms, easeOut)
// triggered when first item added to cart
//
// CONTAINER:
// bg: heroGradient
// borderRadius: 16
// padding: 14×18
// shadow: 0 8px 24px rgba(flame,0.40)
//
// LAYOUT: Row (spaceBetween)
// LEFT: Row
// ├── Container bg:rgba(white,0.20), radius:8, padding:4×10
// │   Text "{n} ITEMS" — 11px, white, bold
// └── Text "₹{total}" — 15px, white, bold, marginLeft:10
//
// RIGHT: Row
// ├── Text "View Cart" — 13px, white, bold
// └── HugeIcon:strokeRoundedArrowRight01, white, 16
//
// PRESS ANIMATION: scale(0.98), duration:100ms
// TAP: navigate to /cart
```

---

## 7. OFFER BANNER CARD

### File: `lib/widgets/offer_banner_card.dart`

```dart
// SIZE: 220×80
// borderRadius: 14
// overflow: hidden
//
// VARIANTS:
// 1. Primary: [#CC2D00 → #FF4500] — Welcome offers
// 2. Green:   [#1a3a1a → #16A34A] — Delivery offers
// 3. Red:     [#3a1a1a → #DC2626] — Hot deals
//
// DECORATIVE CIRCLE:
// position: top-right, size:80×80, bg:rgba(white,0.08), radius:50%
// offset: right:-20, top:-20
//
// CONTENT (padding:14×16):
// ├── Text: offer type tag — 9px, white 0.80, w700
// ├── Text: offer headline — 14px, white, w800
// └── Text: coupon code — 10px, white 0.75
//
// HOVER: scale(1.02), duration:200ms
```

---

## 8. CUISINE PILL

### File: `lib/widgets/cuisine_pill.dart`

```dart
// INACTIVE:
// bg: white, border: 1.5 flame100
// padding: 8×16, borderRadius: 20
// Row [HugeIcon relevant, flame2, 14] [Text label — 11px, flame2, w700]
//
// ACTIVE:
// bg: flame, border: flame
// icon: white, text: white
// transform: translateY(-1px)
// shadow: 0 4px 12px rgba(flame,0.30)
//
// ANIMATION: AnimatedContainer 200ms

// CUISINE MAPPING:
// All         → HugeIcons.strokeRoundedRestaurant01
// Gujarati    → HugeIcons.strokeRoundedPot
// Kathiyawadi → HugeIcons.strokeRoundedCookingPot
// Punjabi     → HugeIcons.strokeRoundedFoodNoodles
// Burgers     → HugeIcons.strokeRoundedBurger
// Pizzas      → HugeIcons.strokeRoundedPizza01
// South Indian→ HugeIcons.strokeRoundedLeaf01
```

---

## 9. VEG / NON-VEG DIET ICON

### File: `lib/widgets/diet_icon.dart`

```dart
// PURE VEG:
// Outer square: 14×14, border: 1.5 success (#16A34A), borderRadius: 3
// Inner circle: 7×7, filled success
//
// NON-VEG:
// Outer square: 14×14, border: 1.5 nonVeg (#DC2626), borderRadius: 3
// Inner circle: 7×7, filled nonVeg

Widget build(BuildContext context) {
  final color = isVeg ? AppColors.success : AppColors.nonVeg;
  return Container(
    width: 14, height: 14,
    decoration: BoxDecoration(
      border: Border.all(color: color, width: 1.5),
      borderRadius: BorderRadius.circular(3),
    ),
    child: Center(
      child: Container(
        width: 7, height: 7,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    ),
  );
}
```

---

## 10. POS LIVE INDICATOR

### File: `lib/widgets/pos_live_indicator.dart`

```dart
// BLINKING DOT:
// size: 6×6 or 8×8
// color: posLive (#4AFF91) for tracking, or success for menu
// animation: opacity 1.0↔0.25, duration:1500ms, repeat

// Container (bg:successBg, radius:9, padding:7×10)
// Row:
// ├── AnimatedDot (blinking)
// ├── SizedBox(7)
// ├── HugeIcon:strokeRoundedComputerDesk, success, 14
// └── Text "Direct POS Synchronized Kitchen" — 9px, success, w700
```

---

## 11. ETA RING TIMER

### File: `lib/widgets/eta_ring_timer.dart`

```dart
// SIZE: 160×160
// Uses CustomPainter for gradient ring
//
// LAYERS (Stack):
// 1. BACKGROUND RING: CustomPaint
//    circle stroke, color:flame100, width:10, full circle
//
// 2. PROGRESS RING: CustomPaint
//    gradient stroke (flame→mango) via shader
//    strokeWidth:10, strokeCap:round
//    startAngle: -π/2 (top)
//    sweepAngle: 2π × progress
//    Animation: Tween 0→progress, 1000ms, easeOut on mount
//    Countdown: update every second
//
// 3. PULSE RING (outer):
//    AnimationController repeat
//    scale: 1.0→1.06 (2s, easeInOut)
//    opacity: 0.5→0.0
//    Container: borderRadius:50%, border:2 rgba(flame,0.30)
//
// 4. CENTER CONTENT:
//    Column center:
//    ├── Text minutes — 32px, flame, w800
//    └── Text "minutes" — labelSmall, txtMuted

class ETARingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth / 2;

    // Background ring
    canvas.drawCircle(center, radius,
      Paint()..color = AppColors.flame100
             ..style = PaintingStyle.stroke
             ..strokeWidth = 10);

    // Gradient progress ring
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: -math.pi / 2 + 2 * math.pi * progress,
      colors: [AppColors.flame, AppColors.mango],
    );
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false,
      Paint()..shader = gradient.createShader(rect)
             ..style = PaintingStyle.stroke
             ..strokeWidth = 10
             ..strokeCap = StrokeCap.round);
  }
}
```

---

## 12. ANIMATED STEP INDICATOR

### File: `lib/widgets/step_indicator.dart`

```dart
// Used in: Order Tracking screen

// STEP CIRCLE (26×26):
// DONE:    bg:flame, border:flame, icon:checkmark white
//          entrance: ScaleTransition 0.6→1.15→1.0 (400ms, elasticOut)
// ACTIVE:  bg:flame50, border:2 flame, relevant icon flame
//          ongoing: pulsing glow (box-shadow 0→8px rgba(flame,0.4)→0, 2s repeat)
// PENDING: bg:transparent, border:2 flame100, relevant icon txtMuted

// CONNECTOR LINE (width:2, flex:1 height):
// DONE:    bg:flame, animated fill top→bottom (300ms delay after step)
// PENDING: bg:flame100

// LABEL:
// DONE/ACTIVE: flame, w800, 10px
// PENDING:     txtMuted, w700, 10px

// SUBLABEL (active only):
// 9px, txtMuted
// [step 2 active] shows live cooking timer "Cooking: 0:00"
```

---

## 13. COUPON DRAWER

### File: `lib/widgets/coupon_drawer.dart`

```dart
// showModalBottomSheet
// DraggableScrollableSheet initialSize:0.55, maxSize:0.80
// Container bg:white, radius: topLeft(20) topRight(20)
//
// HEADER:
// Row [HugeIcon:strokeRoundedDiscount01, flame, 20]
//     [Text "Apply Coupon" — headlineSmall]
//     [close button]
//
// AVAILABLE COUPONS LIST:
// ListView of CouponTile:
// Container margin:0×14×8, bg:white, border:1.5 dashed flame200, radius:12
// Row:
// ├── Container 44×44, radius:10, bg:flame50
// │   └── HugeIcon:strokeRoundedDiscount01, flame, 22
// ├── Column
// │   ├── Text coupon code — labelLarge, flame, letterSpacing:1
// │   └── Text description — bodySmall
// └── ElevatedButton "Apply" — compact
//
// AVAILABLE CODES:
// WELCOME100  → "₹100 off on first order"
// LIVERESTRO50 → "50% off up to ₹150"
// FREESHIP    → "Free delivery on this order"
```

---

## 14. ANIMATED LOCATION DOT

### File: `lib/widgets/animated_dot.dart`

```dart
// Used in: Top bar location pill, POS live indicator, tracking status
// 
// SIZE: 5×5 or 6×6 or 8×8 (configurable)
// ANIMATION: opacity 1.0↔0.25 or 1.0↔0.30
// Duration: 1500ms or 2000ms
// Repeat: forever, reverse

Widget build(BuildContext context) {
  return AnimatedBuilder(
    animation: _animation,
    builder: (_, __) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(_animation.value),
        shape: BoxShape.circle,
      ),
    ),
  );
}
```

---

## 15. QUANTITY CONTROLLER

### File: `lib/widgets/qty_controller.dart`

```dart
// Used in: Dish cards (ADD → − 1 +), Cart items
//
// ZERO STATE (ADD button):
// Container bg:flame, radius:7, padding:4×10
// Text "+ ADD" — 11px, white, bold
// onTap: animate to qty controller
//
// QTY CONTROLLER:
// Container bg:flame, radius:7, overflow:hidden
// Row:
// ├── IconButton (−): HugeIcon:strokeRoundedMinusSign, white, 14
// │   width:28, height:28, onTap: decrementQty
// ├── Text "{qty}" — 12px, white, w700, minWidth:18
// └── IconButton (+): HugeIcon:strokeRoundedPlusSign, white, 14
//     width:28, height:28, onTap: incrementQty
//
// TRANSITION (ADD→QTY):
// AnimatedSwitcher 250ms, ScaleTransition
//
// AUTO-REMOVE when qty reaches 0:
// AnimatedSwitcher back to ADD button
```
