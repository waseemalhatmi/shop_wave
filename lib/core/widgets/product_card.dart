import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/extensions/context_ext.dart';
import '../../../features/products/domain/entities/product_entity.dart';
import '../../../features/favorites/presentation/providers/favorites_providers.dart';

/// Reusable product card used across Home, Categories, Search, etc.
///
/// Two variants:
/// - Default (vertical) — used in horizontal scrolling lists
/// - Wide — used in grid views (set [wide] = true)
class ProductCard extends ConsumerWidget {
  const ProductCard({
    required this.product,
    super.key,
    this.wide = false,
    this.onFavoriteToggle,
    this.isFavorite,
  });

  final ProductEntity product;
  final bool wide;
  final VoidCallback? onFavoriteToggle;
  final bool? isFavorite;

  static const double _cardWidth = 160;
  static const double _imageHeight = 125;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Use passed isFavorite or watch from providers
    final bool favoriteStatus = isFavorite ?? ref.watch(isFavoriteProvider(product.id));

    // Use passed onFavoriteToggle or default to toggling the provider
    final toggleAction = onFavoriteToggle ??
        () {
          ref.read(favoritesProvider.notifier).toggleFavorite(product);
        };

    final Widget imageWidget = Stack(
      children: [
        if (wide)
          Positioned.fill(
            child: _ProductImage(
              imageUrl: product.primaryImageUrl,
              height: double.infinity,
              wide: wide,
            ),
          )
        else
          _ProductImage(
            imageUrl: product.primaryImageUrl,
            height: _imageHeight,
            wide: wide,
          ),
        // Discount Badge
        if (product.hasDiscount)
          Positioned(
            top: AppSpacing.xs,
            left: AppSpacing.xs,
            child: _DiscountBadge(percent: product.discountPercenti),
          ),
        // Favorite Button
        Positioned(
          top: AppSpacing.xs,
          right: AppSpacing.xs,
          child: _FavoriteButton(
            isFavorite: favoriteStatus,
            onTap: toggleAction,
          ),
        ),
        // New Badge
        if (product.isNewArrival && !product.hasDiscount)
          Positioned(
            top: AppSpacing.xs,
            left: AppSpacing.xs,
            child: _NewBadge(),
          ),
      ],
    );

    return GestureDetector(
      onTap: () => context.push(
        AppRoutes.productDetailPath(product.id),
      ),
      child: Container(
        width: wide ? null : _cardWidth,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark ? AppColors.shadowDark : AppColors.shadowLight,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Product Image ─────────────────────────────────────
              if (wide)
                Expanded(child: imageWidget)
              else
                imageWidget,

              // ── Product Info ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name
                    Text(
                      product.localizedName(Localizations.localeOf(context).languageCode),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Rating
                    if (product.avgRating > 0) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: AppColors.star,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            product.avgRating.toStringAsFixed(1),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.star,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${product.reviewCount})',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                    ],

                    // Price wrap
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: AppSpacing.xs,
                      runSpacing: 2,
                      children: [
                        Text(
                          '${product.finalPrice.toStringAsFixed(2)} ${context.l10n.general_sar}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (product.hasDiscount)
                          Text(
                            '${product.basePrice.toStringAsFixed(2)} ${context.l10n.general_sar}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: AppColors.originalPrice,
                            ),
                          ),
                      ],
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

// ─── Private Widgets ─────────────────────────────────────────────────────────

class _ProductImage extends StatelessWidget {
  const _ProductImage({
    required this.imageUrl,
    required this.height,
    required this.wide,
  });

  final String? imageUrl;
  final double height;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _PlaceholderImage(height: height, wide: wide);
    }
    return Image.network(
      imageUrl!,
      height: height,
      width: wide ? double.infinity : null,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          _PlaceholderImage(height: height, wide: wide),
      loadingBuilder: (_, child, progress) => progress == null
          ? child
          : _PlaceholderImage(height: height, wide: wide),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  const _PlaceholderImage({required this.height, required this.wide});
  final double height;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: height,
      width: wide ? double.infinity : null,
      color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 40,
          color: isDark
              ? AppColors.onSurfaceVariantDark
              : AppColors.onSurfaceVariantLight,
        ),
      ),
    );
  }
}

class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge({required this.percent});
  final int percent;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.badge,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          '-$percent%',
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}

class _NewBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isAr ? 'جديد' : 'NEW',
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({this.isFavorite = false, this.onTap});
  final bool isFavorite;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.85),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            size: 18,
            color: isFavorite ? AppColors.badge : AppColors.onSurfaceVariantLight,
          ),
        ),
      );
}
