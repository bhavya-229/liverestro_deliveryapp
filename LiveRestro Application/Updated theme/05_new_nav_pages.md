# LiveRestro — New Nav Pages Specifications
## Search · Orders · Profile

---

## SCREEN 12 — Search Page

### Route: `/search`
### File: `lib/screens/search/search_screen.dart`
### Trigger: Tap bottom nav index 1 OR tap search bar on Home screen

```
KEY BEHAVIOR:
- TextField autofocuses on page enter → keyboard opens immediately
- Live filtering on every keystroke (no submit button needed)
- Shows 3 states: Default (recent + categories), Results, Empty
- Back button → pop to previous screen (Home)
```

### Widget Tree

```
Scaffold (bg: bgPage, resizeToAvoidBottomInset: true)
└── Column
    ├── HEADER (bg: bgPage, padding: 12×12)
    │   ├── BACK ROW
    │   │   └── Row (gap: 8, marginBottom: 10)
    │   │       ├── BackButton
    │   │       │   Container 30×30, bg:flame50, radius:50%
    │   │       │   border:1.5 flame100
    │   │       │   HugeIcon:strokeRoundedArrowLeft01, flame, 15
    │   │       │   onTap: Navigator.pop(context)
    │   │       └── Text "Search" — headlineSmall
    │   │
    │   └── SEARCH INPUT
    │       Container bg:white, border:2 flame, radius:12
    │       [focused] border:flame, shadow: 0 0 0 3px rgba(flame,0.12)
    │       Row:
    │       ├── Padding(left:12) HugeIcon:strokeRoundedSearch01, flame, 17
    │       ├── Expanded → TextField
    │       │   autofocus: true
    │       │   hint: "Dish, restaurant, cuisine…"
    │       │   hintStyle: bodyMedium, txtMuted
    │       │   onChanged: _onSearchChanged
    │       │   controller: _searchController
    │       │   textInputAction: TextInputAction.search
    │       └── [if query not empty] ClearButton
    │           Container 22×22, bg:flame100, radius:50%
    │           HugeIcon:strokeRoundedCancel01, flame, 12
    │           onTap: _clearSearch()
    │
    └── Expanded → AnimatedSwitcher (300ms, fade)
        ├── [query empty]    DefaultSearchState
        ├── [has results]    SearchResultsState
        └── [no results]     EmptySearchState
```

### State A — Default (query is empty)

```
SingleChildScrollView → Column
├── RECENT SEARCHES SECTION
│   ├── Padding(12×12) Row
│   │   ├── HugeIcon:strokeRoundedClock01, flame, 14
│   │   └── Text "Recent searches" — labelMedium
│   └── Padding(0×12) Wrap (spacing:6, runSpacing:6)
│       └── RecentChip × n
│           GestureDetector onTap: fillSearch(label)
│           Container bg:white, border:1.5 flame100, radius:18, padding:5×10
│           Row [HugeIcon:strokeRoundedClock01, txtMuted, 12] [Text label — labelSmall, txt2]
│           Chips: "Paneer Tikka", "Agashiye", "Burger", "Gujarati Thali"
│           onTap: set controller.text = label, trigger search
│
├── BROWSE BY CATEGORY SECTION (marginTop: 14)
│   ├── Padding(12×12) Row
│   │   ├── HugeIcon:strokeRoundedCategory01, flame, 14
│   │   └── Text "Browse by category" — labelMedium
│   └── SizedBox(height:70)
│       └── ListView.builder (horizontal, padding:12 h)
│           itemExtent: 58
│           └── CategoryIconTile
│               Column (center, gap:4)
│               ├── Container 46×46, radius:12
│               │   active: bg:flame, border:flame
│               │   inactive: bg:white, border:1.5 flame100
│               │   HugeIcon: relevant icon, active:white, inactive:flame, size:22
│               └── Text label — 8px, txt2, w700
│
│   Categories:
│   All         → HugeIcons.strokeRoundedRestaurant01
│   Non-Veg     → HugeIcons.strokeRoundedMeat01
│   Pure Veg    → HugeIcons.strokeRoundedLeaf01
│   Burgers     → HugeIcons.strokeRoundedBurger01
│   Pizzas      → HugeIcons.strokeRoundedPizza01
│   Thali       → HugeIcons.strokeRoundedFoodNoodles
│   Beverages   → HugeIcons.strokeRoundedCoffee01
│
└── TRENDING NEAR YOU SECTION (marginTop: 14)
    ├── Padding(12×12) Row
    │   ├── HugeIcon:strokeRoundedTrendingUp, flame, 14
    │   └── Text "Trending near you" — labelMedium
    └── List of SearchResultItem (top 4 trending, non-interactive header)
```

### State B — Results (query has text, results found)

```
Column
├── Result count header
│   Padding(6×12) Text "{n} results for "{query}"" — bodySmall, txtMuted
│
└── ListView.builder (items: filteredList)
    └── SearchResultItem
        GestureDetector → navigate to restaurant or dish
        Container (borderBottom: 1 flame50, padding: 10×12)
        Row:
        ├── ICON CONTAINER (40×40, radius:11)
        │   Restaurant: heroGradient bg, HugeIcon white
        │   Dish:       flame50 bg, border:1.5 flame100, HugeIcon flame
        │
        ├── SizedBox(10)
        │
        ├── Expanded → Column (crossAxis: start)
        │   ├── RichText: name with HIGHLIGHTED match
        │   │   matched portion: bg:flame50, color:flame, fontWeight:700
        │   │   rest: normal bodySmall
        │   └── Row (gap:4, marginTop:2)
        │       ├── [restaurant] HugeIcon:strokeRoundedStore, txtMuted, 10
        │       ├── [dish] HugeIcon:strokeRoundedRestaurant01, txtMuted, 10
        │       └── Text: subtitle — 9px, txtMuted
        │
        └── Column (crossAxis: end, gap: 3)
            ├── Text: price — priceTagSmall
            └── Row [HugeIcon:strokeRoundedClock01, txtMuted, 9] [Text time — 8px, txtMuted]
```

### State C — Empty (query has text, no results)

```
Center → Column (center)
├── SizedBox(height: 40)
├── HugeIcon:strokeRoundedSearchMinus, flame100, 52
├── SizedBox(height: 14)
├── Text "No results found" — headlineSmall, txtPrimary
├── SizedBox(height: 6)
├── Text "Try "{query}" with different spelling" — bodySmall, txtMuted, center
├── SizedBox(height: 20)
└── OutlinedButton "Clear search"
    border: flame, color: flame
    onTap: _clearSearch()
```

### Search Logic

```dart
// lib/screens/search/search_screen.dart

class SearchScreen extends ConsumerStatefulWidget { ... }

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _ctrl = TextEditingController();
  String _query = '';

  void _onChanged(String val) {
    setState(() => _query = val.trim().toLowerCase());
  }

  void _clear() {
    _ctrl.clear();
    setState(() => _query = '');
  }

  List<SearchResult> get _results {
    if (_query.isEmpty) return [];
    return allSearchableItems.where((item) =>
      item.name.toLowerCase().contains(_query) ||
      item.subtitle.toLowerCase().contains(_query) ||
      item.tags.any((t) => t.toLowerCase().contains(_query))
    ).toList();
  }
}

// SearchResult model:
class SearchResult {
  final String id;
  final SearchResultType type; // restaurant | dish
  final String name;
  final String subtitle;
  final String price;
  final String deliveryTime;
  final List<String> tags;
  final String? restaurantId;   // for dishes, parent restaurant
}

enum SearchResultType { restaurant, dish }
```

---

## SCREEN 13 — Orders Page

### Route: `/orders`
### File: `lib/screens/orders/orders_screen.dart`
### Trigger: Tap bottom nav index 2

```
KEY BEHAVIOR:
- Shows LIVE ORDER BANNER at top if there's an active order
- Filter tabs: All | Active | Delivered | Cancelled
- Past orders sorted newest first
- Each card: Reorder + Rate actions
- Cancelled orders show refund amount in green
- Empty state when no orders exist
```

### Widget Tree

```
Scaffold (bg: bgPage)
└── Column
    ├── GRADIENT HERO HEADER
    │   Container bg:heroGradient, padding:14×12 16bottom
    │   Row:
    │   ├── BackButton (circle rgba white 0.20) → Navigator.pop
    │   └── Column (crossAxis: start)
    │       ├── Text "Your Orders" — headlineMedium, white
    │       └── Text "Track live, reorder, rate your meals" — bodySmall, white 0.75
    │
    ├── FILTER TABS ROW
    │   SizedBox(height:42)
    │   └── ListView.builder (horizontal, padding:10 h, gap:5)
    │       └── FilterChip
    │           active: bg:flame, white text, border:flame
    │           inactive: bg:white, txt2 text, border:flame100
    │           Labels: "All orders" | "Active" | "Delivered" | "Cancelled"
    │           onTap: setState filter + re-filter list
    │
    └── Expanded → SingleChildScrollView → Column
        │
        ├── [if hasActiveOrder] LIVE ORDER BANNER
        │   Container margin:10×12, bg:heroGradient, radius:13, padding:12×14
        │   Row:
        │   ├── Column (flex:1)
        │   │   ├── LIVE LABEL Row
        │   │   │   [AnimatedDot green 5px] [HugeIcon:strokeRoundedRadio, white, 12]
        │   │   │   [Text "LIVE ORDER" — 9px, white 0.80, w700, letterSpacing:0.5]
        │   │   ├── Text: restaurantName — headlineSmall, white
        │   │   └── Row [HugeIcon:strokeRoundedCookingPot, white, 11]
        │   │         [Text "Food being prepared · ETA 18 min" — 9px, white 0.80]
        │   └── GestureDetector → context.push('/tracking/{orderId}')
        │       Container bg:rgba(white,0.22), border:1 rgba(white,0.35)
        │       radius:9, padding:7×11
        │       Row [HugeIcon:strokeRoundedLocation01, white, 11] [Text "Track" — 9px, white, w800]
        │
        ├── [if pastOrders not empty] SECTION HEADER
        │   Padding(12×12) Text "Past orders" — headlineSmall
        │
        ├── [if pastOrders not empty] ORDER CARDS LIST
        │   Column (padding:0×12, gap:8)
        │   └── OrderCard × n (see below)
        │
        └── [if filtered list empty] EMPTY STATE
            Center → Column
            ├── HugeIcon:strokeRoundedShoppingBag01, flame100, 52
            ├── Text "No orders here" — headlineSmall
            └── Text "Your [filter] orders will show up here" — bodySmall, txtMuted
```

### Order Card Widget

```
// File: lib/widgets/order_card.dart

Container (bg:white, border:1.5 flame100, radius:12, padding:11×13)
│
├── TOP ROW (spaceBetween, crossAxis:start, marginBottom:8)
│   ├── Column (crossAxis:start)
│   │   ├── Text: restaurantName — labelLarge
│   │   └── Row (marginTop:2)
│   │       [HugeIcon:strokeRoundedCalendar01, txtMuted, 10]
│   │       [Text: "Yesterday · 12:15 PM" — 8px, txtMuted]
│   └── STATUS BADGE
│       Container radius:5, padding:2×7
│       Row [HugeIcon relevant, 10] [Text status — 8px, w700]
│
│       DELIVERED: bg:successBg, color:success
│                  icon: HugeIcons.strokeRoundedCheckmarkCircle01
│       CANCELLED:  bg:nonVegBg, color:nonVeg
│                  icon: HugeIcons.strokeRoundedCancel01
│       ACTIVE:    bg:flame50, color:flame
│                  icon: HugeIcons.strokeRoundedRadio
│
├── ITEMS TEXT
│   Text: "Item1 × qty · Item2 × qty · ..." — 9px, txtSecondary
│   maxLines: 2, overflow: ellipsis
│   marginBottom: 8
│
└── BOTTOM ROW (spaceBetween, crossAxis:center)
    ├── Column (crossAxis:start)
    │   ├── Text "Order total" OR "Refunded" — 8px, txtMuted
    │   └── Text "₹{amount}" — priceTagSmall
    │         cancelled/refunded: color:success
    │
    └── ACTION BUTTONS ROW (gap:5)
        [DELIVERED]:
        ├── SecondaryBtn "Rate"
        │   bg:flame50, border:1.5 flame100, color:flame
        │   HugeIcon:strokeRoundedStar, flame, 12
        └── PrimaryBtn "Reorder"
            bg:ctaGradient, color:white
            HugeIcon:strokeRoundedRefresh, white, 12

        [CANCELLED]:
        └── PrimaryBtn "Reorder"

        [ACTIVE]:
        └── PrimaryBtn "Track Live →"
            onTap: context.push('/tracking/{orderId}')
```

### Order Filter Logic

```dart
// lib/screens/orders/orders_screen.dart

enum OrderFilter { all, active, delivered, cancelled }

List<Order> get filteredOrders {
  switch (_activeFilter) {
    case OrderFilter.all:
      return _orders;
    case OrderFilter.active:
      return _orders.where((o) =>
        o.status != OrderStatus.delivered &&
        o.status != OrderStatus.cancelled
      ).toList();
    case OrderFilter.delivered:
      return _orders.where((o) => o.status == OrderStatus.delivered).toList();
    case OrderFilter.cancelled:
      return _orders.where((o) => o.status == OrderStatus.cancelled).toList();
  }
}

Order? get activeOrder => _orders.firstWhereOrNull((o) =>
  o.status != OrderStatus.delivered &&
  o.status != OrderStatus.cancelled
);

// Show live banner only when activeOrder != null
// Live banner is always at top regardless of filter selection
```

---

## SCREEN 11 (UPDATED) — Profile Page

### Route: `/profile`
### File: `lib/screens/profile/profile_screen.dart`
### Changes from v1: Removed order history section. Added stats row. Added more account rows.

```
Scaffold (bg: bgPage)
└── SingleChildScrollView → Column
    │
    ├── GRADIENT HERO
    │   Container bg:heroGradient, padding:20×14 24bottom, textAlign:center
    │   Stack:
    │   ├── EDIT BUTTON (position: topRight 12,12)
    │   │   Container 30×30, bg:rgba(white,0.22), radius:50%
    │   │   HugeIcon:strokeRoundedEdit01, white, 14
    │   │   onTap: navigate to edit profile sheet
    │   │
    │   └── Column (center)
    │       ├── CircleAvatar
    │       │   size:60, bg:rgba(white,0.22), border:2 rgba(white,0.40)
    │       │   Text: initials — 18px, white, w800
    │       │
    │       ├── SizedBox(8)
    │       ├── Text: fullName — headlineMedium, white
    │       ├── Text: "+91 XXXXX · email" — bodySmall, white 0.75, marginTop:2
    │       │
    │       └── BADGES ROW (gap:6, marginTop:8)
    │           ├── Badge [HugeIcon:strokeRoundedLeaf01] "Pure Veg"
    │           └── Badge [HugeIcon:strokeRoundedShieldTick] "Verified"
    │           Badge: bg:rgba(white,0.18), border:1 rgba(white,0.30)
    │                  radius:10, padding:3×10, 8px white w700
    │
    ├── STATS ROW (margin:10×12, gap:8)
    │   └── Row → 3 × StatCard
    │       Container flex:1, bg:white, border:1.5 flame100, radius:12, padding:10×8
    │       textAlign:center
    │       ├── Text: value — 16px, flame, w800
    │       └── Text: label — 8px, txtMuted, marginTop:2
    │
    │       Stats:
    │       ├── "{orderCount}"  — "Orders"
    │       ├── "₹{totalSpent}" — "Spent"
    │       └── "{addressCount}" — "Addresses"
    │
    ├── PREFERENCES SECTION (padding:12×12 0)
    │   ├── SectionLabel "PREFERENCES"
    │   └── SettingsCard
    │       ├── ProfileRow "Pure Veg Mode"
    │       │   icon: HugeIcons.strokeRoundedLeaf01
    │       │   trailing: CupertinoSwitch (activeColor:success)
    │       │
    │       ├── ProfileRow "Dark Mode"
    │       │   icon: HugeIcons.strokeRoundedMoon02
    │       │   trailing: CupertinoSwitch (activeColor:flame)
    │       │
    │       └── ProfileRow "Notifications"
    │           icon: HugeIcons.strokeRoundedNotification01
    │           trailing: CupertinoSwitch (activeColor:flame)
    │
    ├── ACCOUNT SECTION (padding:0×12)
    │   ├── SectionLabel "ACCOUNT"
    │   └── SettingsCard
    │       ├── ProfileRow "Saved addresses"
    │       │   icon: HugeIcons.strokeRoundedMapsPin01
    │       │   trailing: "{n} saved ›"
    │       │   onTap: push /addresses
    │       │
    │       ├── ProfileRow "Payment methods"
    │       │   icon: HugeIcons.strokeRoundedCreditCard
    │       │   trailing: "GPay ›"
    │       │   onTap: push /payment-methods
    │       │
    │       ├── ProfileRow "Refer & earn"
    │       │   icon: HugeIcons.strokeRoundedGift
    │       │   trailing: "₹100 each ›" (color:flame, w700)
    │       │   onTap: push /refer
    │       │
    │       └── ProfileRow "Help & support"
    │           icon: HugeIcons.strokeRoundedCustomerSupport
    │           trailing: "›"
    │           onTap: push /support
    │
    ├── APP INFO SECTION (padding:0×12)
    │   ├── SectionLabel "APP INFO"
    │   └── SettingsCard
    │       ├── ProfileRow "App version"
    │       │   icon: HugeIcons.strokeRoundedInformationCircle
    │       │   trailing: "v1.0.0" (static, no chevron)
    │       │
    │       └── ProfileRow "Terms & privacy"
    │           icon: HugeIcons.strokeRoundedFileText
    │           trailing: "›"
    │           onTap: launch URL
    │
    └── LOGOUT ROW (margin:0×12 16bottom)
        Container bg:white, border:1.5 nonVegBg, radius:13, padding:13
        Row (center) [HugeIcon:strokeRoundedLogout01, nonVeg, 17]
                     [Text "Log out" — labelLarge, nonVeg]
        onTap: showLogoutConfirmDialog()
```

### Profile Row Widget

```dart
// File: lib/widgets/profile_row.dart

Widget build(BuildContext context) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.flame50, width: 1)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: AppColors.flame50,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Center(
              child: HugeIcon(icon: icon, color: AppColors.flame, size: 16),
            ),
          ),
          SizedBox(width: 11),
          // Label
          Expanded(
            child: Text(label, style: AppTypography.labelLarge),
          ),
          // Trailing
          if (trailing != null) trailing!,
          if (trailingText != null)
            Text(trailingText!, style: AppTypography.bodySmall.copyWith(
              color: trailingColor ?? AppColors.txtMuted,
              fontWeight: trailingBold ? FontWeight.w700 : FontWeight.w400,
            )),
        ],
      ),
    ),
  );
}
```

### Section Label Widget

```dart
// Padding: 12 top, 12 horizontal, 7 bottom
// Text: label — 9px, txtMuted, w700, letterSpacing: 0.5
// Example: "PREFERENCES", "ACCOUNT", "APP INFO"

Widget _sectionLabel(String label) => Padding(
  padding: EdgeInsets.fromLTRB(12, 12, 12, 7),
  child: Text(
    label,
    style: TextStyle(
      fontSize: 9,
      fontWeight: FontWeight.w700,
      color: AppColors.txtMuted,
      letterSpacing: 0.5,
      fontFamily: AppTypography.fontFamily,
    ),
  ),
);
```

---

## UPDATED NAVIGATION SPEC

### Floating Nav Bar — Active State per Screen

```dart
// lib/widgets/floating_nav_bar.dart

// Pass currentIndex to highlight correct tab

// /home     → currentIndex: 0
// /search   → currentIndex: 1
// /orders   → currentIndex: 2
// /profile  → currentIndex: 3

// Also highlight when on sub-routes:
// /restaurant/:id → currentIndex: 0 (home)
// /cart           → currentIndex: 2 (orders)
// /tracking/:id   → currentIndex: 2 (orders)
// /payment        → currentIndex: 2 (orders)

int _getNavIndex(String location) {
  if (location.startsWith('/search'))   return 1;
  if (location.startsWith('/orders'))   return 2;
  if (location.startsWith('/cart'))     return 2;
  if (location.startsWith('/tracking')) return 2;
  if (location.startsWith('/payment'))  return 2;
  if (location.startsWith('/profile'))  return 3;
  return 0; // home, restaurant, etc.
}
```

### Nav Tap Handlers

```dart
void _onNavTap(int index, BuildContext context) {
  switch (index) {
    case 0: context.go('/home');    break;
    case 1: context.push('/search'); break; // push so back returns to home
    case 2: context.go('/orders');   break;
    case 3: context.go('/profile');  break;
  }
}
```

### Home Screen — Search Bar (READ ONLY tap target)

```dart
// lib/screens/home/home_screen.dart
// The search bar on home is NOT a real input field

GestureDetector(
  onTap: () => context.push('/search'),
  child: AbsorbPointer( // prevent keyboard from opening
    child: Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.flame100, width: 1.5),
      ),
      child: Row(
        children: [
          HugeIcon(icon: AppIcons.search, color: AppColors.txtMuted, size: 16),
          SizedBox(width: 8),
          Text(
            'Search restaurants, dishes, cuisines…',
            style: AppTypography.bodySmall.copyWith(color: AppColors.txtMuted),
          ),
        ],
      ),
    ),
  ),
)
```

---

## UPDATED ROUTE TABLE

```dart
// lib/router/app_router.dart — COMPLETE v2

final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash',        builder: (_, __) => SplashScreen()),
    GoRoute(path: '/login',         builder: (_, __) => LoginScreen()),
    GoRoute(path: '/profile-setup', builder: (_, __) => ProfileSetupScreen()),
    GoRoute(path: '/location',      builder: (_, __) => LocationScreen()),

    ShellRoute(
      builder: (_, __, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/home',        builder: (_, __) => HomeScreen()),
        GoRoute(path: '/search',      builder: (_, __) => SearchScreen()),    // NEW
        GoRoute(path: '/orders',      builder: (_, __) => OrdersScreen()),    // NEW
        GoRoute(path: '/profile',     builder: (_, __) => ProfileScreen()),   // UPDATED

        GoRoute(
          path: '/restaurant/:id',
          builder: (_, state) => RestaurantScreen(
            restaurantId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(path: '/cart',        builder: (_, __) => CartScreen()),
        GoRoute(path: '/payment',     builder: (_, __) => PaymentScreen()),
        GoRoute(
          path: '/tracking/:orderId',
          builder: (_, state) => TrackingScreen(
            orderId: state.pathParameters['orderId']!,
          ),
        ),
      ],
    ),
  ],
);
```

---

## UPDATED FOLDER STRUCTURE (additions only)

```
lib/
├── screens/
│   ├── search/
│   │   └── search_screen.dart          ← NEW
│   ├── orders/
│   │   └── orders_screen.dart          ← NEW
│   └── profile/
│       └── profile_screen.dart         ← UPDATED (simplified)
│
└── widgets/
    ├── order_card.dart                 ← NEW
    ├── profile_row.dart                ← NEW
    └── search_result_item.dart         ← NEW
```

---

## DUMMY DATA ADDITIONS

```dart
// Dummy orders for Orders screen

final List<Order> dummyOrders = [
  // ACTIVE ORDER (shows in live banner)
  Order(
    id: 'ORD_001',
    restaurantId: '1',
    restaurantName: 'Agashiye — The House of MG',
    items: [...],
    totalAmount: 940,
    paymentMethod: 'Google Pay',
    placedAt: DateTime.now().subtract(Duration(minutes: 12)),
    status: OrderStatus.preparing,
    etaMinutes: 18,
    rider: RiderInfo(
      name: 'Ramesh Kumar',
      vehicleNumber: 'GJ-01 AB 2345',
      vehicleModel: 'Honda Activa',
      rating: 4.9,
      phoneNumber: '+91 98765 12345',
    ),
  ),

  // DELIVERED
  Order(
    id: 'ORD_002',
    restaurantId: '3',
    restaurantName: 'Green House Café',
    totalAmount: 420,
    status: OrderStatus.delivered,
    placedAt: DateTime.now().subtract(Duration(days: 1, hours: 12)),
  ),

  // DELIVERED
  Order(
    id: 'ORD_003',
    restaurantId: '4',
    restaurantName: 'Burger Singh',
    totalAmount: 680,
    status: OrderStatus.delivered,
    placedAt: DateTime.now().subtract(Duration(days: 3, hours: 4)),
  ),

  // CANCELLED
  Order(
    id: 'ORD_004',
    restaurantId: '5',
    restaurantName: "La Pino'z Pizza",
    totalAmount: 399,
    status: OrderStatus.cancelled,
    placedAt: DateTime.now().subtract(Duration(days: 5, hours: 10)),
    refundAmount: 399,
  ),
];

// Dummy profile stats
const int dummyOrderCount   = 12;
const String dummyTotalSpent = '₹6.2k';
const int dummyAddressCount  = 3;
```
