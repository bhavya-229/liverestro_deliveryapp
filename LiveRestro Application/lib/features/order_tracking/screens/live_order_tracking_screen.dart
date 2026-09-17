import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/animated_dot.dart';
import '../../../core/widgets/eta_ring_timer.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/step_indicator.dart';
import '../../location/models/address_model.dart';
import '../models/order_model.dart';
import '../providers/order_tracking_provider.dart';

class LiveOrderTrackingScreen extends ConsumerWidget {
  final String orderId;

  const LiveOrderTrackingScreen({super.key, required this.orderId});

  void _callRider(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final orders = ref.watch(orderTrackingProvider);

    final order = orders.firstWhere(
      (o) => o.orderId == orderId,
      orElse: () => OrderModel(
        orderId: orderId,
        restaurantId: 'rest_chatkara',
        restaurantName: 'Chatkara',
        items: const [],
        billAmount: 399,
        deliveryAddress: const AddressModel(
          id: '1',
          tag: 'Home',
          fullAddress: 'A-402, Shivam Heights, University Road, Rajkot',
          landmark: 'Near Kotecha Chowk',
          latitude: 22.3039,
          longitude: 70.8022,
        ),
        paymentMethod: 'UPI',
        placedAt: DateTime.now(),
        customerName: 'Customer',
        customerPhone: '9876543210',
      ),
    );

    final statusIndex = order.status.index;

    final steps = [
      LiveOrderStep(
        title: 'Order placed & sent to kitchen POS',
        subtitle: 'Confirmed by ${order.restaurantName} POS terminal',
        icon: AppIcons.checkmark,
        status: statusIndex > 0
            ? StepStatus.done
            : (statusIndex == 0 ? StepStatus.active : StepStatus.pending),
      ),
      LiveOrderStep(
        title: 'Food is being prepared in kitchen',
        subtitle: statusIndex == 1 ? 'Direct POS sync: Chef active' : null,
        icon: AppIcons.pot,
        status: statusIndex > 1
            ? StepStatus.done
            : (statusIndex == 1 ? StepStatus.active : StepStatus.pending),
      ),
      LiveOrderStep(
        title: 'Order ready & rider assigned',
        subtitle: statusIndex == 2 ? 'Packed & waiting for rider pickup' : null,
        icon: AppIcons.clock,
        status: statusIndex > 2
            ? StepStatus.done
            : (statusIndex == 2 ? StepStatus.active : StepStatus.pending),
      ),
      LiveOrderStep(
        title: 'Out for delivery',
        subtitle: statusIndex == 3 ? 'Rider is on the way to your address' : null,
        icon: AppIcons.motorbike,
        status: statusIndex > 3
            ? StepStatus.done
            : (statusIndex == 3 ? StepStatus.active : StepStatus.pending),
      ),
      LiveOrderStep(
        title: 'Delivered!',
        subtitle: statusIndex == 4 ? 'Enjoy your hot meal!' : null,
        icon: AppIcons.checkCircle,
        status: statusIndex == 4 ? StepStatus.done : StepStatus.pending,
      ),
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.bgPage,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // GRADIENT HEADER
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                decoration: const BoxDecoration(
                  gradient: AppColors.heroGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(22),
                    bottomRight: Radius.circular(22),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.go('/home'),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.22),
                            ),
                            child: const Center(
                              child: HugeIcon(
                                icon: AppIcons.close,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Live Order Tracking',
                          style: AppTypography.headlineSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            ref.read(orderTrackingProvider.notifier).fastForwardStatus(orderId);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              'Next Stage ⏩',
                              style: AppTypography.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const AnimatedDot(size: 6, color: AppColors.posLive),
                        const SizedBox(width: 6),
                        Text(
                          'POS Kitchen Confirmed  ·  Order #${order.orderId}',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ETA RING SECTION
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ETARingTimer(
                  totalMinutes: 30,
                  remainingMinutes: order.etaMinutes,
                ),
              ),

              const SizedBox(height: 18),

              // STATUS CHIP
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.flame50,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.flame100,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AnimatedDot(size: 6, color: AppColors.flame),
                    const SizedBox(width: 7),
                    const HugeIcon(
                      icon: AppIcons.pot,
                      color: AppColors.flame,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getStatusText(order.status),
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.flame,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // MILESTONE STRIP
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.flame100,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMilestoneNode('3.2 km', AppIcons.location, statusIndex >= 0),
                    _buildMilestoneLine(statusIndex >= 1),
                    _buildMilestoneNode('Kitchen', AppIcons.pot, statusIndex >= 1),
                    _buildMilestoneLine(statusIndex >= 3),
                    _buildMilestoneNode('On way', AppIcons.motorbike, statusIndex >= 3),
                    _buildMilestoneLine(statusIndex >= 4),
                    _buildMilestoneNode('Your door', AppIcons.address, statusIndex >= 4),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // RIDER CARD
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.flame100,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.flame,
                      child: const Text(
                        'RK',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.riderName ?? 'Ramesh Kumar',
                            style: AppTypography.labelLarge.copyWith(
                              color: isDark ? AppColors.darkTxt : AppColors.txtPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            order.riderVehicleNumber ?? 'GJ 03 EK 4492 · Honda Activa',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.txtMuted,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.successBg,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const HugeIcon(
                                  icon: AppIcons.star,
                                  color: AppColors.success,
                                  size: 10,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '4.9 Top Rated',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _callRider(order.riderPhone),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          color: AppColors.successBg,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: HugeIcon(
                            icon: AppIcons.phone,
                            color: AppColors.success,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 5-STAGE LIVE STEPPER
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: StepIndicator(steps: steps),
              ),

              const SizedBox(height: 16),

              // BACK TO HOME BUTTON
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GradientButton(
                  label: 'Back to Home',
                  leadingIcon: AppIcons.home,
                  onTap: () => context.go('/home'),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed:
        return 'Order sent to restaurant POS';
      case OrderStatus.preparing:
        return 'Food being prepared in kitchen';
      case OrderStatus.ready:
        return 'Order packed & ready for pickup';
      case OrderStatus.outForDelivery:
        return 'Rider on the way to your door';
      case OrderStatus.delivered:
        return 'Delivered! Enjoy your meal';
    }
  }

  Widget _buildMilestoneNode(String label, List<List<dynamic>> icon, bool isReached) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isReached ? AppColors.flame : AppColors.flame50,
          ),
          child: Center(
            child: HugeIcon(
              icon: icon,
              color: isReached ? Colors.white : AppColors.txtMuted,
              size: 14,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: isReached ? AppColors.flame : AppColors.txtMuted,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildMilestoneLine(bool isFilled) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 14),
        color: isFilled ? AppColors.flame : AppColors.flame100,
      ),
    );
  }
}
