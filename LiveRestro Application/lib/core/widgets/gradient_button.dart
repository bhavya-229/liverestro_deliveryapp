import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';

class GradientButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final List<List<dynamic>>? leadingIcon;
  final List<List<dynamic>>? trailingIcon;
  final bool isLoading;
  final bool isEnabled;
  final double? width;
  final double height;
  final LinearGradient? gradient;

  const GradientButton({
    super.key,
    required this.label,
    required this.onTap,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
    this.height = AppSpacing.buttonHeight,
    this.gradient,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bool canTap = widget.isEnabled && !widget.isLoading && widget.onTap != null;

    return GestureDetector(
      onTapDown: canTap ? (_) => setState(() => _pressed = true) : null,
      onTapUp: canTap ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: canTap ? () => setState(() => _pressed = false) : null,
      onTap: canTap ? widget.onTap : null,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedOpacity(
          opacity: _pressed ? 0.90 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            height: widget.height,
            width: widget.width ?? double.infinity,
            decoration: BoxDecoration(
              gradient: widget.isEnabled ? (widget.gradient ?? AppColors.ctaGradient) : null,
              color: widget.isEnabled ? null : AppColors.flame100,
              borderRadius: AppSpacing.buttonRadius,
              boxShadow: widget.isEnabled
                  ? [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.leadingIcon != null) ...[
                          HugeIcon(
                            icon: widget.leadingIcon!,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.label,
                          style: AppTypography.ctaButton.copyWith(
                            color: widget.isEnabled ? Colors.white : Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                        if (widget.trailingIcon != null) ...[
                          const SizedBox(width: 8),
                          HugeIcon(
                            icon: widget.trailingIcon!,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
