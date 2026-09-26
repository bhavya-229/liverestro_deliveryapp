import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../constants/app_colors.dart';
import '../constants/app_icons.dart';
import '../constants/app_typography.dart';
import 'animated_dot.dart';

class FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool hasActiveOrder;

  const FloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.hasActiveOrder = false,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      bottom: 16 + bottomInset,
      left: 0,
      right: 0,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard.withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(36),
                border: Border.all(
                  color: AppColors.flame.withValues(alpha: 0.22),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildNavItem(icon: AppIcons.home, label: 'Home', index: 0),
                  _buildNavItem(icon: AppIcons.search, label: 'Search', index: 1),
                  _buildNavItem(icon: AppIcons.orders, label: 'Orders', index: 2),
                  _buildNavItem(icon: AppIcons.profile, label: 'Profile', index: 3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required List<List<dynamic>> icon,
    required String label,
    required int index,
  }) {
    final bool isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 18 : 14,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                HugeIcon(
                  icon: icon,
                  color: isActive ? Colors.white : AppColors.txtMuted,
                  size: 20,
                ),
                if (index == 2 && hasActiveOrder)
                  const Positioned(
                    top: -1,
                    right: -3,
                    child: AnimatedDot(
                      size: 6,
                      color: AppColors.accent,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: isActive ? Colors.white : AppColors.txtMuted,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
