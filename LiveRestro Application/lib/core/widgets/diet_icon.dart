import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class DietIcon extends StatelessWidget {
  final bool isVeg;
  final double size;

  const DietIcon({
    super.key,
    required this.isVeg,
    this.size = 14.0,
  });

  @override
  Widget build(BuildContext context) {
    final color = isVeg ? AppColors.success : AppColors.nonVeg;
    final innerDotSize = size * 0.5;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Center(
        child: Container(
          width: innerDotSize,
          height: innerDotSize,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
