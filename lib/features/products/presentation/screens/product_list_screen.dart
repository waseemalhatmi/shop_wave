import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/product_card.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../../products/domain/entities/product_entity.dart';

/// ProductList screen — shows products filtered by category or type.
///
/// Receives optional [categoryId] and [title] via GoRouter extras.
class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({
    super.key,
    this.categoryId,
    this.title = 'Products',
  });

  final String? categoryId;
  final String title;

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  _SortOption _sort = _SortOption.newest;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    // Phase 3: Use best sellers as data source; Phase 4 adds real filtering
    final productsAsync = ref.watch(bestSellerProductsProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          widget.title == 'Products' ? (isAr ? 'المنتجات' : 'Products') : widget.title,
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.transparent,
        elevation: 0,
        actions: [
          // Filter button
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: _showFilterSheet,
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

          // ── Product Grid ──────────────────────────────────────────
          Expanded(
            child: productsAsync.when(
              loading: () => GridView.builder(
                padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  childAspectRatio: 0.72,
                ),
                itemCount: 6,
                itemBuilder: (_, __) => const SkeletonLoader(
                  child: SizedBox.expand(),
                ),
              ),
              error: (e, _) => AppErrorWidget(
                message: e.toString(),
                onRetry: () => ref.invalidate(bestSellerProductsProvider),
              ),
              data: (products) {
                final sorted = _sortProducts(products);
                return GridView.builder(
                  padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: sorted.length,
                  itemBuilder: (_, i) => ProductCard(
                    product: sorted[i],
                    wide: true,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<ProductEntity> _sortProducts(List<ProductEntity> products) {
    final list = List<ProductEntity>.from(products);
    switch (_sort) {
      case _SortOption.priceLow:
        list.sort((a, b) => a.finalPrice.compareTo(b.finalPrice));
      case _SortOption.priceHigh:
        list.sort((a, b) => b.finalPrice.compareTo(a.finalPrice));
      case _SortOption.rating:
        list.sort((a, b) => b.avgRating.compareTo(a.avgRating));
      case _SortOption.newest:
        break; // default order from API
    }
    return list;
  }

  void _showFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _FilterSheet(),
    );
  }
}

// ─── Sort Options ─────────────────────────────────────────────────────────────

enum _SortOption { newest, priceLow, priceHigh, rating }

class _SortBar extends StatelessWidget {
  const _SortBar({required this.selected, required this.onChanged});
  final _SortOption selected;
  final ValueChanged<_SortOption> onChanged;

  static const _labels = {
    _SortOption.newest: 'Newest',
    _SortOption.priceLow: 'Price ↑',
    _SortOption.priceHigh: 'Price ↓',
    _SortOption.rating: 'Top Rated',
  };

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final labels = {
      _SortOption.newest: isAr ? 'الأحدث' : 'Newest',
      _SortOption.priceLow: isAr ? 'السعر ↑' : 'Price ↑',
      _SortOption.priceHigh: isAr ? 'السعر ↓' : 'Price ↓',
      _SortOption.rating: isAr ? 'الأعلى تقييماً' : 'Top Rated',
    };

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
        ),
        children: _SortOption.values.map((opt) {
          final isSelected = opt == selected;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ChoiceChip(
              label: Text(labels[opt]!),
              selected: isSelected,
              onSelected: (_) => onChanged(opt),
              selectedColor: AppColors.primary,
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

// ─── Filter Bottom Sheet ──────────────────────────────────────────────────────

class _FilterSheet extends StatefulWidget {
  const _FilterSheet();

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  RangeValues _priceRange = const RangeValues(0, 1000);
  double _minRating = 0;

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
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
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

          // Title
          Row(
            children: [
              Text(
                isAr ? 'تصفية المنتجات' : 'Filter Products',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => setState(() {
                  _priceRange = const RangeValues(0, 1000);
                  _minRating = 0;
                }),
                child: Text(isAr ? 'إعادة تعيين' : 'Reset'),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Price Range
          Text(
            isAr 
                ? 'نطاق السعر: ${_priceRange.start.round()} ${context.l10n.general_sar} — ${_priceRange.end.round()} ${context.l10n.general_sar}'
                : 'Price Range: \$${_priceRange.start.round()} — \$${_priceRange.end.round()}',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 1000,
            divisions: 20,
            activeColor: AppColors.primary,
            onChanged: (v) => setState(() => _priceRange = v),
          ),

          const SizedBox(height: AppSpacing.md),

          // Min Rating
          Text(
            isAr 
                ? 'الحد الأدنى للتقييم: ${_minRating == 0 ? 'الكل' : '${_minRating.toStringAsFixed(1)}+'}'
                : 'Minimum Rating: ${_minRating == 0 ? 'Any' : '${_minRating.toStringAsFixed(1)}+'}',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Slider(
            value: _minRating,
            min: 0,
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
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                isAr ? 'تطبيق التصفية' : 'Apply Filters',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
