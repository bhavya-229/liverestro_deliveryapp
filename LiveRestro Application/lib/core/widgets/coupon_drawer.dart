import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../constants/app_colors.dart';
import '../constants/app_icons.dart';
import '../constants/app_typography.dart';

class CouponModel {
  final String code;
  final String description;
  final String terms;
  final int discountAmount;

  const CouponModel({
    required this.code,
    required this.description,
    required this.terms,
    required this.discountAmount,
  });
}

class CouponDrawer extends StatelessWidget {
  final Function(CouponModel) onApply;

  const CouponDrawer({
    super.key,
    required this.onApply,
  });

  static const List<CouponModel> availableCoupons = [
    CouponModel(
      code: 'WELCOME100',
      description: 'Flat ₹100 OFF on your first order above ₹249',
      terms: 'Valid on orders above ₹249',
      discountAmount: 100,
    ),
    CouponModel(
      code: 'LIVERESTRO50',
      description: '50% OFF up to ₹150 on delicious meals',
      terms: 'Valid on orders above ₹199',
      discountAmount: 150,
    ),
    CouponModel(
      code: 'FREESHIP',
      description: 'Zero Delivery Fee on orders above ₹149',
      terms: 'Free delivery applied directly',
      discountAmount: 40,
    ),
  ];

  static Future<CouponModel?> show(BuildContext context, {required Function(CouponModel) onApply}) {
    return showModalBottomSheet<CouponModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CouponDrawer(onApply: onApply),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.58,
      maxChildSize: 0.85,
      minChildSize: 0.40,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.flame100,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 16, 14),
                child: Row(
                  children: [
                    const HugeIcon(
                      icon: AppIcons.coupon,
                      color: AppColors.flame,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Apply Coupon',
                      style: AppTypography.headlineMedium.copyWith(
                        color: isDark ? AppColors.darkTxt : AppColors.txtPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const HugeIcon(
                        icon: AppIcons.close,
                        color: AppColors.txtMuted,
                        size: 20,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.flame50, height: 1),
              // Coupon List
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: availableCoupons.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (ctx, idx) {
                    final c = availableCoupons[idx];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkBg : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.flame200,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.flame50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: HugeIcon(
                                icon: AppIcons.coupon,
                                color: AppColors.flame,
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.code,
                                  style: AppTypography.labelLarge.copyWith(
                                    color: AppColors.flame,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  c.description,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: isDark ? AppColors.darkTxt2 : AppColors.txtSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              onApply(c);
                              Navigator.of(context).pop(c);
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.flame,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'APPLY',
                                style: AppTypography.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
