import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_typography.dart';
import '../../order_tracking/models/order_model.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTrack;
  final VoidCallback onReorder;
  final VoidCallback onRate;

  const OrderCard({
    super.key,
    required this.order,
    required this.onTrack,
    required this.onReorder,
    required this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCancelled = order.status == OrderStatus.cancelled;
    final isDelivered = order.status == OrderStatus.delivered;
    final isActive = !isCancelled && !isDelivered;

    final dateFormatted = _formatOrderDate(order.placedAt);
    final itemsSummary = order.items
        .map((i) => '${i.menuItem.name} × ${i.quantity}')
        .join(' · ');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.flame100,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOP ROW: Restaurant Name + Date and Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.restaurantName,
                      style: AppTypography.labelLarge.copyWith(
                        color: isDark ? AppColors.darkTxt : AppColors.txtPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const HugeIcon(
                          icon: AppIcons.calendar,
                          color: AppColors.txtMuted,
                          size: 11,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dateFormatted,
                          style: AppTypography.bodySmall.copyWith(
                            fontSize: 10,
                            color: AppColors.txtMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusBadge(isDark, isActive, isDelivered, isCancelled),
            ],
          ),

          const SizedBox(height: 9),

          // ITEMS TEXT
          Text(
            itemsSummary,
            style: AppTypography.bodySmall.copyWith(
              fontSize: 11,
              color: isDark ? AppColors.darkTxt2 : AppColors.txtSecondary,
              height: 1.35,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 12),

          // BOTTOM ROW: Amount & Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // PRICE OR REFUND
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCancelled ? 'Refunded' : 'Order total',
                    style: AppTypography.bodySmall.copyWith(
                      fontSize: 10,
                      color: AppColors.txtMuted,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '₹${order.billAmount.toInt()}',
                    style: AppTypography.priceTagSmall.copyWith(
                      color: isCancelled ? AppColors.success : AppColors.flame,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              // ACTION BUTTONS
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isDelivered) ...[
                    // Rate button
                    GestureDetector(
                      onTap: onRate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : AppColors.flame50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.flame100,
                            width: 1.5,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            HugeIcon(
                              icon: AppIcons.star,
                              color: AppColors.flame,
                              size: 13,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Rate',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.flame,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Reorder button
                    GestureDetector(
                      onTap: onReorder,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          gradient: AppColors.ctaGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            HugeIcon(
                              icon: AppIcons.refresh,
                              color: Colors.white,
                              size: 13,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Reorder',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else if (isCancelled) ...[
                    // Reorder button for cancelled
                    GestureDetector(
                      onTap: onReorder,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          gradient: AppColors.ctaGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            HugeIcon(
                              icon: AppIcons.refresh,
                              color: Colors.white,
                              size: 13,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Reorder',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    // Active order -> Track Live
                    GestureDetector(
                      onTap: onTrack,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          gradient: AppColors.ctaGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Track Live →',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isDark, bool isActive, bool isDelivered, bool isCancelled) {
    Color bg;
    Color color;
    List<List<dynamic>> icon;
    String label;

    if (isDelivered) {
      bg = isDark ? AppColors.success.withValues(alpha: 0.2) : AppColors.successBg;
      color = AppColors.success;
      icon = AppIcons.checkCircle;
      label = 'Delivered';
    } else if (isCancelled) {
      bg = isDark ? AppColors.nonVeg.withValues(alpha: 0.2) : AppColors.nonVegBg;
      color = AppColors.nonVeg;
      icon = AppIcons.close;
      label = 'Cancelled';
    } else {
      bg = isDark ? AppColors.flame.withValues(alpha: 0.2) : AppColors.flame50;
      color = AppColors.flame;
      icon = AppIcons.radio;
      label = order.status == OrderStatus.preparing
          ? 'Preparing'
          : (order.status == OrderStatus.outForDelivery ? 'On Way' : 'Active');
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(icon: icon, color: color, size: 11),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatOrderDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today · ${DateFormat('hh:mm a').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday · ${DateFormat('hh:mm a').format(date)}';
    } else {
      return '${DateFormat('dd MMM').format(date)} · ${DateFormat('hh:mm a').format(date)}';
    }
  }
}
