import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/network/api_client.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../location/providers/location_provider.dart';
import '../../order_tracking/models/order_model.dart';
import '../../order_tracking/providers/order_tracking_provider.dart';
import '../providers/payment_provider.dart';

class PaymentSelectionScreen extends ConsumerStatefulWidget {
  const PaymentSelectionScreen({super.key});

  @override
  ConsumerState<PaymentSelectionScreen> createState() => _PaymentSelectionScreenState();
}

class _PaymentSelectionScreenState extends ConsumerState<PaymentSelectionScreen> {
  String _selectedPaymentMethod = 'gpay'; // gpay, phonepe, paytm, other_upi, card, netbanking

  void _onPlaceOrder() async {
    final cartState = ref.read(cartProvider);
    final locationState = ref.read(locationProvider);
    final user = ref.read(authProvider).user;

    final success = await ref.read(paymentProvider.notifier).processPayment(
      amount: cartState.finalAmount,
    );

    if (!mounted) return;

    if (success) {
      // Map display payment method string
      String methodDisplay = 'UPI';
      if (_selectedPaymentMethod == 'card') methodDisplay = 'Credit/Debit Card';
      if (_selectedPaymentMethod == 'netbanking') methodDisplay = 'Net Banking';
      if (_selectedPaymentMethod == 'gpay') methodDisplay = 'Google Pay';
      if (_selectedPaymentMethod == 'phonepe') methodDisplay = 'PhonePe';
      if (_selectedPaymentMethod == 'paytm') methodDisplay = 'Paytm';

      // Dispatch order to LiveRestro POS API backend
      final remoteOrder = await ApiClient().createOrder(
        restaurantId: cartState.restaurantId ?? '55',
        customerName: user?.name ?? 'Customer',
        customerPhone: user?.phoneNumber ?? '9876543210',
        deliveryAddress: locationState.activeAddress.fullAddress,
        paymentMethod: methodDisplay,
        totalAmount: cartState.finalAmount,
        items: cartState.items.map((i) => {
          'item_id': i.menuItem.id,
          'item_name': i.menuItem.name,
          'quantity': i.quantity,
          'price': i.totalPrice,
          'selected_option': i.selectedOption,
        }).toList(),
        deliveryTip: cartState.deliveryTip,
        specialNotes: cartState.deliveryInstructions,
      );

      final assignedOrderId = remoteOrder != null && remoteOrder['order_number'] != null
          ? remoteOrder['order_number'].toString()
          : "LR-${const Uuid().v4().substring(0, 8).toUpperCase()}";

      final newOrder = OrderModel(
        orderId: assignedOrderId,
        restaurantId: cartState.restaurantId ?? '55',
        restaurantName: cartState.restaurantName ?? 'LiveRestro Partner',
        items: cartState.items,
        billAmount: cartState.finalAmount,
        deliveryAddress: locationState.activeAddress,
        paymentMethod: methodDisplay,
        placedAt: DateTime.now(),
        customerName: user?.name ?? 'Customer',
        customerPhone: user?.phoneNumber ?? '9876543210',
      );

      ref.read(orderTrackingProvider.notifier).startNewOrder(newOrder);
      ref.read(cartProvider.notifier).clearCart();

      if (!mounted) return;
      context.go('/tracking/${newOrder.orderId}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cartState = ref.watch(cartProvider);
    final paymentState = ref.watch(paymentProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.bgPage,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/cart');
            }
          },
          child: const Center(
            child: HugeIcon(
              icon: AppIcons.back,
              color: AppColors.flame,
              size: 20,
            ),
          ),
        ),
        title: Text(
          'Select Payment',
          style: AppTypography.headlineMedium.copyWith(
            color: isDark ? AppColors.darkTxt : AppColors.txtPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Amount Summary Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.flame50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.flame100),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Payable Amount',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.txtSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '₹${cartState.finalAmount.toInt()}',
                                style: AppTypography.priceTag.copyWith(fontSize: 22),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.successBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const HugeIcon(
                                  icon: AppIcons.lockKey,
                                  color: AppColors.success,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '100% SECURE',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.success,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // UPI Options Header
                    Text(
                      'Pay via UPI',
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.darkTxt : AppColors.txtPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),

                    _buildPaymentOption('gpay', AppIcons.upi, 'Google Pay', 'Fast & secure UPI transfer', isDark),
                    const SizedBox(height: 8),
                    _buildPaymentOption('phonepe', AppIcons.upi, 'PhonePe', 'Instant bank payment', isDark),
                    const SizedBox(height: 8),
                    _buildPaymentOption('paytm', AppIcons.upi, 'Paytm UPI', 'Pay via Paytm handle', isDark),
                    const SizedBox(height: 8),
                    _buildPaymentOption('other_upi', AppIcons.upi, 'Other UPI App / QR', 'Scan or enter any UPI ID', isDark),

                    const SizedBox(height: 24),

                    // Cards & NetBanking
                    Text(
                      'Cards & Net Banking',
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.darkTxt : AppColors.txtPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),

                    _buildPaymentOption('card', AppIcons.payment, 'Credit / Debit Cards', 'Visa, MasterCard, RuPay', isDark),
                    const SizedBox(height: 8),
                    _buildPaymentOption('netbanking', AppIcons.receipt, 'Net Banking', 'All Indian banks supported', isDark),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Bottom CTA
            Container(
              padding: const EdgeInsets.all(16),
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
                label: paymentState.isProcessing
                    ? 'Processing Payment...'
                    : 'Pay  ·  ₹${cartState.finalAmount.toInt()}',
                trailingIcon: AppIcons.secure,
                isLoading: paymentState.isProcessing,
                onTap: paymentState.isProcessing ? null : _onPlaceOrder,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String value, List<List<dynamic>> icon, String title, String subtitle, bool isDark) {
    final isSelected = _selectedPaymentMethod == value;

    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.flame : (isDark ? AppColors.darkBorder : AppColors.flame100),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.flame50 : (isDark ? AppColors.darkBg : AppColors.flame50),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: HugeIcon(
                  icon: icon,
                  color: AppColors.flame,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.labelMedium.copyWith(
                      color: isDark ? AppColors.darkTxt : AppColors.txtPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.txtMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.flame : AppColors.txtMuted,
                  width: 2,
                ),
                color: isSelected ? AppColors.flame : Colors.transparent,
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(Icons.circle, size: 8, color: Colors.white),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
