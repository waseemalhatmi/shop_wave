import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'animated_tap_scale.dart';

/// A polished, reusable empty-state widget with icon animation, descriptive
/// copy, and an optional CTA button.
///
/// Uses [flutter_animate] for entrance animations: fade-in + slide-up.
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.iconColor,
    this.iconSize = 80,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = iconColor ?? AppColors.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Animated Icon ────────────────────────────────────────
            Container(
              width: iconSize + 40,
              height: iconSize + 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: color.withValues(alpha: 0.55),
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.7, 0.7),
                  end: const Offset(1.0, 1.0),
                  duration: 500.ms,
                  curve: Curves.elasticOut,
                )
                .fade(duration: 300.ms),
            const SizedBox(height: AppSpacing.xl),

            // ── Title ───────────────────────────────────────────────
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight,
              ),
              textAlign: TextAlign.center,
            )
                .animate(delay: 150.ms)
                .fade(duration: 400.ms)
                .slideY(begin: 0.3, end: 0, duration: 400.ms, curve: Curves.easeOut),

            // ── Subtitle ────────────────────────────────────────────
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle!,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 14,
                  color: isDark
                      ? AppColors.onSurfaceVariantDark
                      : AppColors.onSurfaceVariantLight,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              )
                  .animate(delay: 250.ms)
                  .fade(duration: 400.ms)
                  .slideY(begin: 0.3, end: 0, duration: 400.ms),
            ],

            // ── CTA Button ──────────────────────────────────────────
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              AnimatedTapScale(
                onTap: onAction!,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Text(
                    actionLabel!,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.white,
                    ),
                  ),
                ),
              )
                  .animate(delay: 350.ms)
                  .fade(duration: 400.ms)
                  .slideY(begin: 0.4, end: 0, duration: 400.ms, curve: Curves.easeOut),
            ],
          ],
        ),
      ),
    );
  }
}
