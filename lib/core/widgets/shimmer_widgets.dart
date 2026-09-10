import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_colors.dart';

/// A shimmer-style animated loading placeholder that pulses while content loads.
///
/// Uses [flutter_animate]'s shimmer effect for a premium skeleton loader
/// experience — superior to simple grey boxes.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.primary.withValues(alpha: 0.08)
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    ).animate(onPlay: (c) => c.repeat()).shimmer(
          duration: 1200.ms,
          color: isDark
              ? AppColors.primary.withValues(alpha: 0.15)
              : Colors.grey.shade100,
        );
  }
}

/// Animated product card skeleton for grid/list loading states.
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerBox(width: double.infinity, height: 160, borderRadius: 16),
        const SizedBox(height: 8),
        const ShimmerBox(width: 120, height: 14),
        const SizedBox(height: 6),
        const ShimmerBox(width: 80, height: 14),
      ],
    );
  }
}

/// Animated order card skeleton.
class OrderCardSkeleton extends StatelessWidget {
  const OrderCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerBox(width: 80, height: 14),
              Spacer(),
              ShimmerBox(width: 60, height: 22, borderRadius: 20),
            ],
          ),
          SizedBox(height: 12),
          ShimmerBox(width: double.infinity, height: 12),
          SizedBox(height: 6),
          ShimmerBox(width: 160, height: 12),
        ],
      ),
    );
  }
}
