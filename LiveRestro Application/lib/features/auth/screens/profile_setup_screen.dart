import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/gradient_button.dart';
import '../providers/auth_provider.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _promoController = TextEditingController();

  bool _isPureVeg = false;
  bool _isPromoApplied = false;
  String? _appliedPromoCode;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  void _onApplyPromo() {
    final code = _promoController.text.trim().toUpperCase();
    if (code.isNotEmpty) {
      setState(() {
        _isPromoApplied = true;
        _appliedPromoCode = code;
      });
    }
  }

  void _onSaveAndContinue() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name')),
      );
      return;
    }

    await ref.read(authProvider.notifier).completeRegistration(
      name: name,
      email: _emailController.text.trim(),
      isVegOnly: _isPureVeg,
      couponCode: _appliedPromoCode,
    );

    if (!mounted) return;
    context.go('/location');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Column(
        children: [
          // GRADIENT HEADER
          Container(
            height: 90,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(12, 36, 16, 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/login');
                    }
                  },
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.20),
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
                const SizedBox(width: 14),
                Text(
                  'Set up your profile',
                  style: AppTypography.headlineSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ),

          // FORM CONTENT
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Full name label & field
                  Row(
                    children: [
                      const HugeIcon(
                        icon: AppIcons.user,
                        color: AppColors.flame,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Full name',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.flame,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nameController,
                    style: AppTypography.bodyLarge,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Aarav Patel',
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Email label & field
                  Row(
                    children: [
                      const HugeIcon(
                        icon: AppIcons.email,
                        color: AppColors.flame,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Email (optional)',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.flame,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: AppTypography.bodyLarge,
                    decoration: const InputDecoration(
                      hintText: 'e.g. aarav@example.com',
                    ),
                  ),

                  const SizedBox(height: 18),

                  // VEG MODE CARD
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.flame100, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.successBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: HugeIcon(
                              icon: AppIcons.leaf,
                              color: AppColors.success,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pure Veg Mode',
                                style: AppTypography.labelLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Show only vegetarian options',
                                style: AppTypography.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        CupertinoSwitch(
                          value: _isPureVeg,
                          activeTrackColor: AppColors.success,
                          onChanged: (val) {
                            setState(() => _isPureVeg = val);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // PROMO CODE ACCORDION
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.flame200, width: 1.5),
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        title: Row(
                          children: [
                            const HugeIcon(
                              icon: AppIcons.coupon,
                              color: AppColors.flame,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Have a referral or coupon code?',
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.flame,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _promoController,
                                        style: AppTypography.labelLarge,
                                        textCapitalization: TextCapitalization.characters,
                                        decoration: const InputDecoration(
                                          hintText: 'Enter code (e.g. WELCOME100)',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: _onApplyPromo,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.flame,
                                        minimumSize: const Size(80, 48),
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                      ),
                                      child: const Text('Apply', style: TextStyle(fontSize: 13)),
                                    ),
                                  ],
                                ),
                                if (_isPromoApplied) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const HugeIcon(
                                        icon: AppIcons.checkCircle,
                                        color: AppColors.success,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Code "$_appliedPromoCode" applied successfully!',
                                        style: AppTypography.labelSmall.copyWith(
                                          color: AppColors.success,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // CTA BUTTON
                  GradientButton(
                    label: 'Start Exploring Food →',
                    isLoading: authState.isLoading,
                    onTap: _onSaveAndContinue,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
