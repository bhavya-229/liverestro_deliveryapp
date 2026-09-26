import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liverestro/features/cart/models/cart_item_model.dart';
import 'package:liverestro/features/cart/providers/cart_provider.dart';
import 'package:liverestro/features/restaurant/data/mock_restaurants.dart';
import 'package:liverestro/features/restaurant/screens/home_discovery_screen.dart';
import 'package:liverestro/features/orders/screens/orders_screen.dart';
import 'package:liverestro/features/profile/screens/profile_screen.dart';
import 'package:liverestro/features/search/screens/search_screen.dart';

void main() {
  group('LiveRestro Cart & Promo Business Logic Tests', () {
    test('Calculates cart item totals, delivery fees, and 5% GST properly', () {
      final container = ProviderContainer();
      final cartNotifier = container.read(cartProvider.notifier);

      final restaurant = MockRestaurants.list.first;
      final item1 = restaurant.menuItems.first;

      cartNotifier.addItem(
        CartItemModel(
          menuItem: item1,
          restaurantId: restaurant.id,
          restaurantName: restaurant.name,
          quantity: 2,
        ),
      );

      final state = container.read(cartProvider);
      expect(state.totalItemCount, 2);
      expect(state.itemTotal, item1.price * 2);
      expect(state.taxesAndGst, (item1.price * 2) * 0.05);
      expect(state.finalAmount, greaterThan(0));
    });

    test('Applies WELCOME100 coupon and enforces discount ceiling', () {
      final container = ProviderContainer();
      final cartNotifier = container.read(cartProvider.notifier);

      final restaurant = MockRestaurants.list.first;
      final item = restaurant.menuItems.first;

      cartNotifier.addItem(
        CartItemModel(
          menuItem: item,
          restaurantId: restaurant.id,
          restaurantName: restaurant.name,
          quantity: 2,
        ),
      );

      final welcomePromo = CartNotifier.availablePromos.firstWhere((p) => p.code == 'WELCOME100');
      cartNotifier.applyPromo(welcomePromo);

      final state = container.read(cartProvider);
      expect(state.appliedPromo?.code, 'WELCOME100');
      expect(state.discountAmount, lessThanOrEqualTo(100));
    });
  });

  group('LiveRestro UI Widget Tests', () {
    testWidgets('Renders HomeDiscoveryScreen with search shortcut and categories', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomeDiscoveryScreen(),
          ),
        ),
      );

      expect(find.byType(HomeDiscoveryScreen), findsOneWidget);
      expect(find.text('Search restaurants, dishes, cuisines…'), findsOneWidget);
      expect(find.text('Burgers'), findsWidgets);
      expect(find.text('Chatkara'), findsWidgets);
    });

    testWidgets('Renders SearchScreen with active search TextField and categories', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SearchScreen(),
          ),
        ),
      );

      expect(find.byType(SearchScreen), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Recent searches'), findsOneWidget);
      expect(find.text('Browse by category'), findsOneWidget);
    });

    testWidgets('Renders OrdersScreen with filter tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OrdersScreen(),
          ),
        ),
      );

      expect(find.byType(OrdersScreen), findsOneWidget);
      expect(find.text('Your Orders'), findsOneWidget);
      expect(find.text('All orders'), findsOneWidget);
      expect(find.text('Delivered'), findsWidgets);
    });

    testWidgets('Renders ProfileScreen with user details and stats', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );

      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(find.text('Orders'), findsWidgets);
      expect(find.text('Spent'), findsOneWidget);
      expect(find.text('Addresses'), findsOneWidget);
      expect(find.text('PREFERENCES'), findsOneWidget);
    });
  });
}
