import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/product_card.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../providers/favorites_providers.dart';

/// Favorites screen.
/// Connected to real favorites table via Supabase in Phase 6.
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final authState = ref.watch(authNotifierProvider);
    final isAuthenticated = authState is AuthAuthenticated;

    final productsAsync = isAuthenticated ? ref.watch(favoritesProvider) : null;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          context.l10n.favorites_title,
          style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.transparent,
        elevation: 0,
      ),
      body: !isAuthenticated
          ? _buildGuestState(context, isAr)
          : RefreshIndicator(
              onRefresh: () => ref.refresh(favoritesProvider.future),
              child: productsAsync!.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, __) => _buildErrorState(context, ref, error),
          data: (products) {
            if (products.isEmpty) {
              return _buildEmptyState(context);
            }
            return GridView.builder(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 0.72,
              ),
              itemCount: products.length,
              itemBuilder: (_, i) {
                final product = products[i];
                return ProductCard(
                  product: product,
                  wide: true,
                  isFavorite: true,
                  onFavoriteToggle: () {
                    ref.read(favoritesProvider.notifier).toggleFavorite(product);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.favorite_border_rounded,
                size: 72,
                color: AppColors.onSurfaceVariantLight,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                context.l10n.favorites_empty,
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                context.l10n.favorites_empty_desc,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.home),
                child: Text(isAr ? 'استكشف المنتجات' : 'Explore Products'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 72,
                color: AppColors.error,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                isAr ? 'فشل تحميل المفضلة' : 'Failed to load favorites',
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                error.toString().replaceAll('Exception: ', ''),
                style: TextStyle(
                  fontFamily: 'Outfit',
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: () => ref.invalidate(favoritesProvider),
                child: Text(context.l10n.general_retry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuestState(BuildContext context, bool isAr) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.15),
                      AppColors.badge.withValues(alpha: 0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.badge.withValues(alpha: 0.25),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  size: 48,
                  color: AppColors.badge,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                isAr ? 'قائمة أمنياتك بانتظارك!' : 'Your Wishlist is Waiting!',
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                isAr
                    ? 'سجّل دخولك الآن لحفظ المنتجات المميزة، ومتابعة عروضها وأسعارها في أي وقت.'
                    : 'Sign in now to save your favorite items and track special deals anytime.',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 14,
                  height: 1.5,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: 240,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => context.push(AppRoutes.login),
                  icon: const Icon(Icons.login_rounded, size: 20),
                  label: Text(
                    isAr ? 'تسجيل الدخول' : 'Sign In',
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
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
