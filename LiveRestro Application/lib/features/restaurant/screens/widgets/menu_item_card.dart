import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/diet_icon.dart';
import '../../../../core/widgets/qty_controller.dart';
import '../../models/menu_item_model.dart';
import '../../models/restaurant_model.dart';
import '../../../cart/models/cart_item_model.dart';
import '../../../cart/providers/cart_provider.dart';
import 'item_customization_sheet.dart';

class MenuItemCard extends ConsumerWidget {
  final MenuItemModel item;
  final RestaurantModel restaurant;

  const MenuItemCard({
    super.key,
    required this.item,
    required this.restaurant,
  });

  void _handleAddItem(BuildContext context, WidgetRef ref) {
    final cartNotifier = ref.read(cartProvider.notifier);
    final cartState = ref.read(cartProvider);

    if (item.customizations.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => ItemCustomizationSheet(item: item, restaurant: restaurant),
      );
      return;
    }

    if (cartState.restaurantId != null && cartState.restaurantId != restaurant.id) {
      _showReplaceCartDialog(context, ref);
      return;
    }

    cartNotifier.addItem(
      CartItemModel(
        menuItem: item,
        restaurantId: restaurant.id,
        restaurantName: restaurant.name,
      ),
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text('${item.name} added to cart')),
          ],
        ),
        backgroundColor: AppColors.flameDark,
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showReplaceCartDialog(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentRestName = ref.read(cartProvider).restaurantName ?? 'another restaurant';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        title: Text(
          "Replace Cart Items?",
          style: AppTypography.headlineMedium.copyWith(
            color: isDark ? AppColors.darkTxt : AppColors.txtPrimary,
          ),
        ),
        content: Text(
          "Your cart contains items from '$currentRestName'. Do you want to clear the cart and add items from '${restaurant.name}'?",
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              "Cancel",
              style: TextStyle(color: AppColors.txtMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(cartProvider.notifier).clearCart();
              ref.read(cartProvider.notifier).addItem(
                CartItemModel(
                  menuItem: item,
                  restaurantId: restaurant.id,
                  restaurantName: restaurant.name,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.flame,
              minimumSize: const Size(120, 42),
            ),
            child: const Text("Replace Cart"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cartState = ref.watch(cartProvider);
    final quantityInCart = cartState.getItemQuantity(item.id);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.flame50,
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Dish info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    DietIcon(isVeg: item.isVeg, size: 14),
                    if (item.isBestseller) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const Text(
                          'Bestseller',
                          style: TextStyle(
                            fontSize: 9,
                            color: Color(0xFFE65100),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.name,
                  style: AppTypography.labelLarge.copyWith(
                    color: isDark ? AppColors.darkTxt : AppColors.txtPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${item.price.toInt()}',
                  style: AppTypography.priceTagSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? AppColors.darkTxt2 : AppColors.txtSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.customizations.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Customizable',
                    style: TextStyle(
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                      color: AppColors.flame200,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Right: Dish image + ADD / QTY button
          Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    width: 84,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.flame50,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: CachedNetworkImage(
                      imageUrl: item.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.flame50,
                        child: const Center(
                          child: HugeIcon(
                            icon: AppIcons.food,
                            color: AppColors.flame100,
                            size: 28,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: HugeIcon(
                          icon: AppIcons.food,
                          color: AppColors.flame100,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -12,
                    child: QtyController(
                      quantity: quantityInCart,
                      isCustomizable: item.customizations.isNotEmpty,
                      onAdd: () {
                        if (quantityInCart == 0 || item.customizations.isNotEmpty) {
                          _handleAddItem(context, ref);
                        } else {
                          ref.read(cartProvider.notifier).incrementQuantity(item.id);
                        }
                      },
                      onRemove: () {
                        ref.read(cartProvider.notifier).decrementQuantity(item.id);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
            ],
          ),
        ],
      ),
    );
  }
}
