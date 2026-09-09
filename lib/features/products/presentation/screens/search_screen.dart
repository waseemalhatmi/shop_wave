import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/product_card.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../../products/domain/repositories/products_repository.dart';
import '../providers/search_providers.dart';

/// Production-grade Search Screen featuring real-time Supabase querying,
/// keystroke debounce, local search history (Recent Searches), category filtering,
/// and popular suggestions.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String text) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      const Duration(milliseconds: AppConstants.searchDebounceMs),
      () {
        final query = text.trim();
        ref.read(searchQueryProvider.notifier).state = query;
        if (query.isNotEmpty) {
          ref.read(recentSearchesProvider.notifier).addQuery(query);
        }
      },
    );
    setState(() {});
  }

  void _executeSearch(String query) {
    _debounceTimer?.cancel();
    final trimmed = query.trim();
    _controller.text = trimmed;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: trimmed.length),
    );
    ref.read(searchQueryProvider.notifier).state = trimmed;
    if (trimmed.isNotEmpty) {
      ref.read(recentSearchesProvider.notifier).addQuery(trimmed);
    }
    _focusNode.unfocus();
    setState(() {});
  }

  void _clearSearch() {
    _debounceTimer?.cancel();
    _controller.clear();
    ref.read(searchQueryProvider.notifier).state = '';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final activeQuery = ref.watch(searchQueryProvider);
    final searchResultsAsync = ref.watch(searchResultsProvider);
    final recentSearches = ref.watch(recentSearchesProvider);
    final categoriesAsync = ref.watch(homeCategoriesProvider);
    final selectedCategoryId = ref.watch(searchSelectedCategoryProvider);
    final selectedSort = ref.watch(searchSortOptionProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: AppSpacing.md),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            textInputAction: TextInputAction.search,
            style: const TextStyle(fontFamily: 'Outfit', fontSize: 15),
            decoration: InputDecoration(
              hintText: isAr
                  ? 'ابحث عن منتجات، ماركات...'
                  : 'Search products, brands...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: _clearSearch,
                      tooltip: isAr ? 'مسح' : 'Clear',
                    )
                  : null,
              filled: true,
              fillColor:
                  isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: _onSearchChanged,
            onSubmitted: _executeSearch,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Category Filter Pills ─────────────────────────────────
          categoriesAsync.maybeWhen(
            data: (categories) => _CategoryFilterBar(
              categories: categories,
              selectedCategoryId: selectedCategoryId,
              onSelect: (catId) {
                ref.read(searchSelectedCategoryProvider.notifier).state = catId;
              },
            ),
            orElse: () => const SizedBox.shrink(),
          ),

          // ── Body: Initial Suggestions OR Results ──────────────────
          Expanded(
            child: activeQuery.isEmpty
                ? _SearchDefaultView(
                    recentSearches: recentSearches,
                    onSelectKeyword: _executeSearch,
                    onRemoveKeyword: (keyword) {
                      ref
                          .read(recentSearchesProvider.notifier)
                          .removeQuery(keyword);
                    },
                    onClearAll: () {
                      ref.read(recentSearchesProvider.notifier).clearAll();
                    },
                  )
                : Column(
                    children: [
                      // Sort Bar for Results
                      _SearchSortBar(
                        selected: selectedSort,
                        onChanged: (newSort) {
                          ref.read(searchSortOptionProvider.notifier).state =
                              newSort;
                        },
                      ),

                      // Results Grid
                      Expanded(
                        child: searchResultsAsync.when(
                          loading: () => GridView.builder(
                            padding: const EdgeInsets.all(
                              AppSpacing.screenHorizontal,
                            ),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: AppSpacing.md,
                              mainAxisSpacing: AppSpacing.md,
                              childAspectRatio: 0.72,
                            ),
                            itemCount: 6,
                            itemBuilder: (context, index) =>
                                const SkeletonLoader(
                              child: SizedBox.expand(),
                            ),
                          ),
                          error: (e, _) => AppErrorWidget(
                            message: e.toString(),
                            onRetry: () =>
                                ref.invalidate(searchResultsProvider),
                          ),
                          data: (products) {
                            if (products.isEmpty) {
                              return _NoSearchResultsView(
                                query: activeQuery,
                                onClear: _clearSearch,
                              );
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    AppSpacing.screenHorizontal,
                                    AppSpacing.xs,
                                    AppSpacing.screenHorizontal,
                                    AppSpacing.sm,
                                  ),
                                  child: Text(
                                    isAr
                                        ? '${products.length} نتيجة بحث عن "$activeQuery"'
                                        : '${products.length} results for "$activeQuery"',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GridView.builder(
                                    padding: const EdgeInsets.all(
                                      AppSpacing.screenHorizontal,
                                    ),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: AppSpacing.md,
                                      mainAxisSpacing: AppSpacing.md,
                                      childAspectRatio: 0.72,
                                    ),
                                    itemCount: products.length,
                                    itemBuilder: (context, index) =>
                                        ProductCard(
                                      product: products[index],
                                      wide: true,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Category Filter Bar ──────────────────────────────────────────────────────

class _CategoryFilterBar extends StatelessWidget {
  const _CategoryFilterBar({
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelect,
  });

  final List<dynamic> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
        ),
        itemCount: categories.length + 1,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSpacing.xs),
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = selectedCategoryId == null;
            return ChoiceChip(
              label: Text(isAr ? 'الكل' : 'All'),
              selected: isSelected,
              onSelected: (_) => onSelect(null),
              selectedColor: AppColors.primary,
              backgroundColor:
                  isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              labelStyle: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.white : null,
              ),
            );
          }

          final category = categories[index - 1];
          final isSelected = selectedCategoryId == category.id;

          return ChoiceChip(
            label: Text(category.localizedName(
              isAr ? 'ar' : 'en',
            )),
            selected: isSelected,
            onSelected: (_) => onSelect(category.id as String),
            selectedColor: AppColors.primary,
            backgroundColor:
                isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            labelStyle: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.white : null,
            ),
          );
        },
      ),
    );
  }
}

// ─── Search Sort Bar ──────────────────────────────────────────────────────────

class _SearchSortBar extends StatelessWidget {
  const _SearchSortBar({
    required this.selected,
    required this.onChanged,
  });

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
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
        ),
        children: ProductSortOption.values.map((opt) {
          final isSelected = opt == selected;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: ChoiceChip(
              label: Text(labels[opt]!),
              selected: isSelected,
              onSelected: (_) => onChanged(opt),
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.white : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Search Default View (Recent & Popular Searches) ──────────────────────────

class _SearchDefaultView extends StatelessWidget {
  const _SearchDefaultView({
    required this.recentSearches,
    required this.onSelectKeyword,
    required this.onRemoveKeyword,
    required this.onClearAll,
  });

  final List<String> recentSearches;
  final ValueChanged<String> onSelectKeyword;
  final ValueChanged<String> onRemoveKeyword;
  final VoidCallback onClearAll;

  static const _popularAr = [
    'ساعة ذكية',
    'حذاء رياضي',
    'هاتف محمول',
    'سماعات لاسلكية',
    'حقيبة يد',
    'نظارة شمسية',
    'عطر فاخر',
    'ملابس رياضية',
  ];

  static const _popularEn = [
    'Smart Watch',
    'Running Shoes',
    'Smartphone',
    'Wireless Earbuds',
    'Leather Bag',
    'Sunglasses',
    'Luxury Perfume',
    'Sportswear',
  ];

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final popularList = isAr ? _popularAr : _popularEn;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      children: [
        // ── Recent Searches Section ─────────────────────────────────
        if (recentSearches.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isAr ? 'عمليات البحث الأخيرة' : 'Recent Searches',
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: onClearAll,
                child: Text(
                  isAr ? 'مسح الكل' : 'Clear All',
                  style: const TextStyle(color: AppColors.badge),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: recentSearches
                .map(
                  (keyword) => Chip(
                    avatar: const Icon(Icons.history_rounded, size: 16),
                    label: Text(keyword),
                    deleteIcon: const Icon(Icons.close, size: 14),
                    onDeleted: () => onRemoveKeyword(keyword),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],

        // ── Popular Searches Section ────────────────────────────────
        Row(
          children: [
            const Icon(
              Icons.trending_up_rounded,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              isAr ? 'عمليات بحث شائعة' : 'Popular Searches',
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: popularList
              .map(
                (tag) => ActionChip(
                  label: Text(tag),
                  onPressed: () => onSelectKeyword(tag),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

// ─── No Results View ──────────────────────────────────────────────────────────

class _NoSearchResultsView extends StatelessWidget {
  const _NoSearchResultsView({
    required this.query,
    required this.onClear,
  });

  final String query;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.onSurfaceVariantLight.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 40,
                color: AppColors.onSurfaceVariantLight,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              isAr
                  ? 'لم يتم العثور على نتائج لـ "$query"'
                  : 'No results for "$query"',
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              isAr
                  ? 'تأكد من كتابة الكلمات بشكل صحيح أو جرّب البحث بكلمات أخرى.'
                  : 'Try checking for typos or searching for a different keyword.',
              style: const TextStyle(
                color: AppColors.onSurfaceVariantLight,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.clear_rounded, size: 16),
              label: Text(isAr ? 'مسح البحث' : 'Clear Search'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
