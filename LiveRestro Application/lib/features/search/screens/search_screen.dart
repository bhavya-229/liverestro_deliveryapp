import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/floating_nav_bar.dart';
import '../../restaurant/data/mock_restaurants.dart';
import '../models/search_result.dart';
import '../widgets/search_result_item.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _query = '';
  String _selectedCategory = 'All';

  final List<String> _recentSearches = const [
    'Paneer Tikka',
    'Agashiye',
    'Burger',
    'Gujarati Thali',
  ];

  late final List<SearchResult> _allSearchableItems;

  @override
  void initState() {
    super.initState();
    _buildSearchableIndex();
  }

  void _buildSearchableIndex() {
    final List<SearchResult> items = [];
    final restaurants = MockRestaurants.list;

    for (final r in restaurants) {
      // Add restaurant
      items.add(
        SearchResult(
          id: r.id,
          type: SearchResultType.restaurant,
          name: r.name,
          subtitle: '${r.cuisines.join(" · ")} · ${r.distanceKm} km',
          price: '₹${r.priceForTwo} for 2',
          deliveryTime: '${r.deliveryTimeMinutes} min',
          tags: [...r.cuisines, r.name, r.tagline, if (r.isPureVeg) 'Pure Veg'],
        ),
      );

      // Add dishes
      for (final dish in r.menuItems) {
        items.add(
          SearchResult(
            id: dish.id,
            type: SearchResultType.dish,
            name: dish.name,
            subtitle: '${r.name} · ${dish.category}',
            price: '₹${dish.price.toInt()}',
            deliveryTime: '${r.deliveryTimeMinutes} min',
            tags: [
              dish.name,
              dish.category,
              r.name,
              if (dish.isVeg) 'Pure Veg' else 'Non-Veg',
              if (dish.isBestseller) 'Bestseller',
            ],
            restaurantId: r.id,
          ),
        );
      }
    }

    _allSearchableItems = items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    setState(() {
      _query = val.trim();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _query = '';
      _selectedCategory = 'All';
    });
  }

  void _selectRecentChip(String text) {
    _searchController.text = text;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: text.length),
    );
    setState(() {
      _query = text.trim();
    });
  }

  void _onSelectCategory(String cat) {
    setState(() {
      _selectedCategory = cat;
      if (cat == 'All') {
        _query = '';
        _searchController.clear();
      } else {
        _query = cat;
        _searchController.text = cat;
      }
    });
  }

  List<SearchResult> get _filteredResults {
    if (_query.isEmpty) return [];
    final lowerQ = _query.toLowerCase();
    return _allSearchableItems.where((item) {
      final nameMatches = item.name.toLowerCase().contains(lowerQ);
      final subMatches = item.subtitle.toLowerCase().contains(lowerQ);
      final tagMatches = item.tags.any((t) => t.toLowerCase().contains(lowerQ));
      return nameMatches || subMatches || tagMatches;
    }).toList();
  }

  List<SearchResult> get _trendingItems {
    return _allSearchableItems
        .where((i) => i.tags.contains('Bestseller') || i.type == SearchResultType.restaurant)
        .take(4)
        .toList();
  }

  void _navigateToResult(SearchResult item) {
    if (item.type == SearchResultType.restaurant) {
      context.push('/restaurant/${item.id}');
    } else {
      context.push('/restaurant/${item.restaurantId ?? "rest_chatkara"}');
    }
  }

  void _onNavTap(int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        // Already on Search
        break;
      case 2:
        context.go('/orders');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final results = _filteredResults;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.bgPage,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // HEADER SECTION (12x12 padding)
                Container(
                  color: isDark ? AppColors.darkBg : AppColors.bgPage,
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // BACK ROW
                      Row(
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
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkCard : AppColors.flame50,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark ? AppColors.darkBorder : AppColors.flame100,
                                  width: 1.5,
                                ),
                              ),
                              child: const Center(
                                child: HugeIcon(
                                  icon: AppIcons.back,
                                  color: AppColors.flame,
                                  size: 15,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Search',
                            style: AppTypography.headlineSmall.copyWith(
                              color: isDark ? AppColors.darkTxt : AppColors.txtPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // SEARCH INPUT CONTAINER
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.flame,
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.flame.withValues(alpha: 0.12),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: HugeIcon(
                                icon: AppIcons.search,
                                color: AppColors.flame,
                                size: 18,
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                focusNode: _focusNode,
                                autofocus: true,
                                textInputAction: TextInputAction.search,
                                onChanged: _onSearchChanged,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: isDark ? AppColors.darkTxt : AppColors.txtPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Dish, restaurant, cuisine…',
                                  hintStyle: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.txtMuted,
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            if (_query.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: GestureDetector(
                                  onTap: _clearSearch,
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppColors.flameDark
                                          : AppColors.flame100,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: HugeIcon(
                                        icon: AppIcons.close,
                                        color: AppColors.flame,
                                        size: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // CONTENT AREA
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _query.isEmpty
                        ? _buildDefaultState(isDark)
                        : (results.isNotEmpty
                            ? _buildResultsState(results, isDark)
                            : _buildEmptyState(isDark)),
                  ),
                ),
              ],
            ),

            // FLOATING NAV BAR
            FloatingNavBar(
              currentIndex: 1,
              onTap: _onNavTap,
            ),
          ],
        ),
      ),
    );
  }

  // STATE A: Default State (query is empty)
  Widget _buildDefaultState(bool isDark) {
    final categories = [
      {'label': 'All', 'icon': AppIcons.restaurant},
      {'label': 'Non-Veg', 'icon': AppIcons.meat},
      {'label': 'Pure Veg', 'icon': AppIcons.leaf},
      {'label': 'Burgers', 'icon': AppIcons.burger},
      {'label': 'Pizzas', 'icon': AppIcons.pizza},
      {'label': 'Thali', 'icon': AppIcons.food},
      {'label': 'Beverages', 'icon': AppIcons.coffee},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // RECENT SEARCHES SECTION
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
            child: Row(
              children: [
                const HugeIcon(
                  icon: AppIcons.clock,
                  color: AppColors.flame,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  'Recent searches',
                  style: AppTypography.labelMedium.copyWith(
                    color: isDark ? AppColors.darkTxt2 : AppColors.txtSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recentSearches.map((label) {
                return GestureDetector(
                  onTap: () => _selectRecentChip(label),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.flame100,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const HugeIcon(
                          icon: AppIcons.clock,
                          color: AppColors.txtMuted,
                          size: 12,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          label,
                          style: AppTypography.labelSmall.copyWith(
                            color: isDark ? AppColors.darkTxt : AppColors.txtSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 18),

          // BROWSE BY CATEGORY SECTION
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            child: Row(
              children: [
                const HugeIcon(
                  icon: AppIcons.category,
                  color: AppColors.flame,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  'Browse by category',
                  style: AppTypography.labelMedium.copyWith(
                    color: isDark ? AppColors.darkTxt2 : AppColors.txtSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 74,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, idx) {
                final cat = categories[idx];
                final label = cat['label'] as String;
                final icon = cat['icon'] as List<List<dynamic>>;
                final isActive = _selectedCategory == label;

                return GestureDetector(
                  onTap: () => _onSelectCategory(label),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.flame
                              : (isDark ? AppColors.darkCard : Colors.white),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isActive
                                ? AppColors.flame
                                : (isDark ? AppColors.darkBorder : AppColors.flame100),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: HugeIcon(
                            icon: icon,
                            color: isActive ? Colors.white : AppColors.flame,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: isActive
                              ? AppColors.flame
                              : (isDark ? AppColors.darkTxt2 : AppColors.txtSecondary),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 18),

          // TRENDING NEAR YOU SECTION
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
            child: Row(
              children: [
                const HugeIcon(
                  icon: AppIcons.trending,
                  color: AppColors.flame,
                  size: 15,
                ),
                const SizedBox(width: 6),
                Text(
                  'Trending near you',
                  style: AppTypography.labelMedium.copyWith(
                    color: isDark ? AppColors.darkTxt2 : AppColors.txtSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          ..._trendingItems.map((item) {
            return SearchResultItem(
              result: item,
              query: '',
              onTap: () => _navigateToResult(item),
            );
          }),
        ],
      ),
    );
  }

  // STATE B: Search Results State
  Widget _buildResultsState(List<SearchResult> results, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
          child: Text(
            '${results.length} results for "$_query"',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.txtMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 90),
            itemCount: results.length,
            itemBuilder: (context, idx) {
              final item = results[idx];
              return SearchResultItem(
                result: item,
                query: _query,
                onTap: () => _navigateToResult(item),
              );
            },
          ),
        ),
      ],
    );
  }

  // STATE C: Empty Search State
  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 90),
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
                  icon: AppIcons.searchMinus,
                  color: AppColors.flame200,
                  size: 46,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'No results found',
              style: AppTypography.headlineSmall.copyWith(
                color: isDark ? AppColors.darkTxt : AppColors.txtPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try "$_query" with different spelling',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.txtMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            OutlinedButton(
              onPressed: _clearSearch,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.flame, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
              ),
              child: Text(
                'Clear search',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.flame,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
