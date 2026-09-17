import 'package:flutter/material.dart';
import '../constants/app_typography.dart';

enum OfferBannerVariant { flame, green, red }

class OfferBannerCard extends StatefulWidget {
  final String tag;
  final String headline;
  final String couponCode;
  final OfferBannerVariant variant;
  final VoidCallback? onTap;

  const OfferBannerCard({
    super.key,
    required this.tag,
    required this.headline,
    required this.couponCode,
    this.variant = OfferBannerVariant.flame,
    this.onTap,
  });

  @override
  State<OfferBannerCard> createState() => _OfferBannerCardState();
}

class _OfferBannerCardState extends State<OfferBannerCard> {
  bool _pressed = false;

  LinearGradient get _gradient {
    switch (widget.variant) {
      case OfferBannerVariant.flame:
        return const LinearGradient(
          colors: [Color(0xFFCC2D00), Color(0xFFFF4500)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
      case OfferBannerVariant.green:
        return const LinearGradient(
          colors: [Color(0xFF13361A), Color(0xFF16A34A)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
      case OfferBannerVariant.red:
        return const LinearGradient(
          colors: [Color(0xFF381212), Color(0xFFDC2626)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: 230,
          height: 86,
          decoration: BoxDecoration(
            gradient: _gradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Decorative circle
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.09),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.tag.toUpperCase(),
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 9,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.headline,
                      style: AppTypography.headlineSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.couponCode,
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.80),
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
