import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/coupon_drawer.dart';
import '../../../core/widgets/diet_icon.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/qty_controller.dart';
import '../providers/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    if (cart.items.isEmpty) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.bgPage,
        appBar: AppBar(
          leading: IconButton(
            icon: const HugeIcon(icon: AppIcons.back, color: AppColors.flame, size: 20),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
          title: Text(
            'Your Cart',
            style: AppTypography.headlineMedium.copyWith(
              color: isDark ? AppColors.darkTxt : AppColors.txtPrimary,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.flame50,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: HugeIcon(
                      icon: AppIcons.cart,
                      color: AppColors.flame,
                      size: 44,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Your cart is empty',
                  style: AppTypography.headlineMedium.copyWith(
                    color: isDark ? AppColors.darkTxt : AppColors.txtPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Explore our partner restaurants to add delicious items',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: 200,
                  child: GradientButton(
                    label: 'Browse Food',
                    leadingIcon: AppIcons.restaurant,
                    onTap: () => context.go('/home'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.bgPage,
      body: SafeArea(
        child: Column(
          children: [
            // APP BAR
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.flame50,
                    width: 1,
                  ),
                ),
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
                    child: const HugeIcon(
                      icon: AppIcons.back,
                      color: AppColors.flame,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cart.restaurantName ?? 'Restaurant Cart',
                          style: AppTypography.headlineSmall.copyWith(
                            color: isDark ? AppColors.darkTxt : AppColors.txtPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${cart.totalItemCount} items in cart',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.txtMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => cartNotifier.clearCart(),
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          const HugeIcon(
                            icon: AppIcons.delete,
                            color: AppColors.nonVeg,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Clear all',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.nonVeg,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // CART CONTENT
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // ITEMS LIST
                    Container(
                      color: isDark ? AppColors.darkCard : Colors.white,
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: cart.items.length,
                        separatorBuilder: (context, index) => Divider(
                          color: isDark ? AppColors.darkBorder : AppColors.flame50,
                          height: 1,
                        ),
                        itemBuilder: (ctx, idx) {
                          final item = cart.items[idx];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child: DietIcon(isVeg: item.menuItem.isVeg, size: 14),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.menuItem.name,
                                        style: AppTypography.labelLarge.copyWith(
                                          color: isDark ? AppColors.darkTxt : AppColors.txtPrimary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      if (item.selectedOption != null) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          item.selectedOption!,
                                          style: AppTypography.bodySmall.copyWith(
                                            color: AppColors.txtMuted,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 4),
                                      Text(
                                        '₹${item.unitPrice.toInt()} each',
                                        style: AppTypography.priceTagSmall,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                QtyController(
                                  quantity: item.quantity,
                                  onAdd: () => cartNotifier.incrementQuantity(item.menuItem.id),
                                  onRemove: () => cartNotifier.decrementQuantity(item.menuItem.id),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    // COUPON SECTION
                    GestureDetector(
                      onTap: () {
                        CouponDrawer.show(
                          context,
                          onApply: (coupon) {
                            cartNotifier.applyPromo(
                              PromoCodeModel(
                                code: coupon.code,
                                description: coupon.description,
                                discountPercentage: coupon.code == 'LIVERESTRO50' ? 50 : 100,
                                maxDiscount: coupon.discountAmount.toDouble(),
                                minOrderAmount: 149,
                              ),
                            );
                          },
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: cart.appliedPromo != null ? AppColors.success : AppColors.flame200,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            HugeIcon(
                              icon: AppIcons.coupon,
                              color: cart.appliedPromo != null ? AppColors.success : AppColors.flame,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                cart.appliedPromo != null
                                    ? 'Code "${cart.appliedPromo!.code}" Applied'
                                    : 'Apply a coupon code',
                                style: AppTypography.labelMedium.copyWith(
                                  color: cart.appliedPromo != null ? AppColors.success : AppColors.flame,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            if (cart.appliedPromo != null)
                              GestureDetector(
                                onTap: () => cartNotifier.removePromo(),
                                child: Text(
                                  'Remove',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.nonVeg,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              )
                            else
                              const HugeIcon(
                                icon: AppIcons.forward,
                                color: AppColors.flame,
                                size: 16,
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // TIP SECTION
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.flame100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const HugeIcon(
                                icon: AppIcons.favourite,
                                color: AppColors.flame,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Tip your delivery partner',
                                style: AppTypography.labelMedium.copyWith(
                                  color: isDark ? AppColors.darkTxt : AppColors.txtPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _buildTipChip(ref, label: 'No tip', amount: 0, currentTip: cart.deliveryTip),
                              const SizedBox(width: 8),
                              _buildTipChip(ref, label: '₹20', amount: 20, currentTip: cart.deliveryTip),
                              const SizedBox(width: 8),
                              _buildTipChip(ref, label: '₹30', amount: 30, currentTip: cart.deliveryTip),
                              const SizedBox(width: 8),
                              _buildTipChip(ref, label: '₹50', amount: 50, currentTip: cart.deliveryTip),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // BILL BREAKDOWN
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.flame50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.flame100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const HugeIcon(
                                icon: AppIcons.receipt,
                                color: AppColors.flame,
                                size: 15,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Bill breakdown',
                                style: AppTypography.labelLarge.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildBillRow('Item total', '₹${cart.itemTotal.toInt()}'),
                          _buildBillRow('Delivery fee', cart.deliveryFee == 0 ? 'FREE' : '₹${cart.deliveryFee.toInt()}', isSuccess: cart.deliveryFee == 0),
                          _buildBillRow('Platform fee', '₹${cart.platformFee.toInt()}'),
                          _buildBillRow('GST (5%)', '₹${cart.taxesAndGst.toInt()}'),
                          if (cart.discountAmount > 0)
                            _buildBillRow(
                              'Discount (${cart.appliedPromo!.code})',
                              '−₹${cart.discountAmount.toInt()}',
                              isSuccess: true,
                            ),
                          if (cart.deliveryTip > 0)
                            _buildBillRow('Delivery tip', '₹${cart.deliveryTip.toInt()}'),
                          const SizedBox(height: 8),
                          Divider(color: isDark ? AppColors.darkBorder : AppColors.flame100),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total payable',
                                style: AppTypography.labelLarge.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                '₹${cart.finalAmount.toInt()}',
                                style: AppTypography.priceTag.copyWith(fontSize: 18),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            // BOTTOM CTA BAR
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.flame100,
                    width: 1,
                  ),
                ),
              ),
              child: GradientButton(
                label: 'Select Payment  ·  ₹${cart.finalAmount.toInt()}',
                trailingIcon: AppIcons.forward,
                onTap: () => context.push('/payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipChip(WidgetRef ref, {required String label, required double amount, required double currentTip}) {
    final isSelected = currentTip == amount;

    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(cartProvider.notifier).setDeliveryTip(amount),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.flame : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.flame : AppColors.flame100,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: isSelected ? Colors.white : AppColors.txtSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBillRow(String title, String value, {bool isSuccess = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.txtSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              color: isSuccess ? AppColors.success : AppColors.txtPrimary,
              fontWeight: isSuccess ? FontWeight.w800 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
