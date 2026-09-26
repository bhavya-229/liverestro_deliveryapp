import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_typography.dart';
import '../models/search_result.dart';

class SearchResultItem extends StatelessWidget {
  final SearchResult result;
  final String query;
  final VoidCallback onTap;

  const SearchResultItem({
    super.key,
    required this.result,
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRestaurant = result.type == SearchResultType.restaurant;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.flame50,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // ICON CONTAINER (40x40, radius: 11)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: isRestaurant ? AppColors.heroGradient : null,
                color: isRestaurant
                    ? null
                    : (isDark ? AppColors.darkCard : AppColors.flame50),
                borderRadius: BorderRadius.circular(11),
                border: isRestaurant
                    ? null
                    : Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.flame100,
                        width: 1.5,
                      ),
              ),
              child: Center(
                child: HugeIcon(
                  icon: isRestaurant ? AppIcons.store : AppIcons.food,
                  color: isRestaurant ? Colors.white : AppColors.flame,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 11),

            // CENTER: HIGHLIGHTED NAME & SUBTITLE
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHighlightedTitle(context, isDark),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      HugeIcon(
                        icon: isRestaurant ? AppIcons.store : AppIcons.restaurant,
                        color: AppColors.txtMuted,
                        size: 11,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          result.subtitle,
                          style: AppTypography.bodySmall.copyWith(
                            fontSize: 10,
                            color: AppColors.txtMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // TRAILING: PRICE & DELIVERY TIME
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  result.price,
                  style: AppTypography.priceTagSmall.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const HugeIcon(
                      icon: AppIcons.clock,
                      color: AppColors.txtMuted,
                      size: 10,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      result.deliveryTime,
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: 9,
                        color: AppColors.txtMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightedTitle(BuildContext context, bool isDark) {
    final lowerName = result.name.toLowerCase();
    final lowerQ = query.trim().toLowerCase();

    final baseStyle = AppTypography.labelLarge.copyWith(
      color: isDark ? AppColors.darkTxt : AppColors.txtPrimary,
      fontWeight: FontWeight.w700,
    );

    if (lowerQ.isEmpty || !lowerName.contains(lowerQ)) {
      return Text(
        result.name,
        style: baseStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final startIndex = lowerName.indexOf(lowerQ);
    final endIndex = startIndex + lowerQ.length;

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: baseStyle,
        children: [
          if (startIndex > 0)
            TextSpan(text: result.name.substring(0, startIndex)),
          TextSpan(
            text: result.name.substring(startIndex, endIndex),
            style: TextStyle(
              backgroundColor: isDark
                  ? AppColors.flame.withValues(alpha: 0.3)
                  : AppColors.flame50,
              color: AppColors.flame,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (endIndex < result.name.length)
            TextSpan(text: result.name.substring(endIndex)),
        ],
      ),
    );
  }
}
