import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/floating_cart_bar.dart';
import '../../../core/widgets/pos_live_indicator.dart';
import '../../cart/providers/cart_provider.dart';
import '../providers/restaurant_provider.dart';
import 'widgets/menu_item_card.dart';

class RestaurantDetailScreen extends ConsumerStatefulWidget {
  final String restaurantId;

  const RestaurantDetailScreen({super.key, required this.restaurantId});

  @override
  ConsumerState<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends ConsumerState<RestaurantDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<String> _categories;

  @override
  void initState() {
    super.initState();
    final restaurant = ref.read(restaurantDetailProvider(widget.restaurantId));
    _categories = ['All', ...(restaurant?.categories ?? [])];
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final restaurant = ref.watch(restaurantDetailProvider(widget.restaurantId));
    final cartState = ref.watch(cartProvider);

    if (restaurant == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Restaurant')),
        body: const Center(child: Text('Restaurant not found')),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.bgPage,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // SLIVER APP BAR
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                elevation: 0,
                backgroundColor: AppColors.flameDark,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.22),
                      ),
                      child: const Center(
                        child: HugeIcon(
                          icon: AppIcons.back,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          gradient: AppColors.heroGradient,
                        ),
                      ),
                      Positioned(
                        right: 20,
                        top: 40,
                        child: Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: HugeIcon(
                              icon: AppIcons.restaurant,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 46,
                        left: 16,
                        right: 70,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              restaurant.name,
                              style: AppTypography.headlineMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              restaurant.cuisines.join(' · '),
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const HugeIcon(
                                  icon: AppIcons.star,
                                  color: AppColors.warning,
                                  size: 13,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${restaurant.rating} (${restaurant.ratingCount})',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text('·', style: TextStyle(color: Colors.white70)),
                                const SizedBox(width: 8),
                                Text(
                                  '${restaurant.deliveryTimeMinutes} min',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(38),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: isDark ? AppColors.darkCard : AppColors.successBg,
                    child: const Row(
                      children: [
                        POSLiveIndicator(
                          text: 'Direct POS Synchronized Kitchen — live order sync',
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // CATEGORY TABS (Pinned header)
              SliverPersistentHeader(
                pinned: true,
                delegate: _CategoryTabHeaderDelegate(
                  child: Container(
                    height: 44,
                    color: isDark ? AppColors.darkCard : Colors.white,
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      indicatorColor: AppColors.flame,
                      indicatorWeight: 2.5,
                      labelColor: AppColors.flame,
                      unselectedLabelColor: AppColors.txtMuted,
                      labelStyle: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w800),
                      unselectedLabelStyle: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
                      tabAlignment: TabAlignment.start,
                      tabs: _categories.map((c) => Tab(text: c)).toList(),
                    ),
                  ),
                ),
              ),

              // MENU ITEMS
              Builder(
                builder: (context) {
                  final activeCategory = _categories[_tabController.index];
                  final items = activeCategory == 'All'
                      ? restaurant.menuItems
                      : restaurant.menuItems.where((i) {
                          return i.category.trim().toLowerCase() == activeCategory.trim().toLowerCase();
                        }).toList();

                  if (items.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const HugeIcon(
                                icon: AppIcons.pot,
                                color: AppColors.txtMuted,
                                size: 36,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No items in "$activeCategory"',
                                style: AppTypography.headlineSmall.copyWith(
                                  color: AppColors.txtSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Explore other categories or check back soon.',
                                style: AppTypography.bodySmall.copyWith(color: AppColors.txtMuted),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                    sliver: SliverList.builder(
                      itemCount: items.length,
                      itemBuilder: (ctx, idx) {
                        return MenuItemCard(
                          item: items[idx],
                          restaurant: restaurant,
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),

          // FLOATING CART BAR
          if (cartState.items.isNotEmpty)
            FloatingCartBar(
              itemCount: cartState.totalItemCount,
              totalAmount: cartState.finalAmount.toInt(),
              onTap: () => context.push('/cart'),
            ),
        ],
      ),
    );
  }
}

class _CategoryTabHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _CategoryTabHeaderDelegate({required this.child});

  @override
  double get minExtent => 44.0;
  @override
  double get maxExtent => 44.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;

  @override
  bool shouldRebuild(covariant _CategoryTabHeaderDelegate oldDelegate) => true;
}
