import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../home/presentation/providers/home_providers.dart';

/// Categories screen — shows all top-level categories in a grid.
class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(homeCategoriesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          context.l10n.home_categories,
          style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
        backgroundColor: AppColors.transparent,
        elevation: 0,
      ),
      body: categoriesAsync.when(
        loading: () => GridView.builder(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.2,
          ),
          itemCount: 8,
          itemBuilder: (_, __) => const SkeletonLoader(
            child: SizedBox.expand(),
          ),
        ),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(homeCategoriesProvider),
        ),
        data: (categories) => GridView.builder(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.2,
          ),
          itemCount: categories.length,
          itemBuilder: (_, i) {
            final category = categories[i];
            final colors = [
              [const Color(0xFFEDECFF), AppColors.primary],
              [const Color(0xFFFFECF0), AppColors.badge],
              [const Color(0xFFE8F5E9), AppColors.success],
              [const Color(0xFFFFF3E0), AppColors.warning],
              [const Color(0xFFE1F5FE), AppColors.info],
              [const Color(0xFFF3E5F5), const Color(0xFF7B1FA2)],
            ];
            final colorPair = colors[i % colors.length];

            return GestureDetector(
              onTap: () => context.push(
                AppRoutes.productList,
                extra: {
                  'categoryId': category.id,
                  'title': category.localizedName(Localizations.localeOf(context).languageCode),
                },
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : colorPair[0],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color:
                          isDark ? AppColors.shadowDark : AppColors.shadowLight,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Category image or icon
                    Positioned(
                      right: -12,
                      bottom: -12,
                      child: Opacity(
                        opacity: 0.15,
                        child: Icon(
                          Icons.category_rounded,
                          size: 100,
                          color: colorPair[1],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: colorPair[1].withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: category.imageUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      category.imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Icon(
                                        Icons.category_outlined,
                                        color: colorPair[1],
                                      ),
                                    ),
                                  )
                                : Icon(
                                    Icons.category_outlined,
                                    color: colorPair[1],
                                  ),
                          ),
                          Text(
                            category.localizedName(Localizations.localeOf(context).languageCode),
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.onSurfaceDark
                                  : AppColors.onSurfaceLight,
                            ),
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
