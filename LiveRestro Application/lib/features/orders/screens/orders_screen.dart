import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/animated_dot.dart';
import '../../../core/widgets/floating_nav_bar.dart';
import '../../cart/providers/cart_provider.dart';
import '../../order_tracking/models/order_model.dart';
import '../../order_tracking/providers/order_tracking_provider.dart';
import '../widgets/order_card.dart';

enum OrderFilterTab { all, active, delivered, cancelled }

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  OrderFilterTab _activeTab = OrderFilterTab.all;

  void _onNavTap(int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.push('/search');
        break;
      case 2:
        // Already on Orders
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  void _onReorder(OrderModel order) {
    final cartNotifier = ref.read(cartProvider.notifier);
    cartNotifier.clearCart();
    for (final item in order.items) {
      cartNotifier.addItem(item);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Items from ${order.restaurantName} added to cart!'),
        backgroundColor: AppColors.flame,
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Colors.white,
          onPressed: () => context.push('/cart'),
        ),
      ),
    );
  }

  void _onRate(OrderModel order) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        int selectedRating = 5;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.flame100,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Rate your meal from ${order.restaurantName}',
                    style: AppTypography.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starIndex = index + 1;
                      return IconButton(
                        icon: HugeIcon(
                          icon: AppIcons.star,
                          color: starIndex <= selectedRating
                              ? AppColors.warning
                              : AppColors.flame100,
                          size: 32,
                        ),
                        onPressed: () {
                          setSheetState(() => selectedRating = starIndex);
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Thank you for rating your order!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.flame,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('Submit Review'),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allOrders = ref.watch(orderTrackingProvider);

    // Active order check (first non-delivered & non-cancelled)
    OrderModel? activeOrder;
    for (final o in allOrders) {
      if (o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled) {
        activeOrder = o;
        break;
      }
    }

    // Filtered orders
    final List<OrderModel> filteredOrders;
    switch (_activeTab) {
      case OrderFilterTab.all:
        filteredOrders = allOrders;
        break;
      case OrderFilterTab.active:
        filteredOrders = allOrders.where((o) =>
            o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled).toList();
        break;
      case OrderFilterTab.delivered:
        filteredOrders = allOrders.where((o) => o.status == OrderStatus.delivered).toList();
        break;
      case OrderFilterTab.cancelled:
        filteredOrders = allOrders.where((o) => o.status == OrderStatus.cancelled).toList();
        break;
    }

    // Past orders (excluding currently active order if it is being displayed in the hero banner)
    final pastOrders = _activeTab == OrderFilterTab.all
        ? filteredOrders.where((o) => o.orderId != activeOrder?.orderId).toList()
        : filteredOrders;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.bgPage,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // GRADIENT HERO HEADER
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                  decoration: const BoxDecoration(
                    gradient: AppColors.heroGradient,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/home');
                          }
                        },
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.20),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: HugeIcon(
                              icon: AppIcons.back,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Orders',
                            style: AppTypography.headlineMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Track live, reorder, rate your meals',
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // FILTER TABS ROW
                Container(
                  color: isDark ? AppColors.darkBg : AppColors.bgPage,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  height: 54,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    children: [
                      _buildFilterChip('All orders', OrderFilterTab.all, isDark),
                      const SizedBox(width: 8),
                      _buildFilterChip('Active', OrderFilterTab.active, isDark),
                      const SizedBox(width: 8),
                      _buildFilterChip('Delivered', OrderFilterTab.delivered, isDark),
                      const SizedBox(width: 8),
                      _buildFilterChip('Cancelled', OrderFilterTab.cancelled, isDark),
                    ],
                  ),
                ),

                // SCROLLABLE LIST OF ORDERS
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 90),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // LIVE ORDER BANNER (if active order exists)
                        if (activeOrder != null) ...[
                          Container(
                            margin: const EdgeInsets.fromLTRB(14, 4, 14, 12),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: AppColors.heroGradient,
                              borderRadius: BorderRadius.circular(13),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.flame.withValues(alpha: 0.28),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // LIVE LABEL ROW
                                      Row(
                                        children: [
                                          const AnimatedDot(size: 6, color: AppColors.posLive),
                                          const SizedBox(width: 6),
                                          const HugeIcon(
                                            icon: AppIcons.radio,
                                            color: Colors.white,
                                            size: 13,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            'LIVE ORDER',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white.withValues(alpha: 0.90),
                                              letterSpacing: 0.6,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        activeOrder.restaurantName,
                                        style: AppTypography.headlineSmall.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        children: [
                                          const HugeIcon(
                                            icon: AppIcons.pot,
                                            color: Colors.white,
                                            size: 12,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            'Food being prepared · ETA ${activeOrder.etaMinutes} min',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.white.withValues(alpha: 0.85),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () => context.push('/tracking/${activeOrder!.orderId}'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.22),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.35),
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(9),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        HugeIcon(
                                          icon: AppIcons.location,
                                          color: Colors.white,
                                          size: 12,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Track',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // SECTION HEADER (Past Orders)
                        if (pastOrders.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
                            child: Text(
                              _activeTab == OrderFilterTab.all ? 'Past orders' : '${_tabName(_activeTab)} orders',
                              style: AppTypography.headlineSmall.copyWith(
                                color: isDark ? AppColors.darkTxt : AppColors.txtPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Column(
                              children: pastOrders.map((o) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: OrderCard(
                                    order: o,
                                    onTrack: () => context.push('/tracking/${o.orderId}'),
                                    onReorder: () => _onReorder(o),
                                    onRate: () => _onRate(o),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ] else if (activeOrder == null || _activeTab != OrderFilterTab.all) ...[
                          // EMPTY STATE
                          _buildEmptyState(isDark),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // FLOATING GLASSMORPHISM NAV BAR
            FloatingNavBar(
              currentIndex: 2,
              onTap: _onNavTap,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, OrderFilterTab tab, bool isDark) {
    final isActive = _activeTab == tab;

    return GestureDetector(
      onTap: () => setState(() => _activeTab = tab),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.flame
              : (isDark ? AppColors.darkCard : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? AppColors.flame
                : (isDark ? AppColors.darkBorder : AppColors.flame100),
            width: 1.5,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.flame.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isActive
                  ? Colors.white
                  : (isDark ? AppColors.darkTxt2 : AppColors.txtSecondary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.flame50,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: HugeIcon(
                  icon: AppIcons.orders,
                  color: AppColors.flame200,
                  size: 46,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'No orders here',
              style: AppTypography.headlineSmall.copyWith(
                color: isDark ? AppColors.darkTxt : AppColors.txtPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Your ${_tabName(_activeTab).toLowerCase()} orders will show up here',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.txtMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _tabName(OrderFilterTab tab) {
    switch (tab) {
      case OrderFilterTab.all:
        return 'All';
      case OrderFilterTab.active:
        return 'Active';
      case OrderFilterTab.delivered:
        return 'Delivered';
      case OrderFilterTab.cancelled:
        return 'Cancelled';
    }
  }
}
