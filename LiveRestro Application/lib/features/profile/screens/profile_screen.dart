import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/floating_nav_bar.dart';
import '../../auth/providers/auth_provider.dart';
import '../../location/providers/location_provider.dart';
import '../../order_tracking/providers/order_tracking_provider.dart';
import '../widgets/profile_row.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _notificationsEnabled = true;

  void _onNavTap(int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.push('/search');
        break;
      case 2:
        context.go('/orders');
        break;
      case 3:
        // Already on Profile
        break;
    }
  }

  void _showEditProfileSheet(BuildContext context, String currentName, String currentEmail) {
    final nameCtrl = TextEditingController(text: currentName);
    final emailCtrl = TextEditingController(text: currentEmail);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.flame100,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Edit Profile',
                style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Email Address'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  ref.read(authProvider.notifier).updateProfile(
                        name: nameCtrl.text.trim(),
                        email: emailCtrl.text.trim(),
                      );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile updated successfully!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.flame,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Save Changes'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out of LiveRestro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.txtMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.nonVeg,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;
    final themeMode = ref.watch(themeModeProvider);
    final locationState = ref.watch(locationProvider);
    final orders = ref.watch(orderTrackingProvider);

    final totalOrders = orders.length;
    final totalSpentAmount = orders.fold<double>(0, (sum, o) => sum + o.billAmount);
    final totalSpentFormatted = totalSpentAmount > 1000
        ? '₹${(totalSpentAmount / 1000).toStringAsFixed(1)}k'
        : '₹${totalSpentAmount.toInt()}';
    final savedAddressesCount = locationState.savedAddresses.length;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.bgPage,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // GRADIENT HERO
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
                    decoration: const BoxDecoration(
                      gradient: AppColors.heroGradient,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    child: Stack(
                      children: [
                        // BACK & EDIT BUTTONS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.22),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: HugeIcon(
                                    icon: AppIcons.back,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _showEditProfileSheet(
                                context,
                                user?.name ?? 'LiveRestro User',
                                user?.email ?? '',
                              ),
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.22),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: HugeIcon(
                                    icon: AppIcons.edit,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // USER PROFILE CENTER COLUMN
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.22),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.40),
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      (user?.name.isNotEmpty ?? false)
                                          ? user!.name[0].toUpperCase()
                                          : 'B',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  user?.name ?? 'LiveRestro User',
                                  style: AppTypography.headlineMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '+91 ${user?.phoneNumber ?? '98765 43210'} · ${user?.email ?? 'verified'}',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // BADGES ROW
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (user?.isVegOnly ?? true) ...[
                                      _buildHeroBadge(
                                        icon: AppIcons.leaf,
                                        label: 'Pure Veg',
                                      ),
                                      const SizedBox(width: 6),
                                    ],
                                    _buildHeroBadge(
                                      icon: AppIcons.shield,
                                      label: 'Verified',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // STATS ROW (Orders, Spent, Addresses)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                    child: Row(
                      children: [
                        _buildStatCard(
                          isDark,
                          value: totalOrders.toString(),
                          label: 'Orders',
                        ),
                        const SizedBox(width: 8),
                        _buildStatCard(
                          isDark,
                          value: totalSpentFormatted,
                          label: 'Spent',
                        ),
                        const SizedBox(width: 8),
                        _buildStatCard(
                          isDark,
                          value: savedAddressesCount.toString(),
                          label: 'Addresses',
                        ),
                      ],
                    ),
                  ),

                  // PREFERENCES SECTION
                  _buildSectionLabel('PREFERENCES'),
                  _buildSectionContainer(
                    isDark,
                    children: [
                      ProfileRow(
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
                      ProfileRow(
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
                      ProfileRow(
                        icon: AppIcons.notification,
                        label: 'Notifications',
                        showDivider: false,
                        trailing: CupertinoSwitch(
                          value: _notificationsEnabled,
                          activeTrackColor: AppColors.flame,
                          onChanged: (val) {
                            setState(() => _notificationsEnabled = val);
                          },
                        ),
                      ),
                    ],
                  ),

                  // ACCOUNT SECTION
                  _buildSectionLabel('ACCOUNT'),
                  _buildSectionContainer(
                    isDark,
                    children: [
                      ProfileRow(
                        icon: AppIcons.pin,
                        label: 'Saved addresses',
                        trailingText: '$savedAddressesCount saved ›',
                        onTap: () => context.push('/location'),
                      ),
                      ProfileRow(
                        icon: AppIcons.card,
                        label: 'Payment methods',
                        trailingText: 'GPay ›',
                        onTap: () => context.push('/payment'),
                      ),
                      ProfileRow(
                        icon: AppIcons.gift,
                        label: 'Refer & earn',
                        trailingText: '₹100 each ›',
                        trailingColor: AppColors.flame,
                        trailingBold: true,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Referral link copied! Share with friends to earn ₹100 each.'),
                              backgroundColor: AppColors.flame,
                            ),
                          );
                        },
                      ),
                      ProfileRow(
                        icon: AppIcons.support,
                        label: 'Help & support',
                        trailingText: '›',
                        showDivider: false,
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            builder: (ctx) => Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Need help with an order?', style: AppTypography.headlineSmall),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Our POS kitchen support is online 24/7. Reach us via WhatsApp or call our kitchen dispatch hotline.',
                                    style: AppTypography.bodySmall,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.flame,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Contact Support Hotline'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  // APP INFO SECTION
                  _buildSectionLabel('APP INFO'),
                  _buildSectionContainer(
                    isDark,
                    children: [
                      const ProfileRow(
                        icon: AppIcons.info,
                        label: 'App version',
                        trailingText: 'v1.0.0',
                      ),
                      ProfileRow(
                        icon: AppIcons.document,
                        label: 'Terms & privacy',
                        trailingText: '›',
                        showDivider: false,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Terms & Privacy'),
                              content: const Text(
                                'LiveRestro connects diners directly to restaurant Point-of-Sale systems for instantaneous kitchen ticket creation, transparent live dispatch, and commission-free delivery.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // LOGOUT ROW
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: GestureDetector(
                      onTap: () => _showLogoutDialog(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : Colors.white,
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(
                            color: isDark ? AppColors.nonVeg.withValues(alpha: 0.5) : AppColors.nonVegBg,
                            width: 1.5,
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            HugeIcon(
                              icon: AppIcons.logout,
                              color: AppColors.nonVeg,
                              size: 17,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Log out',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.nonVeg,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),

            // FLOATING GLASSMORPHISM NAV BAR
            FloatingNavBar(
              currentIndex: 3,
              onTap: _onNavTap,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBadge({required List<List<dynamic>> icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.30), width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(icon: icon, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(bool isDark, {required String value, required String label}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.flame100,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.flame,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTxt2 : AppColors.txtMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: AppColors.txtMuted,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildSectionContainer(bool isDark, {required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.flame100,
          width: 1.5,
        ),
      ),
      child: Column(children: children),
    );
  }
}
