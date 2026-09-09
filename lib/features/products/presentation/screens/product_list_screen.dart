import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/product_card.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../products/domain/repositories/products_repository.dart';
import '../providers/products_providers.dart';

/// ProductList screen — displays products filtered by category, promotion type,
/// price range, and minimum rating with server-driven Supabase querying and sorting.
class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({
    super.key,
    this.categoryId,
    this.filter,
    this.title = 'Products',
  });

  final String? categoryId;
  final String? filter;
  final String title;

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  ProductSortOption _sort = ProductSortOption.newest;
  RangeValues _priceRange = const RangeValues(0, 1000);
  double _minRating = 0;

  bool get _hasActiveFilters =>
      _priceRange.start > 0 || _priceRange.end < 1000 || _minRating > 0;

  int get _activeFiltersCount {
    var count = 0;
    if (_priceRange.start > 0 || _priceRange.end < 1000) count++;
    if (_minRating > 0) count++;
    return count;
  }

  ProductFilterParams get _filterParams => ProductFilterParams(
        categoryId: widget.categoryId,
        filterType: widget.filter,
        minPrice: _priceRange.start > 0 ? _priceRange.start : null,
        maxPrice: _priceRange.end < 1000 ? _priceRange.end : null,
        minRating: _minRating > 0 ? _minRating : null,
        sortBy: _sort,
      );

  void _resetFilters() {
    setState(() {
      _priceRange = const RangeValues(0, 1000);
      _minRating = 0;
    });
  }

  String _resolveTitle(bool isAr) {
    if (widget.title != 'Products' && widget.title.isNotEmpty) {
      return widget.title;
    }
    switch (widget.filter) {
      case 'flash_deals':
        return isAr ? '⚡ عروض سريعة' : '⚡ Flash Deals';
      case 'featured':
        return isAr ? '⭐ منتجات مميزة' : '⭐ Featured Products';
      case 'best_sellers':
        return isAr ? '🏆 الأكثر مبيعاً' : '🏆 Best Sellers';
      case 'new_arrivals':
        return isAr ? '🆕 وصل حديثاً' : '🆕 New Arrivals';
      default:
        return isAr ? 'المنتجات' : 'Products';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final productsAsync = ref.watch(filteredProductsProvider(_filterParams));

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          _resolveTitle(isAr),
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.transparent,
        elevation: 0,
        actions: [
          // Filter button with badge indicating active filters count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: IconButton(
              icon: Badge(
                isLabelVisible: _hasActiveFilters,
                label: Text(
                  '$_activeFiltersCount',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.tune_rounded),
              ),
              onPressed: _showFilterSheet,
              tooltip: isAr ? 'تصفية المنتجات' : 'Filter Products',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Sort Bar ──────────────────────────────────────────────
          _SortBar(
            selected: _sort,
            onChanged: (s) => setState(() => _sort = s),
          ),

          // ── Active Filters Indicator ──────────────────────────────
          if (_hasActiveFilters)
            _ActiveFilterPills(
              priceRange: _priceRange,
              minRating: _minRating,
              onClearPrice: () =>
                  setState(() => _priceRange = const RangeValues(0, 1000)),
              onClearRating: () => setState(() => _minRating = 0),
              onClearAll: _resetFilters,
            ),

          // ── Product Grid ──────────────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () =>
                  ref.refresh(filteredProductsProvider(_filterParams).future),
              child: productsAsync.when(
                loading: () => GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) => const SkeletonLoader(
                    child: SizedBox.expand(),
                  ),
                ),
                error: (e, _) => AppErrorWidget(
                  message: e.toString(),
                  onRetry: () =>
                      ref.invalidate(filteredProductsProvider(_filterParams)),
                ),
                data: (products) {
                  if (products.isEmpty) {
                    return _EmptyProductCatalog(
                      hasFilters: _hasActiveFilters,
                      onResetFilters: _resetFilters,
                    );
                  }

                  return GridView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: products.length,
                    itemBuilder: (_, i) => ProductCard(
                      product: products[i],
                      wide: true,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(
        initialPriceRange: _priceRange,
        initialMinRating: _minRating,
        onApply: (range, rating) {
          setState(() {
            _priceRange = range;
            _minRating = rating;
          });
        },
      ),
    );
  }
}

// ─── Sort Bar ─────────────────────────────────────────────────────────────────

class _SortBar extends StatelessWidget {
  const _SortBar({required this.selected, required this.onChanged});
  final ProductSortOption selected;
  final ValueChanged<ProductSortOption> onChanged;

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final labels = {
      ProductSortOption.newest: isAr ? 'الأحدث' : 'Newest',
      ProductSortOption.priceLow: isAr ? 'السعر: الأقل' : 'Price: Low to High',
      ProductSortOption.priceHigh: isAr ? 'السعر: الأعلى' : 'Price: High to Low',
      ProductSortOption.rating: isAr ? 'الأعلى تقييماً' : 'Top Rated',
    };

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
          vertical: 4,
        ),
        children: ProductSortOption.values.map((opt) {
          final isSelected = opt == selected;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ChoiceChip(
              label: Text(labels[opt]!),
              selected: isSelected,
              onSelected: (_) => onChanged(opt),
              selectedColor: AppColors.primary,
              backgroundColor: Theme.of(context).cardColor,
              labelStyle: TextStyle(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: isSelected ? AppColors.white : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Active Filter Pills ──────────────────────────────────────────────────────

class _ActiveFilterPills extends StatelessWidget {
  const _ActiveFilterPills({
    required this.priceRange,
    required this.minRating,
    required this.onClearPrice,
    required this.onClearRating,
    required this.onClearAll,
  });

  final RangeValues priceRange;
  final double minRating;
  final VoidCallback onClearPrice;
  final VoidCallback onClearRating;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final hasPrice = priceRange.start > 0 || priceRange.end < 1000;
    final hasRating = minRating > 0;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: 4,
      ),
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (hasPrice)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Chip(
                padding: EdgeInsets.zero,
                labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                label: Text(
                  isAr
                      ? '${priceRange.start.round()} - ${priceRange.end.round()} ${context.l10n.general_sar}'
                      : '${priceRange.start.round()} - ${priceRange.end.round()} SAR',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
                deleteIcon: const Icon(Icons.close, size: 14),
                onDeleted: onClearPrice,
              ),
            ),
          if (hasRating)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Chip(
                padding: EdgeInsets.zero,
                labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                backgroundColor: AppColors.star.withValues(alpha: 0.18),
                label: Text(
                  '★ ${minRating.toStringAsFixed(1)}+',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
                deleteIcon: const Icon(Icons.close, size: 14),
                onDeleted: onClearRating,
              ),
            ),
          ActionChip(
            padding: EdgeInsets.zero,
            labelPadding: const EdgeInsets.symmetric(horizontal: 8),
            label: Text(
              isAr ? 'مسح الكل' : 'Clear All',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.badge,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: onClearAll,
          ),
        ],
      ),
    );
  }
}

// ─── Empty Product Catalog ────────────────────────────────────────────────────

class _EmptyProductCatalog extends StatelessWidget {
  const _EmptyProductCatalog({
    required this.hasFilters,
    required this.onResetFilters,
  });

  final bool hasFilters;
  final VoidCallback onResetFilters;

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                hasFilters
                    ? (isAr
                        ? 'لا توجد منتجات تطابق خيارات التصفية'
                        : 'No products match your filters')
                    : (isAr
                        ? 'لا توجد منتجات متوفرة حالياً'
                        : 'No products available right now'),
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                hasFilters
                    ? (isAr
                        ? 'جرّب تعديل نطاق السعر أو الحد الأدنى للتقييم'
                        : 'Try adjusting your price range or minimum rating')
                    : (isAr
                        ? 'يرجى مراجعة هذا القسم لاحقاً'
                        : 'Please check back later'),
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              if (hasFilters)
                ElevatedButton.icon(
                  onPressed: onResetFilters,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(isAr ? 'إعادة تعيين الفلاتر' : 'Reset Filters'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Filter Bottom Sheet ──────────────────────────────────────────────────────

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.initialPriceRange,
    required this.initialMinRating,
    required this.onApply,
  });

  final RangeValues initialPriceRange;
  final double initialMinRating;
  final void Function(RangeValues range, double minRating) onApply;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late RangeValues _priceRange;
  late double _minRating;

  @override
  void initState() {
    super.initState();
    _priceRange = widget.initialPriceRange;
    _minRating = widget.initialMinRating;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.lg,
        AppSpacing.screenHorizontal,
        MediaQuery.paddingOf(context).bottom + AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Title & Reset
          Row(
            children: [
              Text(
                isAr ? 'تصفية المنتجات' : 'Filter Products',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Outfit',
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => setState(() {
                  _priceRange = const RangeValues(0, 1000);
                  _minRating = 0;
                }),
                child: Text(
                  isAr ? 'إعادة تعيين' : 'Reset',
                  style: const TextStyle(color: AppColors.badge),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Price Range
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isAr ? 'نطاق السعر:' : 'Price Range:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                isAr
                    ? '${_priceRange.start.round()} — ${_priceRange.end.round()} ${context.l10n.general_sar}'
                    : '${_priceRange.start.round()} — ${_priceRange.end.round()} SAR',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          RangeSlider(
            values: _priceRange,
            max: 1000,
            divisions: 20,
            activeColor: AppColors.primary,
            labels: RangeLabels(
              '${_priceRange.start.round()}',
              '${_priceRange.end.round()}',
            ),
            onChanged: (v) => setState(() => _priceRange = v),
          ),

          const SizedBox(height: AppSpacing.md),

          // Min Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isAr ? 'الحد الأدنى للتقييم:' : 'Minimum Rating:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _minRating == 0
                    ? (isAr ? 'الكل' : 'Any')
                    : '★ ${_minRating.toStringAsFixed(1)}+',
                style: const TextStyle(
                  color: AppColors.star,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Slider(
            value: _minRating,
            max: 5,
            divisions: 10,
            activeColor: AppColors.star,
            onChanged: (v) => setState(() => _minRating = v),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(_priceRange, _minRating);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                isAr ? 'تطبيق التصفية' : 'Apply Filters',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
