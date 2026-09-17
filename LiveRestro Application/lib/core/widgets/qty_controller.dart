import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../constants/app_colors.dart';
import '../constants/app_icons.dart';
import '../constants/app_typography.dart';

class QtyController extends StatelessWidget {
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final bool isCustomizable;

  const QtyController({
    super.key,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
    this.isCustomizable = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
      child: quantity == 0
          ? InkWell(
              key: const ValueKey('zero_btn'),
              onTap: onAdd,
              borderRadius: BorderRadius.circular(7),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.flame,
                  borderRadius: BorderRadius.circular(7),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.flame.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isCustomizable ? 'ADD +' : '+ ADD',
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Container(
              key: const ValueKey('counter_box'),
              decoration: BoxDecoration(
                color: AppColors.flame,
                borderRadius: BorderRadius.circular(7),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.flame.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: onRemove,
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(7)),
                    child: const SizedBox(
                      width: 32,
                      height: 30,
                      child: Center(
                        child: HugeIcon(
                          icon: AppIcons.remove,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    constraints: const BoxConstraints(minWidth: 20),
                    alignment: Alignment.center,
                    child: Text(
                      '$quantity',
                      style: AppTypography.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: onAdd,
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(7)),
                    child: const SizedBox(
                      width: 32,
                      height: 30,
                      child: Center(
                        child: HugeIcon(
                          icon: AppIcons.add,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
