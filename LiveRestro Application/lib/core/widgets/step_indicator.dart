import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../constants/app_colors.dart';
import '../constants/app_icons.dart';
import '../constants/app_typography.dart';

enum StepStatus { done, active, pending }

class LiveOrderStep {
  final String title;
  final String? subtitle;
  final List<List<dynamic>> icon;
  final StepStatus status;

  const LiveOrderStep({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.status,
  });
}

class StepIndicator extends StatefulWidget {
  final List<LiveOrderStep> steps;

  const StepIndicator({
    super.key,
    required this.steps,
  });

  @override
  State<StepIndicator> createState() => _StepIndicatorState();
}

class _StepIndicatorState extends State<StepIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(widget.steps.length, (idx) {
        final step = widget.steps[idx];
        final isLast = idx == widget.steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column: Node and connector
            Column(
              children: [
                _buildNode(step),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 38,
                    color: step.status == StepStatus.done ? AppColors.flame : AppColors.flame100,
                  ),
              ],
            ),
            const SizedBox(width: 14),
            // Right content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: AppTypography.labelLarge.copyWith(
                        color: step.status == StepStatus.pending
                            ? AppColors.txtMuted
                            : (step.status == StepStatus.active ? AppColors.flame : AppColors.txtPrimary),
                        fontWeight: step.status == StepStatus.pending ? FontWeight.w600 : FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    if (step.subtitle != null && step.subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        step.subtitle!,
                        style: AppTypography.bodySmall.copyWith(
                          color: step.status == StepStatus.active ? AppColors.flameMedium : AppColors.txtMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildNode(LiveOrderStep step) {
    switch (step.status) {
      case StepStatus.done:
        return Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: AppColors.flame,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: HugeIcon(
              icon: AppIcons.checkmark,
              color: Colors.white,
              size: 14,
            ),
          ),
        );
      case StepStatus.active:
        return AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) => Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.flame50,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.flame, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.flame.withValues(alpha: 0.4),
                  blurRadius: _glowAnimation.value,
                  spreadRadius: _glowAnimation.value * 0.3,
                ),
              ],
            ),
            child: Center(
              child: HugeIcon(
                icon: step.icon,
                color: AppColors.flame,
                size: 14,
              ),
            ),
          ),
        );
      case StepStatus.pending:
        return Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.flame100, width: 2),
          ),
          child: Center(
            child: HugeIcon(
              icon: step.icon,
              color: AppColors.txtMuted,
              size: 14,
            ),
          ),
        );
    }
  }
}
