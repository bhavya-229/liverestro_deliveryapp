import 'package:go_router/go_router.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/profile_setup_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/cart/screens/cart_screen.dart';
import '../../features/checkout/screens/payment_selection_screen.dart';
import '../../features/location/screens/location_picker_screen.dart';
import '../../features/order_tracking/screens/live_order_tracking_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/restaurant/screens/home_discovery_screen.dart';
import '../../features/restaurant/screens/restaurant_detail_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/profile-setup',
      builder: (context, state) => const ProfileSetupScreen(),
    ),
    GoRoute(
      path: '/location',
      builder: (context, state) => const LocationPickerScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeDiscoveryScreen(),
    ),
    GoRoute(
      path: '/restaurant/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? 'rest_chatkara';
        return RestaurantDetailScreen(restaurantId: id);
      },
    ),
    GoRoute(
      path: '/cart',
      builder: (context, state) => const CartScreen(),
    ),
    GoRoute(
      path: '/payment',
      builder: (context, state) => const PaymentSelectionScreen(),
    ),
    GoRoute(
      path: '/tracking/:orderId',
      builder: (context, state) {
        final orderId = state.pathParameters['orderId'] ?? 'LR-ORDER';
        return LiveOrderTrackingScreen(orderId: orderId);
      },
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);
