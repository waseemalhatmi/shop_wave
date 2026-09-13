import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/guest_auth_prompt.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../cart/presentation/providers/cart_notifier.dart';
import '../../domain/entities/product_entity.dart';
import '../../../favorites/presentation/providers/favorites_providers.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../../categories/domain/entities/category_entity.dart';

/// Product Detail Screen — Phase 4: connected to CartNotifier.
/// Phase 5 will connect to real product provider.
class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({
    required this.productId,
    super.key,
  });

  final String productId;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedImageIndex = 0;
  int _quantity = 1;

  String _selectedColor = 'Midnight Black';
  String _selectedSize = 'M';

  static const _colorOptions = [
    ('Midnight Black', 'أسود ليلي', Color(0xFF1E1E24), 'BLK'),
    ('Ocean Navy', 'كحلي بحري', Color(0xFF1B3B6F), 'NVY'),
    ('Silver Mist', 'فضي ناصع', Color(0xFFC0C0C0), 'SLV'),
    ('Rose Gold', 'ذهبي وردي', Color(0xFFB76E79), 'RSG'),
    ('Emerald Green', 'أخضر زمردي', Color(0xFF097969), 'EMR'),
  ];

  static const _sizeOptions = ['S', 'M', 'L', 'XL', 'XXL'];

  String _buildSku(ProductEntity product) {
    final base = product.sku ??
        'SW-${product.id.replaceAll('-', '').substring(0, 6).toUpperCase()}';
    final colorCode = _colorOptions
        .firstWhere((c) => c.$1 == _selectedColor,
            orElse: () => _colorOptions.first)
        .$4;
    return '$base-$colorCode-$_selectedSize';
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId));

    return productAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(
          title: Text(
            Localizations.localeOf(context).languageCode == 'ar' ? 'خطأ' : 'Error',
            style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              Localizations.localeOf(context).languageCode == 'ar'
                  ? 'فشل تحميل تفاصيل المنتج: $error'
                  : 'Failed to load product details: $error',
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Outfit', fontSize: 16),
            ),
          ),
        ),
      ),
      data: (product) => _buildContent(context, product),
    );
  }

  Widget _buildContent(BuildContext context, ProductEntity product) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;

    final images = product.images.isNotEmpty
        ? product.images
        : [product.primaryImageUrl ?? ''];

    final categoriesAsync = ref.watch(homeCategoriesProvider);
    final categoryName = categoriesAsync.maybeWhen(
      data: (list) => list
          .firstWhere(
            (c) => c.id == product.categoryId,
            orElse: () => const CategoryEntity(
              id: '',
              nameEn: 'ShopWave',
              nameAr: 'المتجر',
              slug: '',
              sortOrder: 0,
            ),
          )
          .localizedName(locale),
      orElse: () => 'ShopWave',
    );

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // ── Image Gallery App Bar ───────────────────────────────
          SliverAppBar(
            expandedHeight: 360,
            pinned: true,
            backgroundColor:
                isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            leading: GestureDetector(
              onTap: () => GoRouter.of(context).pop(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    ref.watch(isFavoriteProvider(product.id))
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: 20,
                    color: ref.watch(isFavoriteProvider(product.id))
                        ? AppColors.badge
                        : null,
                  ),
                  onPressed: () {
                    final authState = ref.read(authNotifierProvider);
                    if (authState is! AuthAuthenticated) {
                      final isAr = Localizations.localeOf(context).languageCode == 'ar';
                      GuestAuthPrompt.show(
                        context,
                        title: isAr ? 'المفضلة تتطلب حساباً' : 'Sign in to add to Wishlist',
                        message: isAr
                            ? 'سجل دخولك لحفظ "${product.localizedName('ar')}" في قائمة رغباتك والرجوع إليه لاحقاً.'
                            : 'Sign in or create an account to save "${product.localizedName('en')}" to your wishlist.',
                        icon: Icons.favorite_rounded,
                      );
                      return;
                    }
                    ref.read(favoritesProvider.notifier).toggleFavorite(product);
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.share_outlined, size: 20),
                  onPressed: () {},
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Main image
                  PageView.builder(
                    itemCount: images.length,
                    onPageChanged: (i) =>
                        setState(() => _selectedImageIndex = i),
                    itemBuilder: (_, i) => Image.network(
                      images[i],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.surfaceVariantLight,
                        child: const Icon(
                          Icons.image_outlined,
                          size: 80,
                          color: AppColors.onSurfaceVariantLight,
                        ),
                      ),
                    ),
                  ),
                  // Image indicator dots
                  if (images.length > 1)
                    Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          images.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: i == _selectedImageIndex ? 20 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: i == _selectedImageIndex
                                  ? AppColors.primary
                                  : AppColors.white.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Product Info ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.sm),

                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        categoryName,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Product name
                    Text(
                      product.localizedName(locale),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Rating + sold count
                    Row(
                      children: [
                        if (product.avgRating > 0) ...[
                          ...List.generate(
                            5,
                            (i) => Icon(
                              i < product.avgRating.floor()
                                  ? Icons.star_rounded
                                  : (i < product.avgRating
                                      ? Icons.star_half_rounded
                                      : Icons.star_border_rounded),
                              size: 18,
                              color: AppColors.star,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            '${product.avgRating.toStringAsFixed(1)} (${context.l10n.review_rating_label(product.reviewCount)})',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ] else
                          Text(
                            context.l10n.review_no_reviews,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        const Spacer(),
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          locale == 'ar' ? 'تم بيع ${product.soldCount}' : '${product.soldCount} sold',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${product.finalPrice.toStringAsFixed(2)} ${context.l10n.general_sar}',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (product.hasDiscount) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            '${product.basePrice.toStringAsFixed(2)} ${context.l10n.general_sar}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: AppColors.originalPrice,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.badge.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '-${product.discountPercenti}%',
                              style: const TextStyle(
                                color: AppColors.badge,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const Divider(height: AppSpacing.xl),

                    // ── Color Variant Selector ──────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          locale == 'ar' ? 'اللون:' : 'Color:',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          locale == 'ar'
                              ? _colorOptions
                                  .firstWhere((c) => c.$1 == _selectedColor,
                                      orElse: () => _colorOptions.first)
                                  .$2
                              : _selectedColor,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: _colorOptions.map((opt) {
                        final (nameEn, nameAr, colorVal, _) = opt;
                        final isSelected = _selectedColor == nameEn;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedColor = nameEn),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 10),
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: colorVal,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : (isDark
                                        ? AppColors.borderDark
                                        : Colors.grey.shade300),
                                width: isSelected ? 3.0 : 1.5,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.35),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      )
                                    ]
                                  : null,
                            ),
                            child: isSelected
                                ? Icon(
                                    Icons.check_rounded,
                                    size: 20,
                                    color: colorVal.computeLuminance() > 0.5
                                        ? Colors.black
                                        : Colors.white,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // ── Size Variant Selector ───────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          locale == 'ar' ? 'المقاس:' : 'Size:',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'SKU: ${_buildSku(product)}',
                            style: TextStyle(
                              fontSize: 11,
                              fontFamily: 'Outfit',
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: _sizeOptions.map((sz) {
                        final isSelected = _selectedSize == sz;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedSize = sz),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDark
                                      ? AppColors.surfaceVariantDark
                                      : AppColors.surfaceVariantLight),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : (isDark
                                        ? AppColors.borderDark
                                        : Colors.grey.shade300),
                                width: isSelected ? 2.0 : 1.0,
                              ),
                            ),
                            child: Text(
                              sz,
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: isSelected
                                    ? Colors.white
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const Divider(height: AppSpacing.xl),

                    // Quantity selector
                    Row(
                      children: [
                        Text(
                          context.l10n.product_quantity,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        _QuantitySelector(
                          quantity: _quantity,
                          onChanged: (v) => setState(() => _quantity = v),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Tab bar — Description / Specs / Reviews
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceVariantDark
                            : AppColors.surfaceVariantLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: AppColors.white,
                        unselectedLabelColor:
                            theme.colorScheme.onSurfaceVariant,
                        dividerColor: AppColors.transparent,
                        tabs: [
                          Tab(text: context.l10n.product_description),
                          Tab(text: locale == 'ar' ? 'المواصفات' : 'Specs'),
                          Tab(text: context.l10n.product_reviews),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    AnimatedBuilder(
                      animation: _tabController,
                      builder: (context, _) {
                        switch (_tabController.index) {
                          case 0:
                            return Text(
                              product.localizedDescription(locale) ??
                                  product.descriptionEn ??
                                  (locale == 'ar' ? 'لا يوجد وصف متاح.' : 'No description available.'),
                              style: const TextStyle(height: 1.7, fontSize: 14),
                            );
                          case 1:
                            return const _SpecsTab();
                          case 2:
                          default:
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.md,
                                ),
                                child: TextButton.icon(
                                  icon: const Icon(Icons.rate_review_outlined),
                                  label: Text(locale == 'ar' ? 'عرض جميع التقييمات' : 'View All Reviews'),
                                  onPressed: () => context.push(
                                    AppRoutes.reviewsPath(product.id),
                                  ),
                                ),
                              ),
                            );
                        }
                      },
                    ),

                    const SizedBox(height: 100), // room for bottom bar
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // ── Bottom Action Bar ───────────────────────────────────────
      bottomNavigationBar: _BottomActionBar(
        quantity: _quantity,
        onAddToCart: () => _addToCart(product),
        onBuyNow: () => _buyNow(product),
      ),
    );
  }

  void _addToCart(ProductEntity product) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final sku = _buildSku(product);
    final colorAr = _colorOptions
        .firstWhere((c) => c.$1 == _selectedColor,
            orElse: () => _colorOptions.first)
        .$2;
    final variantLabel = isAr
        ? 'اللون: $colorAr | المقاس: $_selectedSize'
        : 'Color: $_selectedColor | Size: $_selectedSize';

    ref.read(cartNotifierProvider.notifier).addItem(
          product: product,
          quantity: _quantity,
          variantId: '${product.id}-$_selectedColor-$_selectedSize',
          variantLabel: variantLabel,
          color: isAr ? colorAr : _selectedColor,
          size: _selectedSize,
          sku: sku,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '✓ ${context.l10n.product_added_to_cart}',
          style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: isAr ? 'عرض السلة' : 'View Cart',
          textColor: AppColors.white,
          onPressed: () => context.go(AppRoutes.cart),
        ),
      ),
    );
  }

  void _buyNow(ProductEntity product) {
    _addToCart(product);
    context.push(AppRoutes.checkout);
  }
}

// ─── Quantity Selector ────────────────────────────────────────────────────────

class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({required this.quantity, required this.onChanged});
  final int quantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_rounded),
            onPressed: quantity > 1 ? () => onChanged(quantity - 1) : null,
            iconSize: 18,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Text(
              '$quantity',
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => onChanged(quantity + 1),
            iconSize: 18,
          ),
        ],
      ),
    );
  }
}

// ─── Specs Tab ────────────────────────────────────────────────────────────────

class _SpecsTab extends StatelessWidget {
  const _SpecsTab();

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final specs = [
      (isAr ? 'حجم الصوت' : 'Driver Size', isAr ? '40 ملم نيوديميوم' : '40mm Neodymium'),
      (isAr ? 'استجابة التردد' : 'Frequency Response', '20Hz - 20kHz'),
      (isAr ? 'عمر البطارية' : 'Battery Life', isAr ? '30 ساعة' : '30 hours'),
      (isAr ? 'الشحن' : 'Charging', isAr ? 'USB-C، شحن كامل خلال ساعتين' : 'USB-C, 2hr full charge'),
      (isAr ? 'الاتصال' : 'Connectivity', 'Bluetooth 5.2'),
      (isAr ? 'الوزن' : 'Weight', isAr ? '285 جرام' : '285g'),
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: specs.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final (label, value) = specs[i];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Bottom Action Bar ────────────────────────────────────────────────────────

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.onAddToCart,
    required this.onBuyNow,
    this.quantity = 1,
  });

  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;
  final int quantity;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.sm,
        AppSpacing.screenHorizontal,
        MediaQuery.paddingOf(context).bottom + AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.shadowDark : AppColors.shadowLight,
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Add to Cart
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onAddToCart,
              icon: const Icon(Icons.shopping_cart_outlined, size: 18),
              label: Text(context.l10n.product_add_to_cart),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
                side: const BorderSide(color: AppColors.primary),
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Buy Now
          Expanded(
            child: ElevatedButton(
              onPressed: onBuyNow,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                context.l10n.product_buy_now,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
