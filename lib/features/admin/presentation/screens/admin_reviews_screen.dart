import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_reviews_notifier.dart';

class AdminReviewsScreen extends ConsumerStatefulWidget {
  const AdminReviewsScreen({super.key});

  @override
  ConsumerState<AdminReviewsScreen> createState() => _AdminReviewsScreenState();
}

class _AdminReviewsScreenState extends ConsumerState<AdminReviewsScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 250) {
      ref.read(adminReviewsNotifierProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(adminReviewsNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final currentFilter = stateAsync.value?.ratingFilter;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + Stats
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        isAr ? 'إدارة التقييمات' : 'Reviews Management',
                        style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w800, fontFamily: 'Outfit',
                          color: isDark ? AppColors.white : AppColors.onSurfaceLight,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (stateAsync.value != null)
                      _RatingAverage(reviews: stateAsync.value!.reviews, isAr: isAr),
                  ],
                ),
                const SizedBox(height: 14),

                // Rating Filter Row
                Row(
                  children: [
                    Text(
                      isAr ? 'فلتر التقييم:' : 'Filter by rating:',
                      style: TextStyle(
                        fontFamily: 'Outfit', fontWeight: FontWeight.w600, fontSize: 13,
                        color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            // All button
                            _RatingFilterChip(
                              label: isAr ? 'الكل' : 'All',
                              isSelected: currentFilter == null,
                              onTap: () => ref.read(adminReviewsNotifierProvider.notifier).setRatingFilter(null),
                            ),
                            const SizedBox(width: 6),
                            // 1-5 star buttons (descending order for UX)
                            ...List.generate(5, (i) {
                              final rating = 5 - i;
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: _RatingFilterChip(
                                  label: '$rating ★',
                                  isSelected: currentFilter == rating,
                                  starRating: rating,
                                  onTap: () => ref.read(adminReviewsNotifierProvider.notifier).setRatingFilter(rating),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Reviews List ────────────────────────────────────────────────
          Expanded(
            child: stateAsync.when(
              data: (st) => st.reviews.isEmpty
                  ? _EmptyState(isAr: isAr, ratingFilter: st.ratingFilter)
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                      itemCount: st.reviews.length + (st.isLoadingMore ? 1 : 0),
                      itemBuilder: (ctx, i) {
                        if (i == st.reviews.length) {
                          return const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                          );
                        }
                        return _ReviewCard(
                          review: st.reviews[i],
                          isDark: isDark,
                          isAr: isAr,
                          onDelete: () => _confirmDelete(context, ref, st.reviews[i]['id'] as String, isAr),
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (e, _) => _ErrorState(
                isAr: isAr,
                onRetry: () => ref.invalidate(adminReviewsNotifierProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id, bool isAr) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isAr ? 'حذف التقييم' : 'Delete Review', style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700)),
        content: Text(
          isAr ? 'هل أنت متأكد من حذف هذا التقييم؟ لا يمكن التراجع عن هذا الإجراء.' : 'Are you sure you want to delete this review? This cannot be undone.',
          style: const TextStyle(fontFamily: 'Outfit'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isAr ? 'إلغاء' : 'Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(adminReviewsNotifierProvider.notifier).deleteReview(id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(isAr ? 'تم حذف التقييم' : 'Review deleted', style: const TextStyle(fontFamily: 'Outfit')),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ));
                }
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(isAr ? 'فشل الحذف، يرجى المحاولة مجدداً' : 'Delete failed, please try again', style: const TextStyle(fontFamily: 'Outfit')),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                  ));
                }
              }
            },
            child: Text(isAr ? 'حذف' : 'Delete', style: const TextStyle(color: Colors.white, fontFamily: 'Outfit')),
          ),
        ],
      ),
    );
  }
}

// ── Rating Average Widget ─────────────────────────────────────────────────────

class _RatingAverage extends StatelessWidget {
  const _RatingAverage({required this.reviews, required this.isAr});
  final List<Map<String, dynamic>> reviews;
  final bool isAr;

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) return const SizedBox.shrink();
    final avg = reviews.fold<double>(0, (sum, r) => sum + ((r['rating'] as int? ?? 0).toDouble())) / reviews.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: AppColors.star.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.star_rounded, color: AppColors.star, size: 16),
        const SizedBox(width: 4),
        Text(avg.toStringAsFixed(1), style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.star)),
        const SizedBox(width: 4),
        Text(isAr ? 'متوسط' : 'avg', style: const TextStyle(fontFamily: 'Outfit', fontSize: 11, color: AppColors.star)),
      ]),
    );
  }
}

// ── Rating Filter Chip ────────────────────────────────────────────────────────

class _RatingFilterChip extends StatelessWidget {
  const _RatingFilterChip({required this.label, required this.isSelected, required this.onTap, this.starRating});
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int? starRating;

  Color get _chipColor {
    if (starRating == null) return AppColors.primary;
    return switch (starRating!) {
      5 => AppColors.success,
      4 => const Color(0xFF7CB342),
      3 => AppColors.warning,
      2 => Colors.deepOrange,
      _ => AppColors.error,
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? _chipColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? _chipColor : Colors.grey.shade400),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Outfit', fontWeight: FontWeight.w700, fontSize: 12,
            color: isSelected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}

// ── Review Card ───────────────────────────────────────────────────────────────

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review, required this.isDark, required this.isAr, required this.onDelete});
  final Map<String, dynamic> review;
  final bool isDark, isAr;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final rating = review['rating'] as int? ?? 0;
    final comment = review['comment'] as String? ?? '';
    final productData = review['products'] as Map<String, dynamic>?;
    final productName = productData?[isAr ? 'name_ar' : 'name_en'] as String? ?? (isAr ? 'منتج محذوف' : 'Deleted Product');
    final userData = review['profiles'] as Map<String, dynamic>?;
    final userName = userData?['full_name'] as String? ?? (isAr ? 'مستخدم مجهول' : 'Anonymous');

    // Date formatting
    String formattedDate = '';
    final createdAt = review['created_at'];
    if (createdAt != null) {
      final dt = DateTime.tryParse(createdAt.toString())?.toLocal();
      if (dt != null) {
        final diff = DateTime.now().difference(dt);
        if (diff.inDays == 0) {
          formattedDate = isAr ? 'اليوم' : 'Today';
        } else if (diff.inDays == 1) {
          formattedDate = isAr ? 'أمس' : 'Yesterday';
        } else if (diff.inDays < 7) {
          formattedDate = isAr ? 'منذ ${diff.inDays} أيام' : '${diff.inDays}d ago';
        } else {
          formattedDate = '${dt.day}/${dt.month}/${dt.year}';
        }
      }
    }

    // Rating color
    final ratingColor = switch (rating) {
      5 || 4 => AppColors.success,
      3 => AppColors.warning,
      _ => AppColors.error,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 8, offset: const Offset(0, 3))],
        border: rating <= 2 ? Border.all(color: AppColors.error.withValues(alpha: 0.3), width: 1) : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Row: Stars + Date + Delete ──────────────────────────
            Row(
              children: [
                // Stars
                ...List.generate(5, (i) => Icon(
                  i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: AppColors.star, size: 18,
                )),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(color: ratingColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text('$rating/5', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w800, fontSize: 12, color: ratingColor)),
                ),
                const Spacer(),
                Text(formattedDate, style: TextStyle(fontFamily: 'Outfit', fontSize: 11, color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight)),
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  color: AppColors.error,
                  onPressed: onDelete,
                  tooltip: isAr ? 'حذف التقييم' : 'Delete review',
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),

            // ── Comment ──────────────────────────────────────────────────
            if (comment.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '"$comment"',
                  style: TextStyle(
                    fontFamily: 'Outfit', fontSize: 13, fontStyle: FontStyle.italic,
                    color: isDark ? AppColors.white : AppColors.onSurfaceLight,
                    height: 1.5,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 10),
            Divider(height: 1, color: isDark ? Colors.white10 : Colors.black12),
            const SizedBox(height: 10),

            // ── Bottom Row: Product + User ────────────────────────────
            Row(
              children: [
                // Product
                const Icon(Icons.inventory_2_outlined, size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    productName,
                    style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.primary),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                // User
                Icon(Icons.person_outline_rounded, size: 14, color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight),
                const SizedBox(width: 4),
                Text(
                  userName,
                  style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isAr, required this.ratingFilter});
  final bool isAr;
  final int? ratingFilter;

  @override
  Widget build(BuildContext context) {
    final message = ratingFilter != null
        ? (isAr ? 'لا توجد تقييمات بـ $ratingFilter نجوم' : 'No $ratingFilter-star reviews found')
        : (isAr ? 'لا توجد تقييمات حتى الآن' : 'No reviews yet');

    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.reviews_outlined, size: 72, color: Colors.grey.shade400),
        const SizedBox(height: 16),
        Text(message, style: TextStyle(fontFamily: 'Outfit', fontSize: 18, fontWeight: FontWeight.w700, color: Colors.grey.shade600), textAlign: TextAlign.center),
        if (ratingFilter != null) ...[
          const SizedBox(height: 8),
          Text(isAr ? 'جرّب تغيير فلتر النجوم' : 'Try changing the star filter', style: TextStyle(fontFamily: 'Outfit', fontSize: 13, color: Colors.grey.shade500)),
        ],
      ]),
    );
  }
}

// ── Error State ───────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.isAr, required this.onRetry});
  final bool isAr;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.cloud_off_rounded, color: AppColors.error, size: 64),
        const SizedBox(height: 16),
        Text(isAr ? 'فشل تحميل التقييمات' : 'Failed to load reviews', style: const TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.error)),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: Text(isAr ? 'إعادة المحاولة' : 'Retry', style: const TextStyle(fontFamily: 'Outfit')),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
        ),
      ]),
    );
  }
}
