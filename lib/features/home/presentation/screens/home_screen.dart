import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/product_card.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../domain/entities/banner_entity.dart';
import '../providers/home_providers.dart';

/// Home screen — the main landing page of ShopWave.
///
/// Sections:
/// 1. App Bar with search + notifications
/// 2. Greeting with user name
/// 3. Search bar shortcut
/// 4. Promotional banner carousel
/// 5. Category chips
/// 6. Flash deals horizontal list
/// 7. Featured products
/// 8. New arrivals
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final authState = ref.watch(authNotifierProvider);
    final userName = authState is AuthAuthenticated
        ? authState.user.displayName
        : (isAr ? 'بك' : 'there');

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: RefreshIndicator(
        color: AppColors.primary,
        displacement: 60,
        onRefresh: () async {
          ref.invalidate(homeBannersProvider);
          ref.invalidate(homeCategoriesProvider);
          ref.invalidate(featuredProductsProvider);
          ref.invalidate(newArrivalProductsProvider);
          ref.invalidate(flashDealProductsProvider);
          ref.invalidate(bestSellerProductsProvider);
          // Allow brief visual feedback before re-fetch completes
          await Future<void>.delayed(const Duration(milliseconds: 400));
        },
        child: CustomScrollView(
          // Required so RefreshIndicator works even when content
          // is shorter than the viewport (e.g. empty state).
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── App Bar ──────────────────────────────────────────
            _HomeAppBar(userName: userName),

            // ── Search Shortcut ──────────────────────────────────
            SliverToBoxAdapter(
              child: _SearchBar(),
            ),

            // ── Banner Carousel ──────────────────────────────────
            SliverToBoxAdapter(
              child: _BannerSection(),
            ),

            // ── Category Chips ───────────────────────────────────
            SliverToBoxAdapter(
              child: _CategorySection(),
            ),

            // ── Flash Deals ──────────────────────────────────────
            SliverToBoxAdapter(
              child: _ProductSection(
                title: isAr ? '⚡ عروض سريعة' : '⚡ Flash Deals',
                subtitle: isAr ? 'عروض لفترة محدودة' : 'Limited time offers',
                watch: (r) => r.watch(flashDealProductsProvider),
                onRetry: () => ref.invalidate(flashDealProductsProvider),
                seeAllRoute: AppRoutes.productList,
                seeAllExtra: {
                  'filter': 'flash_deals',
                  'title': isAr ? 'عروض سريعة' : 'Flash Deals',
                },
                accentColor: AppColors.badge,
              ),
            ),

            // ── Featured Products ─────────────────────────────────
            SliverToBoxAdapter(
              child: _ProductSection(
                title: isAr ? '⭐ منتجات مميزة' : '⭐ Featured',
                subtitle: isAr ? 'مختارة بعناية لأجلك' : 'Handpicked for you',
                watch: (r) => r.watch(featuredProductsProvider),
                onRetry: () => ref.invalidate(featuredProductsProvider),
                seeAllRoute: AppRoutes.productList,
                seeAllExtra: {
                  'filter': 'featured',
                  'title': isAr ? 'منتجات مميزة' : 'Featured Products',
                },
              ),
            ),

            // ── Best Sellers ──────────────────────────────────────
            SliverToBoxAdapter(
              child: _ProductSection(
                title: isAr ? '🏆 الأكثر مبيعاً' : '🏆 Best Sellers',
                subtitle: isAr ? 'الأعلى تقييماً ومبيعاً' : 'Top rated & sold',
                watch: (r) => r.watch(bestSellerProductsProvider),
                onRetry: () => ref.invalidate(bestSellerProductsProvider),
                seeAllRoute: AppRoutes.productList,
                seeAllExtra: {
                  'filter': 'best_sellers',
                  'title': isAr ? 'الأكثر مبيعاً' : 'Best Sellers',
                },
                accentColor: AppColors.warning,
              ),
            ),

            // ── New Arrivals ──────────────────────────────────────
            SliverToBoxAdapter(
              child: _ProductSection(
                title: isAr ? '🆕 وصل حديثاً' : '🆕 New Arrivals',
                subtitle: isAr ? 'أحدث المنتجات' : 'Just dropped',
                watch: (r) => r.watch(newArrivalProductsProvider),
                onRetry: () => ref.invalidate(newArrivalProductsProvider),
                seeAllRoute: AppRoutes.productList,
                seeAllExtra: {
                  'filter': 'new_arrivals',
                  'title': isAr ? 'وصل حديثاً' : 'New Arrivals',
                },
              ),
            ),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.xxl),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── App Bar ─────────────────────────────────────────────────────────────────

class _HomeAppBar extends ConsumerWidget {
  const _HomeAppBar({required this.userName});
  final String userName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final authState = ref.watch(authNotifierProvider);
    final isAuthenticated = authState is AuthAuthenticated;

    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      elevation: 0,
      titleSpacing: AppSpacing.screenHorizontal,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isAuthenticated
                ? (isAr ? '${_greeting(isAr)}، 👋' : 'Good ${_greeting(isAr)}, 👋')
                : (isAr ? 'مرحباً بك، 👋' : 'Welcome to, 👋'),
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 13,
              color: isDark
                  ? AppColors.onSurfaceVariantDark
                  : AppColors.onSurfaceVariantLight,
            ),
          ),
          Text(
            isAuthenticated ? userName : 'ShopWave',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight,
            ),
          ),
        ],
      ),
      actions: [
        if (isAuthenticated) ...[
          // Notifications for authenticated user
          IconButton(
            icon: Badge(
              isLabelVisible: true,
              smallSize: 8,
              backgroundColor: AppColors.badge,
              child: Icon(
                Icons.notifications_outlined,
                color: isDark
                    ? AppColors.onSurfaceDark
                    : AppColors.onSurfaceLight,
              ),
            ),
            onPressed: () => context.push(AppRoutes.notifications),
          ),
        ] else ...[
          // Prominent Sign In button for Guest user
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () => context.push(AppRoutes.login),
              icon: const Icon(Icons.login_rounded, size: 16),
              label: Text(
                isAr ? 'تسجيل الدخول' : 'Sign In',
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
        // Cart icon for all users (guests can also add items to cart)
        IconButton(
          icon: Icon(
            Icons.shopping_cart_outlined,
            color: isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight,
          ),
          onPressed: () => context.go(AppRoutes.cart),
        ),
        const SizedBox(width: AppSpacing.sm),
      ],
    );
  }

  String _greeting(bool isAr) {
    final hour = DateTime.now().hour;
    if (hour < 12) return isAr ? 'صباح الخير' : 'Morning';
    if (hour < 17) return isAr ? 'مساء الخير' : 'Afternoon';
    return isAr ? 'مساء الخير' : 'Evening';
  }
}

// ─── Search Bar ───────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.sm,
      ),
      child: GestureDetector(
        onTap: () => context.push(AppRoutes.search),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: isDark ? AppColors.shadowDark : AppColors.shadowLight,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: isDark
                    ? AppColors.onSurfaceVariantDark
                    : AppColors.onSurfaceVariantLight,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                context.l10n.home_search_hint,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 14,
                  color: isDark
                      ? AppColors.onSurfaceVariantDark
                      : AppColors.onSurfaceVariantLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Banner Section ───────────────────────────────────────────────────────────

class _BannerSection extends ConsumerStatefulWidget {
  @override
  ConsumerState<_BannerSection> createState() => _BannerSectionState();
}

class _BannerSectionState extends ConsumerState<_BannerSection> {
  final _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;
  Timer? _autoScrollTimer;
  int _totalBanners = 0;

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || _totalBanners < 2) return;
      final nextPage = (_currentPage + 1) % _totalBanners;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final bannersAsync = ref.watch(homeBannersProvider);

    return bannersAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
          vertical: AppSpacing.sm,
        ),
        child: SkeletonLoader(
          child: SizedBox(height: 180, width: double.infinity),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (banners) {
        if (banners.isEmpty) return const SizedBox.shrink();
        // Start auto-scroll once banners are loaded
        if (_totalBanners != banners.length) {
          _totalBanners = banners.length;
          WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
        }
        return Column(
          children: [
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 180,
              child: PageView.builder(
                controller: _pageController,
                itemCount: banners.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) => GestureDetector(
                  // Pause auto-scroll while user is swiping manually
                  onPanDown: (_) => _autoScrollTimer?.cancel(),
                  onPanEnd: (_) => _startAutoScroll(),
                  child: _BannerCard(banner: banners[i]),
                ),
              ),
            ),
            if (banners.length > 1) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  banners.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _currentPage ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == _currentPage
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.banner});
  final BannerEntity banner;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                banner.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                  ),
                  child: const Icon(
                    Icons.image_outlined,
                    color: AppColors.white,
                    size: 48,
                  ),
                ),
              ),
              if (banner.localizedTitle(Localizations.localeOf(context).languageCode) != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          AppColors.black.withValues(alpha: 0.7),
                          AppColors.transparent,
                        ],
                      ),
                    ),
                    child: Text(
                      banner.localizedTitle(Localizations.localeOf(context).languageCode)!,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontFamily: 'Outfit',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
}

// ─── Category Section ─────────────────────────────────────────────────────────

class _CategorySection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(homeCategoriesProvider);

    return categoriesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: SizedBox(height: 88),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (categories) {
        if (categories.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              title: context.l10n.home_categories,
              onSeeAll: () => context.go(AppRoutes.categories),
            ),
            SizedBox(
              height: 88,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                itemCount: categories.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (_, i) => _CategoryChip(category: categories[i]),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category});
  final CategoryEntity category;

  static const List<Color> _bgColors = [
    Color(0xFFEDECFF),
    Color(0xFFFFECF0),
    Color(0xFFE8F5E9),
    Color(0xFFFFF3E0),
    Color(0xFFE1F5FE),
    Color(0xFFF3E5F5),
  ];

  static const List<Color> _iconColors = [
    AppColors.primary,
    AppColors.badge,
    AppColors.success,
    AppColors.warning,
    AppColors.info,
    Color(0xFF7B1FA2),
  ];

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final index = category.nameEn.hashCode.abs() % _bgColors.length;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => context.push(
        AppRoutes.productList,
        extra: {'categoryId': category.id, 'title': category.localizedName(locale)},
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceVariantDark
                  : _bgColors[index],
              borderRadius: BorderRadius.circular(16),
            ),
            child: category.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      category.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Icon(Icons.category_outlined, color: _iconColors[index]),
                    ),
                  )
                : Icon(Icons.category_outlined, color: _iconColors[index]),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            category.localizedName(locale),
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.onSurfaceDark
                  : AppColors.onSurfaceLight,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Product Section ──────────────────────────────────────────────────────────

class _ProductSection extends ConsumerWidget {
  const _ProductSection({
    required this.title,
    required this.subtitle,
    required this.watch,
    required this.onRetry,
    required this.seeAllRoute,
    this.seeAllExtra,
    this.accentColor,
  });

  final String title;
  final String subtitle;
  /// Reads the provider state. Called on every rebuild via [ref.watch].
  final AsyncValue<List<ProductEntity>> Function(WidgetRef) watch;
  /// Called when the user taps "Retry" on an error state.
  /// The caller is responsible for invalidating the correct provider.
  final VoidCallback onRetry;
  /// Route to navigate to when the user taps "See All".
  final String seeAllRoute;
  /// Optional extra payload forwarded to [seeAllRoute] via GoRouter.
  final Object? seeAllExtra;
  final Color? accentColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = watch(ref);

    return productsAsync.when(
      loading: () => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(title: title),
            SizedBox(
              height: 240,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                itemCount: 4,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.md),
                itemBuilder: (_, __) => const SkeletonLoader(
                  child: SizedBox(width: 160, height: 240),
                ),
              ),
            ),
          ],
        ),
      ),
      error: (Object error, _) => Padding(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        child: AppErrorWidget(
          message: error.toString(),
          onRetry: onRetry,
        ),
      ),
      data: (List<ProductEntity> products) {
        if (products.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.sm),
            _SectionHeader(
              title: title,
              subtitle: subtitle,
              accentColor: accentColor,
              onSeeAll: () => context.push(seeAllRoute, extra: seeAllExtra),
            ),
            SizedBox(
              height: 248,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                  vertical: AppSpacing.xs,
                ),
                itemCount: products.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.md),
                itemBuilder: (_, int i) => ProductCard(product: products[i]),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.subtitle,
    this.onSeeAll,
    this.accentColor,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onSeeAll;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          if (accentColor != null) ...[
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                ),
              ),
              child: Text(context.l10n.general_see_all),
            ),
        ],
      ),
    );
  }
}
