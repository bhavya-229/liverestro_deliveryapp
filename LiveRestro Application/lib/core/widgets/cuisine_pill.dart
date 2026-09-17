import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../constants/app_colors.dart';
import '../constants/app_icons.dart';
import '../constants/app_typography.dart';

class CuisinePill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final List<List<dynamic>>? customIcon;

  const CuisinePill({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.customIcon,
  });

  List<List<dynamic>> get _icon {
    if (customIcon != null) return customIcon!;
    switch (label.toLowerCase()) {
      case 'all':
        return AppIcons.restaurant;
      case 'gujarati':
      case 'kathiyawadi':
      case 'thali':
        return AppIcons.pot;
      case 'punjabi':
        return AppIcons.food;
      case 'burgers':
        return AppIcons.burger;
      case 'pizzas':
        return AppIcons.pizza;
      case 'south indian':
        return AppIcons.leaf;
      default:
        return AppIcons.food;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, isSelected ? -1 : 0, 0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.flame : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.flame : AppColors.flame100,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.flame.withValues(alpha: 0.30),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(
              icon: _icon,
              color: isSelected ? Colors.white : AppColors.flameMedium,
              size: 15,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.flameMedium,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
