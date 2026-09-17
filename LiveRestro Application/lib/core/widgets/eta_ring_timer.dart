import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

class ETARingTimer extends StatefulWidget {
  final int totalMinutes;
  final int remainingMinutes;
  final double size;

  const ETARingTimer({
    super.key,
    this.totalMinutes = 30,
    required this.remainingMinutes,
    this.size = 160.0,
  });

  @override
  State<ETARingTimer> createState() => _ETARingTimerState();
}

class _ETARingTimerState extends State<ETARingTimer> with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseScaleAnimation;
  late Animation<double> _pulseOpacityAnimation;

  @override
  void initState() {
    super.initState();

    final targetProgress = widget.totalMinutes > 0
        ? ((widget.totalMinutes - widget.remainingMinutes) / widget.totalMinutes).clamp(0.05, 1.0)
        : 0.5;

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: targetProgress).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOut),
    );
    _progressController.forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _pulseScaleAnimation = Tween<double>(begin: 1.0, end: 1.07).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseOpacityAnimation = Tween<double>(begin: 0.55, end: 0.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant ETARingTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.remainingMinutes != widget.remainingMinutes) {
      final targetProgress = widget.totalMinutes > 0
          ? ((widget.totalMinutes - widget.remainingMinutes) / widget.totalMinutes).clamp(0.05, 1.0)
          : 0.5;
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: targetProgress,
      ).animate(
        CurvedAnimation(parent: _progressController, curve: Curves.easeOut),
      );
      _progressController.reset();
      _progressController.forward();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulse Outer Ring
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) => Transform.scale(
              scale: _pulseScaleAnimation.value,
              child: Container(
                width: widget.size + 14,
                height: widget.size + 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.flame.withValues(alpha: _pulseOpacityAnimation.value),
                    width: 2.5,
                  ),
                ),
              ),
            ),
          ),

          // Arc Ring via CustomPainter
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) => CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _ETARingPainter(
                progress: _progressAnimation.value,
                strokeWidth: 10.0,
              ),
            ),
          ),

          // Center ETA Minutes Content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${widget.remainingMinutes}',
                style: AppTypography.displayLarge.copyWith(
                  color: AppColors.flame,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'minutes',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.txtMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ETARingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;

  _ETARingPainter({
    required this.progress,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth / 2;

    // Background track ring
    final bgPaint = Paint()
      ..color = AppColors.flame100
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    // Gradient progress arc
    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final sweepAngle = 2 * math.pi * progress;
      const startAngle = -math.pi / 2;

      final gradient = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
        colors: const [AppColors.flameDark, AppColors.flame, AppColors.mango],
        stops: const [0.0, 0.5, 1.0],
      );

      final progressPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ETARingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.strokeWidth != strokeWidth;
  }
}
