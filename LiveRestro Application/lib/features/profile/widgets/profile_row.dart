import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

class ProfileRow extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;
  final String? trailingText;
  final Color? trailingColor;
  final bool trailingBold;
  final bool showDivider;

  const ProfileRow({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.trailing,
    this.trailingText,
    this.trailingColor,
    this.trailingBold = false,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          border: showDivider
              ? Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.flame50,
                    width: 1,
                  ),
                )
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Icon container (32x32, radius 9)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.flame50,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Center(
                child: HugeIcon(
                  icon: icon,
                  color: AppColors.flame,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(width: 11),

            // Label
            Expanded(
              child: Text(
                label,
                style: AppTypography.labelLarge.copyWith(
                  color: isDark ? AppColors.darkTxt : AppColors.txtPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),

            // Trailing
            ?trailing,
            if (trailingText != null)
              Text(
                trailingText!,
                style: AppTypography.bodySmall.copyWith(
                  color: trailingColor ?? AppColors.txtMuted,
                  fontWeight: trailingBold ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
