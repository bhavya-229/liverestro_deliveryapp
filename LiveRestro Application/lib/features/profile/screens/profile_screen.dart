import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/theme_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../location/providers/location_provider.dart';
import '../../order_tracking/providers/order_tracking_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;
    final themeMode = ref.watch(themeModeProvider);
    final locationState = ref.watch(locationProvider);
    final orders = ref.watch(orderTrackingProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.bgPage,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HERO HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 26),
                decoration: const BoxDecoration(
                  gradient: AppColors.heroGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
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
                            width: 36,
                            height: 36,
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
                        const SizedBox(width: 12),
                        Text(
                          'My Profile',
                          style: AppTypography.headlineSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white.withValues(alpha: 0.25),
                      child: Text(
                        (user?.name.isNotEmpty ?? false) ? user!.name[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user?.name ?? 'LiveRestro User',
                      style: AppTypography.headlineMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '+91 ${user?.phoneNumber ?? '9876543210'}  ·  ${user?.email ?? 'verified'}',
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // SETTINGS CARD
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.flame100,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    _buildRow(
                      context,
                      icon: AppIcons.leaf,
                      label: 'Pure Veg Mode',
                      trailing: CupertinoSwitch(
                        value: user?.isVegOnly ?? false,
                        activeTrackColor: AppColors.success,
                        onChanged: (val) {
                          ref.read(authProvider.notifier).toggleVegPreference(val);
                        },
                      ),
                    ),
                    _buildDivider(isDark),
                    _buildRow(
                      context,
                      icon: AppIcons.darkMode,
                      label: 'Dark Mode',
                      trailing: CupertinoSwitch(
                        value: themeMode == ThemeMode.dark,
                        activeTrackColor: AppColors.flame,
                        onChanged: (_) {
                          ref.read(themeModeProvider.notifier).toggleTheme();
                        },
                      ),
                    ),
                    _buildDivider(isDark),
                    _buildRow(
                      context,
                      icon: AppIcons.address,
                      label: 'Saved Addresses',
                      onTap: () => context.push('/location'),
                      trailing: Row(
                        children: [
                          Text(
                            '${locationState.savedAddresses.length} saved',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.txtMuted),
                          ),
                          const SizedBox(width: 4),
                          const HugeIcon(icon: AppIcons.forward, color: AppColors.flame, size: 14),
                        ],
                      ),
                    ),
                    _buildDivider(isDark),
                    _buildRow(
                      context,
                      icon: AppIcons.payment,
                      label: 'Payment Methods',
                      trailing: Row(
                        children: [
                          Text(
                            'UPI / COD',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.txtMuted),
                          ),
                          const SizedBox(width: 4),
                          const HugeIcon(icon: AppIcons.forward, color: AppColors.flame, size: 14),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // SECTION LABEL
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Order History',
                  style: AppTypography.labelLarge.copyWith(
                    color: isDark ? AppColors.darkTxt : AppColors.txtPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ORDER HISTORY CARDS
              if (orders.isEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.flame100),
                  ),
                  child: Text(
                    'No orders placed yet',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.txtMuted),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: orders.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (ctx, idx) {
                    final o = orders[idx];
                    return Container(
                      padding: const EdgeInsets.all(14),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                o.restaurantName,
                                style: AppTypography.labelLarge.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.flame50,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  o.orderId,
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.flame,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const HugeIcon(
                                icon: AppIcons.calendar,
                                color: AppColors.txtMuted,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${o.placedAt.day}/${o.placedAt.month}/${o.placedAt.year} · ${o.items.length} items',
                                style: AppTypography.bodySmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '₹${o.billAmount.toInt()}',
                                style: AppTypography.priceTagSmall,
                              ),
                              InkWell(
                                onTap: () => context.push('/tracking/${o.orderId}'),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.flame,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Track Live',
                                        style: AppTypography.labelSmall.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const HugeIcon(
                                        icon: AppIcons.forward,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),

              const SizedBox(height: 20),

              // LOGOUT BUTTON
              GestureDetector(
                onTap: () async {
                  await ref.read(authProvider.notifier).logout();
                  if (!context.mounted) return;
                  context.go('/login');
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: AppColors.nonVegBg, width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const HugeIcon(
                        icon: AppIcons.logout,
                        color: AppColors.nonVeg,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Log out',
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.nonVeg,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(
    BuildContext context, {
    required List<List<dynamic>> icon,
    required String label,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.flame50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: HugeIcon(
                  icon: icon,
                  color: AppColors.flame,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTypography.labelMedium.copyWith(
                  color: isDark ? AppColors.darkTxt : AppColors.txtPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      color: isDark ? AppColors.darkBorder : AppColors.flame50,
      height: 1,
      indent: 16,
      endIndent: 16,
    );
  }
}
