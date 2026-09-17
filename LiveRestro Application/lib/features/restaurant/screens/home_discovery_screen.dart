import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/animated_dot.dart';
import '../../../core/widgets/cuisine_pill.dart';
import '../../../core/widgets/diet_icon.dart';
import '../../../core/widgets/floating_cart_bar.dart';
import '../../../core/widgets/floating_nav_bar.dart';
import '../../../core/widgets/offer_banner_card.dart';
import '../../../core/widgets/story_bubble.dart';
import '../../../core/widgets/story_viewer.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../location/providers/location_provider.dart';
import '../providers/restaurant_provider.dart';
import 'widgets/restaurant_card.dart';

class HomeDiscoveryScreen extends ConsumerStatefulWidget {
  const HomeDiscoveryScreen({super.key});

  @override
  ConsumerState<HomeDiscoveryScreen> createState() => _HomeDiscoveryScreenState();
}

class _HomeDiscoveryScreenState extends ConsumerState<HomeDiscoveryScreen> {
  int _navIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  final List<String> _cuisines = const [
    'All',
    'Gujarati',
    'Kathiyawadi',
    'Punjabi',
    'Burgers',
    'Pizzas',
    'South Indian',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _openStory(int initialIndex) {
    final stories = [
      StoryViewerItem(
        restaurantName: 'Chatkara',
        chipLabel: "TODAY'S SPECIAL",
        title: 'Double Patty Smash Feast',
        subtitle: 'Loaded cheddar cheese & caramelized onions fresh from the kitchen grill.',
        ctaText: 'Order from Chatkara',
        onCta: () => context.push('/restaurant/rest_chatkara'),
      ),
      StoryViewerItem(
        restaurantName: 'Prajapati Bhakhri Shak',
        chipLabel: 'LOCAL FAVOURITE',
        title: 'Kathiyawadi Desi Ghee Bhakhri',
        subtitle: 'Smoky roasted Baingan Bharta (Ringna No Olo) with pure ghee bhakhri.',
        ctaText: 'Order Kathiyawadi',
        onCta: () => context.push('/restaurant/rest_prajapati'),
      ),
      StoryViewerItem(
        restaurantName: 'Maruti Nandan',
        chipLabel: "CHEF'S PICK",
        title: 'Special Gujarati Deluxe Thali',
        subtitle: '2 Shaks, 4 Phulka rotis, Dal/Kadhi, Farsan, Sweet, and Masala Chaas.',
        ctaText: 'Order Thali',
        onCta: () => context.push('/restaurant/rest_maruti'),
      ),
    ];

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) => StoryViewer(
          stories: stories,
          initialIndex: initialIndex,
        ),
        transitionsBuilder: (context, anim, secondaryAnim, child) => FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  void _onNavTap(int index) {
    setState(() => _navIndex = index);
    switch (index) {
      case 0:
        // Already on Home
        break;
      case 1:
        // Focus search
        _searchFocusNode.requestFocus();
        break;
      case 2:
        // Orders / Cart / Tracking
        final cart = ref.read(cartProvider);
        if (cart.items.isNotEmpty) {
          context.push('/cart');
        } else {
          context.push('/profile');
        }
        break;
      case 3:
        context.push('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locationState = ref.watch(locationProvider);
    final user = ref.watch(authProvider).user;
    final restaurants = ref.watch(restaurantListProvider);
    final selectedCuisine = ref.watch(selectedCategoryFilterProvider);
    final cartState = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.bgPage,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                // TOP BAR (Sticky)
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    color: isDark ? AppColors.darkBg : AppColors.bgPage,
                    child: Row(
                      children: [
                        // Logo
                        Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                gradient: AppColors.heroGradient,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: HugeIcon(
                                  icon: AppIcons.restaurant,
                                  color: Colors.white,
                                  size: 15,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'LiveRestro',
                              style: AppTypography.headlineSmall.copyWith(
                                color: AppColors.flame,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),

                        // Center: Location Pill
                        Expanded(
                          child: GestureDetector(
                            onTap: () => context.push('/location'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkCard : AppColors.flame50,
                                borderRadius: AppSpacing.pillRadius,
                                border: Border.all(
                                  color: isDark ? AppColors.darkBorder : AppColors.flame100,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const AnimatedDot(size: 6, color: AppColors.flame),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      locationState.activeAddress.fullAddress,
                                      style: AppTypography.labelSmall.copyWith(
                                        color: isDark ? AppColors.darkTxt : AppColors.flame,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 10,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  const HugeIcon(
                                    icon: AppIcons.chevronDown,
                                    color: AppColors.flame,
                                    size: 12,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Theme Toggle
                        IconButton(
                          icon: HugeIcon(
                            icon: isDark ? AppIcons.lightMode : AppIcons.darkMode,
                            color: isDark ? AppColors.mango : AppColors.flame,
                            size: 20,
                          ),
                          onPressed: () {
                            ref.read(themeModeProvider.notifier).toggleTheme();
                          },
                        ),

                        // Avatar
                        GestureDetector(
                          onTap: () => context.push('/profile'),
                          child: CircleAvatar(
                            radius: 17,
                            backgroundColor: AppColors.flame,
                            child: Text(
                              (user?.name.isNotEmpty ?? false) ? user!.name[0].toUpperCase() : 'U',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // SEARCH BAR
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.flame100,
                        width: 1.5,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      onChanged: (val) {
                        ref.read(restaurantSearchQueryProvider.notifier).state = val;
                      },
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDark ? AppColors.darkTxt : AppColors.txtPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search restaurants, dishes, cuisines…',
                        prefixIcon: const Padding(
                          padding: EdgeInsets.all(12),
                          child: HugeIcon(
                            icon: AppIcons.search,
                            color: AppColors.txtMuted,
                            size: 18,
                          ),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        fillColor: Colors.transparent,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),
                ),

                // PURE VEG TOGGLE ROW
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const DietIcon(isVeg: true, size: 14),
                            const SizedBox(width: 8),
                            Text(
                              'Pure Veg Mode',
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        CupertinoSwitch(
                          value: user?.isVegOnly ?? false,
                          activeTrackColor: AppColors.success,
                          onChanged: (val) {
                            ref.read(authProvider.notifier).toggleVegPreference(val);
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // OFFER BANNERS
                SliverToBoxAdapter(
                  child: Container(
                    height: 88,
                    margin: const EdgeInsets.only(top: 8, bottom: 12),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        OfferBannerCard(
                          tag: 'Welcome Deal',
                          headline: 'Flat ₹100 OFF on 1st Order',
                          couponCode: 'Use code: WELCOME100',
                          variant: OfferBannerVariant.flame,
                          onTap: () => context.push('/cart'),
                        ),
                        const SizedBox(width: 12),
                        OfferBannerCard(
                          tag: 'Free Shipping',
                          headline: 'Zero Delivery Fee Today',
                          couponCode: 'Use code: FREESHIP',
                          variant: OfferBannerVariant.green,
                          onTap: () => context.push('/cart'),
                        ),
                        const SizedBox(width: 12),
                        OfferBannerCard(
                          tag: 'Mega Feast',
                          headline: '50% OFF Up to ₹150',
                          couponCode: 'Use code: LIVERESTRO50',
                          variant: OfferBannerVariant.red,
                          onTap: () => context.push('/cart'),
                        ),
                      ],
                    ),
                  ),
                ),

                // RESTAURANT STORIES
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Text(
                          'Restaurant Stories',
                          style: AppTypography.labelLarge.copyWith(
                            color: isDark ? AppColors.darkTxt : AppColors.txtPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 94,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            StoryBubble(
                              label: 'Chatkara',
                              onTap: () => _openStory(0),
                              count: 2,
                            ),
                            const SizedBox(width: 10),
                            StoryBubble(
                              label: 'Prajapati',
                              onTap: () => _openStory(1),
                              count: 1,
                            ),
                            const SizedBox(width: 10),
                            StoryBubble(
                              label: 'Maruti Nandan',
                              onTap: () => _openStory(2),
                              count: 3,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // CUISINE FILTER PILLS
                SliverToBoxAdapter(
                  child: Container(
                    height: 44,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _cuisines.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (ctx, idx) {
                        final cat = _cuisines[idx];
                        final isSelected = selectedCuisine == cat;
                        return CuisinePill(
                          label: cat,
                          isSelected: isSelected,
                          onTap: () {
                            ref.read(selectedCategoryFilterProvider.notifier).state = cat;
                          },
                        );
                      },
                    ),
                  ),
                ),

                // SECTION HEADER
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'All Restaurants',
                          style: AppTypography.headlineSmall.copyWith(
                            color: isDark ? AppColors.darkTxt : AppColors.txtPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '${restaurants.length} nearby',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.flame,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // RESTAURANTS LIST
                if (restaurants.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Column(
                          children: [
                            const HugeIcon(
                              icon: AppIcons.restaurant,
                              color: AppColors.txtMuted,
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No partner restaurants found',
                              style: AppTypography.headlineSmall.copyWith(
                                color: isDark ? AppColors.darkTxt : AppColors.txtPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Try clearing filters or changing search query',
                              style: AppTypography.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                    sliver: SliverList.builder(
                      itemCount: restaurants.length,
                      itemBuilder: (ctx, idx) {
                        return RestaurantCard(restaurant: restaurants[idx]);
                      },
                    ),
                  ),
              ],
            ),

            // FLOATING CART BAR (if cart is not empty)
            if (cartState.items.isNotEmpty)
              FloatingCartBar(
                itemCount: cartState.totalItemCount,
                totalAmount: cartState.finalAmount.toInt(),
                onTap: () => context.push('/cart'),
              ),

            // FLOATING GLASSMORPHISM NAV BAR
            FloatingNavBar(
              currentIndex: _navIndex,
              onTap: _onNavTap,
            ),
          ],
        ),
      ),
    );
  }
}
