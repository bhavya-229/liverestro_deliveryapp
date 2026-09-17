import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../constants/app_colors.dart';
import '../constants/app_icons.dart';
import '../constants/app_typography.dart';
import 'animated_dot.dart';

class POSLiveIndicator extends StatelessWidget {
  final String text;
  final bool isDarkBackground;

  const POSLiveIndicator({
    super.key,
    this.text = 'Direct POS Synchronized Kitchen',
    this.isDarkBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkBackground ? Colors.white.withValues(alpha: 0.15) : AppColors.successBg,
        borderRadius: BorderRadius.circular(9),
        border: isDarkBackground ? Border.all(color: Colors.white.withValues(alpha: 0.25)) : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedDot(
            size: 6,
            color: isDarkBackground ? AppColors.posLive : AppColors.success,
          ),
          const SizedBox(width: 7),
          HugeIcon(
            icon: AppIcons.pos,
            color: isDarkBackground ? Colors.white : AppColors.success,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTypography.labelSmall.copyWith(
              color: isDarkBackground ? Colors.white : AppColors.success,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
