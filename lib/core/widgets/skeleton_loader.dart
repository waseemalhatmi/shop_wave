import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Skeleton loading shimmer effect used across the app.
///
/// Why shimmer instead of a spinner?
/// Skeleton loaders communicate the expected layout before content loads.
/// This reduces perceived loading time and improves UX significantly.
/// Studies show skeleton screens feel ~24% faster than spinners.
class SkeletonLoader extends StatefulWidget {
  const SkeletonLoader({
    super.key,
    required this.child,
    this.isLoading = true,
  });

  final Widget child;
  final bool isLoading;

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return widget.child;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        isDark ? AppColors.skeletonBaseDark : AppColors.skeletonBase;
    final highlightColor =
        isDark ? AppColors.skeletonHighlightDark : AppColors.skeletonHighlight;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) => ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [baseColor, highlightColor, baseColor],
          stops: const [0.0, 0.5, 1.0],
          transform: _SlideGradientTransform(_animation.value),
        ).createShader(bounds),
        blendMode: BlendMode.srcATop,
        child: widget.child,
      ),
    );
  }
}

/// A single skeleton box — the building block for all skeleton layouts.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = AppSpacing.sm,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.skeletonBaseDark : AppColors.skeletonBase,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Skeleton for a product card.
class SkeletonProductCard extends StatelessWidget {
  const SkeletonProductCard({super.key});

  @override
  Widget build(BuildContext context) => const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(height: 160, borderRadius: 12),
          SizedBox(height: AppSpacing.sm),
          SkeletonBox(width: 120),
          SizedBox(height: AppSpacing.xs),
          SkeletonBox(width: 80, height: 12),
          SizedBox(height: AppSpacing.xs),
          SkeletonBox(width: 60, height: 14),
        ],
      );
}

/// Skeleton for a list tile.
class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            const SkeletonBox(width: 56, height: 56, borderRadius: 8),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonBox(),
                  const SizedBox(height: AppSpacing.xs),
                  SkeletonBox(width: MediaQuery.sizeOf(context).width * 0.4),
                ],
              ),
            ),
          ],
        ),
      );
}

// ── Helper ────────────────────────────────────────────────────────────────
class _SlideGradientTransform extends GradientTransform {
  const _SlideGradientTransform(this.slidePercent);
  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * slidePercent, 0, 0);
}
