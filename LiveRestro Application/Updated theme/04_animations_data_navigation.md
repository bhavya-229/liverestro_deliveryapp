# LiveRestro — Animations, Data Models & Navigation
## Flutter Implementation Reference

---

## 1. MICRO-ANIMATION CATALOGUE

### Global Animation Durations
```dart
class AppAnimations {
  static const Duration ultraFast = Duration(milliseconds: 100);
  static const Duration fast      = Duration(milliseconds: 200);
  static const Duration medium    = Duration(milliseconds: 350);
  static const Duration slow      = Duration(milliseconds: 500);
  static const Duration verySlow  = Duration(milliseconds: 800);
  static const Duration splash    = Duration(milliseconds: 2500);

  static const Curve standard  = Curves.easeInOut;
  static const Curve enter     = Curves.easeOut;
  static const Curve exit      = Curves.easeIn;
  static const Curve spring    = Curves.elasticOut;
  static const Curve bounce    = Curves.bounceOut;
}
```

### Animation Inventory — Screen by Screen

```
SPLASH SCREEN
├── Logo container   : ScaleTransition 0.4→1.0 (800ms, elasticOut)
├── App name         : FadeTransition (delay:300ms, 600ms, easeOut)
├── Tagline pill     : FadeTransition (delay:600ms, 500ms, easeOut)
└── Spinner          : RotationTransition continuous (1000ms/turn)

LOGIN SCREEN
├── Hero slide down  : SlideTransition dy:-0.1→0 (400ms, easeOut)
├── OTP boxes        : Stagger FadeIn+ScaleIn each box (delay: n×50ms)
├── Active OTP box   : border-color flash + mild scale(1.04)
└── CTA button press : ScaleTransition 1.0→0.97 (100ms)

HOME SCREEN
├── Restaurant cards : Stagger SlideUp+FadeIn (delay: n×80ms, 400ms each)
├── Location dot     : Opacity pulse 1.0↔0.3 (2000ms, repeat)
├── Story rings      : ScaleTransition 1.0→1.07 on tap (150ms)
├── Cuisine pills    : ScaleUp + translateY(-1px) on select (200ms)
├── Cart bar enter   : SlideUp dy:1.0→0 (400ms, easeOut) when first item added
├── Card hover       : translateY(0→-3px), shadow increase (200ms)
└── Skeleton loading : Shimmer left→right sweep (1500ms, repeat)

MENU SCREEN
├── Hero parallax    : image scale on scroll (subtle 1.0→1.1)
├── ADD button       : ScaleIn on appear, ScaleOut on remove (250ms, spring)
├── ADD→QTY          : AnimatedSwitcher cross-fade (250ms)
├── QTY change       : Counter AnimatedSwitcher slide up/down
└── Category tab     : Indicator slide + color transition → accent (200ms)

CART SCREEN
├── Item removal     : SlideOut + FadeOut left (300ms)
├── Quantity change  : Counter number slide animation
├── Bill recalc      : Text AnimatedSwitcher fade (150ms)
├── Coupon applied   : Green success animation (scale + checkmark draw)
└── Tip chip select  : Color transition + scale(1.05) (200ms)

PAYMENT SCREEN
├── Option select    : Border color + bg transition (150ms)
├── Radio fill       : Scale 0→1 with accent color (200ms, spring)
└── CTA press        : Scale 1.0→0.97 (100ms)

TRACKING SCREEN
├── ETA ring mount   : Animated arc from 0→progress (1000ms, easeOut)
├── ETA ring update  : Smooth arc progress (real-time countdown)
├── Pulse outer ring : Scale 1.0→1.06, opacity 0.5→0 (2000ms, repeat)
├── Live dot         : Opacity 1.0↔0.25 (1200ms, repeat)
├── Step completion  : StepCircle scale 0.6→1.15→1.0 (400ms, elasticOut)
├── Connector fill   : Height animate 0→full (300ms, easeOut, after step)
├── Active step glow : BoxShadow pulse 0→8px→0 (2000ms, repeat)
└── Milestone nodes  : Same as step completion, staggered

PROFILE SCREEN
├── Hero mount       : FadeIn + slight scale (500ms)
└── Order card       : Stagger FadeIn (delay: n×60ms)
```

### Emerald Accent Micro-Interactions (NEW — v3)

The plum theme is intentionally calm and monochromatic; these interactions are
where the new emerald `accent` color earns its keep. Rule of thumb: accent
animates only on moments the user caused (a tap, a completed action) or an
in-progress state they should keep an eye on — never as passive decoration.

```
ADD TO CART (Menu screen)
├── Fly-to-cart      : Small dish-icon ghost flies from ADD button to the
│                      cart bar (Bezier path, 350ms, easeInOut), fades out
│                      on arrival
├── Cart badge bump  : Count badge scales 1.0→1.3→1.0 (250ms, elasticOut)
│                      in accent, at the moment the ghost icon lands
└── Count roll       : New quantity digit slides up while old slides out
                       (180ms) — replaces a hard cut

CTA SUCCESS STATE (GradientButton, any screen)
├── Content morph    : Label/spinner cross-fades to a check icon
│                      (AnimatedSwitcher, 200ms)
├── Button pulse     : Scale 1.0→1.04→1.0 (300ms, easeOutBack)
└── Haptic           : HapticFeedback.lightImpact() on every press,
                       .mediumImpact() on the success transition

ACTIVE NAV TAB (Floating nav bar)
├── Pill fill        : AnimatedContainer plum→accent background (200ms)
├── Icon bounce-in   : Scale 0.8→1.0 (250ms, elasticOut) on becoming active
└── Live-order dot   : If an order is in flight, Orders tab shows a 6px
                       accent dot, opacity/scale pulse 1.0↔0.4 (1400ms, loop)

PRICE / BILL UPDATES (Cart, Menu)
├── Price count-up   : Digits animate via TweenAnimationBuilder when the
│                      bill recalculates (250ms, easeOut) instead of a
│                      hard text swap
└── Coupon success   : Chip flashes accentBg→transparent (400ms), small
                       checkmark draws in accent (SVG path animation, 300ms)

RATING STARS (Restaurant card, Reviews)
└── Sequential fill  : Each star scale-bounces in, staggered 60ms apart,
                       on first appearance only (not on re-scroll)

TOASTS / SNACKBARS (Global)
├── Enter            : Slide up + fade (250ms, easeOut)
├── Exit             : Slide down + fade (200ms, easeIn) after 2500ms
└── Success variant  : 3px accent left-border stripe + check icon
```

---

## 2. PAGE TRANSITIONS

```dart
// lib/router/app_router.dart

// Default: Slide from right (standard push)
class SlideRightRoute extends PageRouteBuilder {
  SlideRightRoute({required Widget page})
    : super(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
            child: child,
          );
        },
        transitionDuration: Duration(milliseconds: 300),
      );
}

// Bottom sheet routes (Cart, Customization): slide from bottom
// Story viewer: fade + slide from right
// Splash→Login: fade only (no slide)
```

---

## 3. DATA MODELS

### Restaurant Model
```dart
// lib/models/restaurant.dart

class Restaurant {
  final String id;
  final String name;
  final String cuisineTypes;       // "Gujarati Thali · Kathiyawadi"
  final double rating;
  final String reviewCount;        // "2.1k"
  final int deliveryMinutes;       // 30
  final String distanceKm;         // "2.3 km"
  final String priceForTwo;        // "₹600 for two"
  final bool isVeg;
  final bool isPosLive;
  final String? offerText;         // "20% OFF up to ₹120"
  final String? offerBadge;        // "BESTSELLER"
  final String cuisineCategory;    // for filter pills
  final List<StoryItem> stories;
  final List<MenuCategory> menu;
  final String imageUrl;
}

class StoryItem {
  final String chipLabel;       // "TODAY'S SPECIAL"
  final String title;           // "Royal Gujarati Feast"
  final String subtitle;        // description
  final String ctaText;         // "Order Now"
  final String postedTime;      // "2h ago"
  final StoryType type;         // offer | newDish
}

enum StoryType { offer, newDish }
```

### Menu Models
```dart
// lib/models/menu.dart

class MenuCategory {
  final String id;
  final String name;             // "Starters"
  final List<DishItem> items;
}

class DishItem {
  final String id;
  final String name;
  final int price;
  final String description;
  final bool isVeg;
  final bool isBestseller;
  final bool isCustomizable;
  final String? imageUrl;
  final List<DishVariant>? variants;
  final List<DishExtra>? extras;
}

class DishVariant {
  final String id;
  final String label;            // "Regular" / "Double"
  final int extraPrice;          // 0 for base variant
}

class DishExtra {
  final String id;
  final String label;            // "Extra Cheese"
  final int price;               // 25
}
```

### Cart Models
```dart
// lib/models/cart.dart

class CartItem {
  final DishItem dish;
  int quantity;
  DishVariant? selectedVariant;
  List<DishExtra> selectedExtras;
  String? cookingInstructions;

  int get totalPrice {
    final base = dish.price;
    final variantExtra = selectedVariant?.extraPrice ?? 0;
    final extrasTotal = selectedExtras.fold(0, (sum, e) => sum + e.price);
    return (base + variantExtra + extrasTotal) * quantity;
  }
}

class Cart {
  String? restaurantId;
  String? restaurantName;
  List<CartItem> items = [];
  String? appliedCoupon;
  int couponDiscount = 0;
  int tipAmount = 0;
  String? selectedPaymentMethod;

  int get itemTotal => items.fold(0, (sum, i) => sum + i.totalPrice);
  int get platformFee => 5;
  int get gst => (itemTotal * 0.05).round();
  int get total => itemTotal + platformFee + gst - couponDiscount + tipAmount;
}
```

### Order Models
```dart
// lib/models/order.dart

class Order {
  final String id;
  final String restaurantId;
  final String restaurantName;
  final List<CartItem> items;
  final int totalAmount;
  final String paymentMethod;
  final DateTime placedAt;
  OrderStatus status;
  RiderInfo? rider;
  int etaMinutes;
}

enum OrderStatus {
  placed,      // Step 1
  preparing,   // Step 2
  ready,       // Step 3
  outForDelivery, // Step 4
  delivered,   // Step 5
}

class RiderInfo {
  final String name;
  final String vehicleNumber;
  final String vehicleModel;
  final double rating;
  final String phoneNumber;
}
```

### User Model
```dart
// lib/models/user.dart

class UserProfile {
  final String id;
  final String fullName;
  final String phone;
  final String? email;
  bool isPureVegMode;
  bool isDarkMode;
  List<SavedAddress> savedAddresses;
  List<Order> orderHistory;
}

class SavedAddress {
  final String type;             // "Home" / "Work" / "Other"
  final String fullAddress;
  final String? landmark;
  final double lat;
  final double lng;
}
```

---

## 4. STATE MANAGEMENT

```dart
// Recommended: Riverpod (or Provider / BLoC)

// lib/providers/

// cart_provider.dart
final cartProvider = StateNotifierProvider<CartNotifier, Cart>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<Cart> {
  CartNotifier() : super(Cart());

  void addItem(DishItem dish, {DishVariant? variant, List<DishExtra>? extras}) {
    // Check same restaurant
    // Add or increment
    // Update state
  }

  void removeItem(String dishId) { ... }
  void updateQuantity(String dishId, int qty) { ... }
  void applyCoupon(String code) { ... }
  void setTip(int amount) { ... }
  void clearCart() { ... }
}

// restaurant_provider.dart
final restaurantsProvider = FutureProvider<List<Restaurant>>((ref) async {
  return await RestaurantService.fetchNearby(
    lat: ref.watch(locationProvider).lat,
    lng: ref.watch(locationProvider).lng,
  );
});

// filter_provider.dart
final vegFilterProvider = StateProvider<bool>((ref) => false);
final cuisineFilterProvider = StateProvider<String>((ref) => 'All');
final searchQueryProvider = StateProvider<String>((ref) => '');

// filtered restaurants
final filteredRestaurantsProvider = Provider<List<Restaurant>>((ref) {
  final all = ref.watch(restaurantsProvider).value ?? [];
  final vegOnly = ref.watch(vegFilterProvider);
  final cuisine = ref.watch(cuisineFilterProvider);
  final query = ref.watch(searchQueryProvider);

  return all.where((r) {
    if (vegOnly && !r.isVeg) return false;
    if (cuisine != 'All' && r.cuisineCategory != cuisine) return false;
    if (query.isNotEmpty &&
        !r.name.toLowerCase().contains(query.toLowerCase()) &&
        !r.cuisineTypes.toLowerCase().contains(query.toLowerCase())) return false;
    return true;
  }).toList();
});

// order_tracking_provider.dart
final trackingProvider = StreamProvider.family<Order, String>((ref, orderId) {
  return OrderTrackingService.trackOrder(orderId);
  // Simulated: update status every N seconds
  // Production: WebSocket / FCM push updates
});
```

---

## 5. NAVIGATION / ROUTING

```dart
// lib/router/app_router.dart
// Using go_router package

final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash',       builder: (_, __) => SplashScreen()),
    GoRoute(path: '/login',        builder: (_, __) => LoginScreen()),
    GoRoute(path: '/profile-setup',builder: (_, __) => ProfileSetupScreen()),
    GoRoute(path: '/location',     builder: (_, __) => LocationScreen()),
    ShellRoute(
      builder: (_, __, child) => HomeShell(child: child),
      routes: [
        GoRoute(path: '/home',     builder: (_, __) => HomeScreen()),
        GoRoute(
          path: '/restaurant/:id',
          builder: (_, state) => RestaurantScreen(
            restaurantId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(path: '/cart',     builder: (_, __) => CartScreen()),
        GoRoute(path: '/payment',  builder: (_, __) => PaymentScreen()),
        GoRoute(
          path: '/tracking/:orderId',
          builder: (_, state) => TrackingScreen(
            orderId: state.pathParameters['orderId']!,
          ),
        ),
        GoRoute(path: '/profile',  builder: (_, __) => ProfileScreen()),
      ],
    ),
  ],
);

// BOTTOM NAV MAPPING:
// Index 0 → /home
// Index 1 → /home (open search focused)
// Index 2 → /cart or /tracking/:latest (if active order)
// Index 3 → /profile
```

---

## 6. PACKAGES & DEPENDENCIES

```yaml
# pubspec.yaml

dependencies:
  flutter:
    sdk: flutter

  # ICONS
  hugeicons: ^0.0.7

  # FONTS
  google_fonts: ^6.1.0         # OR bundle Plus Jakarta Sans locally

  # STATE MANAGEMENT
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3

  # NAVIGATION
  go_router: ^13.2.0

  # NETWORK
  dio: ^5.4.0
  cached_network_image: ^3.3.1

  # STORAGE
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0

  # AUTH
  firebase_auth: ^4.17.8       # if using Firebase OTP
  firebase_core: ^2.27.0

  # MAPS (future - currently using animated placeholder)
  # google_maps_flutter: ^2.5.3

  # ANIMATIONS
  shimmer: ^3.0.0
  lottie: ^3.1.0               # for advanced animations

  # UI UTILITIES
  flutter_svg: ^2.0.9
  url_launcher: ^6.2.4          # rider call button
  sms_autofill: ^2.3.0          # OTP autofill

  # LOCATION
  geolocator: ^11.0.0
  geocoding: ^3.0.0

  # PAYMENTS
  razorpay_flutter: ^1.3.6

  # MISC
  intl: ^0.19.0                 # date/number formatting
  uuid: ^4.3.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  riverpod_generator: ^2.3.9
  build_runner: ^2.4.8
  flutter_lints: ^3.0.0
```

---

## 7. PROJECT FOLDER STRUCTURE

```
lib/
├── main.dart
├── app.dart                      # MaterialApp + theme + router
│
├── theme/
│   ├── app_colors.dart
│   ├── app_typography.dart
│   ├── app_spacing.dart
│   ├── app_icons.dart
│   └── app_theme.dart
│
├── router/
│   └── app_router.dart
│
├── models/
│   ├── restaurant.dart
│   ├── menu.dart
│   ├── cart.dart
│   ├── order.dart
│   └── user.dart
│
├── providers/
│   ├── cart_provider.dart
│   ├── restaurant_provider.dart
│   ├── filter_provider.dart
│   ├── order_tracking_provider.dart
│   ├── user_provider.dart
│   └── theme_provider.dart
│
├── services/
│   ├── auth_service.dart
│   ├── restaurant_service.dart
│   ├── order_service.dart
│   ├── payment_service.dart
│   └── location_service.dart
│
├── screens/
│   ├── splash/
│   │   └── splash_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── profile_setup_screen.dart
│   ├── location/
│   │   └── location_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── restaurant/
│   │   ├── restaurant_screen.dart
│   │   └── customization_sheet.dart
│   ├── cart/
│   │   └── cart_screen.dart
│   ├── payment/
│   │   └── payment_screen.dart
│   ├── tracking/
│   │   └── tracking_screen.dart
│   └── profile/
│       └── profile_screen.dart
│
└── widgets/
    ├── floating_nav_bar.dart
    ├── floating_cart_bar.dart
    ├── gradient_button.dart
    ├── restaurant_card.dart
    ├── skeleton_card.dart
    ├── story_bubble.dart
    ├── story_viewer.dart
    ├── offer_banner_card.dart
    ├── cuisine_pill.dart
    ├── diet_icon.dart
    ├── qty_controller.dart
    ├── pos_live_indicator.dart
    ├── eta_ring_timer.dart
    ├── step_indicator.dart
    ├── animated_dot.dart
    └── coupon_drawer.dart

assets/
├── fonts/
│   ├── PlusJakartaSans-Regular.ttf
│   ├── PlusJakartaSans-Medium.ttf
│   ├── PlusJakartaSans-SemiBold.ttf
│   ├── PlusJakartaSans-Bold.ttf
│   └── PlusJakartaSans-ExtraBold.ttf
├── images/
│   └── flag_india.png
└── lottie/
    ├── cooking.json
    └── delivered.json
```

---

## 8. DUMMY DATA (Ahmedabad Restaurants)

```dart
// lib/services/dummy_data.dart

final List<Restaurant> dummyRestaurants = [
  Restaurant(
    id: '1',
    name: 'Agashiye — The House of MG',
    cuisineTypes: 'Gujarati Thali · Kathiyawadi',
    rating: 4.8,
    reviewCount: '2.1k',
    deliveryMinutes: 30,
    distanceKm: '2.3 km',
    priceForTwo: '₹600 for two',
    isVeg: true,
    isPosLive: true,
    offerText: '20% OFF up to ₹120',
    cuisineCategory: 'Gujarati',
  ),
  Restaurant(
    id: '2',
    name: 'Honest Restaurant',
    cuisineTypes: 'Punjabi · Mughlai · Tandoor',
    rating: 4.6,
    reviewCount: '1.8k',
    deliveryMinutes: 25,
    distanceKm: '1.9 km',
    priceForTwo: '₹450 for two',
    isVeg: false,
    isPosLive: true,
    offerText: '50% OFF up to ₹100',
    cuisineCategory: 'Punjabi',
  ),
  Restaurant(
    id: '3',
    name: 'Green House Café',
    cuisineTypes: 'South Indian · Healthy · Bowls',
    rating: 4.5,
    reviewCount: '940',
    deliveryMinutes: 20,
    distanceKm: '1.1 km',
    priceForTwo: '₹280 for two',
    isVeg: true,
    isPosLive: true,
    offerText: 'FREESHIP today',
    cuisineCategory: 'South Indian',
  ),
  Restaurant(
    id: '4',
    name: 'Burger Singh',
    cuisineTypes: 'Burgers · Wraps · Shakes',
    rating: 4.3,
    reviewCount: '1.2k',
    deliveryMinutes: 22,
    distanceKm: '2.7 km',
    priceForTwo: '₹350 for two',
    isVeg: false,
    isPosLive: true,
    offerText: 'BUY 2 GET 1 FREE',
    cuisineCategory: 'Burgers',
  ),
  Restaurant(
    id: '5',
    name: "La Pino'z Pizza",
    cuisineTypes: 'Pizzas · Pastas · Garlic Bread',
    rating: 4.4,
    reviewCount: '1.5k',
    deliveryMinutes: 28,
    distanceKm: '3.2 km',
    priceForTwo: '₹400 for two',
    isVeg: false,
    isPosLive: true,
    offerText: 'PIZZA MANIA ₹99',
    cuisineCategory: 'Pizzas',
  ),
  Restaurant(
    id: '6',
    name: 'Kathiyawadi Kitchen',
    cuisineTypes: 'Kathiyawadi · Rajasthani · Dhaba',
    rating: 4.7,
    reviewCount: '1.1k',
    deliveryMinutes: 35,
    distanceKm: '4.0 km',
    priceForTwo: '₹320 for two',
    isVeg: true,
    isPosLive: true,
    offerText: 'PURE VEG',
    offerBadge: 'LOCAL FAVOURITE',
    cuisineCategory: 'Kathiyawadi',
  ),
];

// DUMMY COUPON CODES:
// WELCOME100   → type:percent, value:100, minOrder:199, maxDiscount:100
// LIVERESTRO50 → type:percent, value:50,  minOrder:299, maxDiscount:150
// FREESHIP     → type:delivery, value:0 (free delivery)

// DUMMY RIDER:
// name: "Ramesh Kumar"
// vehicle: "GJ-01 AB 2345 · Honda Activa"
// rating: 4.9
// phone: "+91 98765 12345"
```

---

## 9. KEY IMPLEMENTATION NOTES FOR FLUTTER DEV

```
1. HUGEICONS USAGE:
   Always use HugeIcon widget (not Icon)
   Always use strokeRounded variant
   Standard size: 20-24 for nav, 16-18 for inline, 14 for dense UI

2. GLASSMORPHISM NAV:
   Use BackdropFilter + ImageFilter.blur(sigmaX:20, sigmaY:20)
   Wrap in ClipRRect for proper clipping
   iOS: works natively | Android: ensure compileSdkVersion >= 31

3. GRADIENT BUTTONS:
   Never use ElevatedButton for primary CTAs — use custom GradientButton widget
   Always apply shadow: 0 6px 20px rgba(FF4500, 0.35)

4. STORY VIEWER:
   Use PageView for swipe between stories
   Implement TapDetector for left/right zones
   Progress bar animation via AnimationController + Tween

5. SKELETON LOADING:
   Show skeleton for minimum 1800ms OR until data loads, whichever is longer
   Use shimmer package with customColor: flame50/flame100

6. FONTS:
   Download Plus Jakarta Sans from Google Fonts
   Bundle locally in assets/fonts/ for offline reliability
   Set fontFamily globally in ThemeData

7. CART PERSISTENCE:
   Save cart to SharedPreferences on every change
   Restore cart on app cold start

8. DARK MODE:
   Listen to system theme + user override
   Store preference in SharedPreferences
   Use Theme.of(context).colorScheme for all colors

9. SAFE AREA:
   Always wrap screens in SafeArea
   FloatingNavBar: add MediaQuery.of(context).padding.bottom to bottom:16

10. TOUCH TARGETS:
    All tappable elements minimum 48×48px (use SizedBox or padding to enforce)
    This is especially critical for quantity +/- buttons
```
