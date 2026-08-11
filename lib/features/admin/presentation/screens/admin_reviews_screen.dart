import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_providers.dart';

class AdminReviewsScreen extends ConsumerWidget {
  const AdminReviewsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(adminReviewsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(20), child: Align(alignment: Alignment.centerLeft, child: Text(isAr ? 'إدارة التقييمات' : 'Reviews Management', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, fontFamily: 'Outfit', color: isDark ? AppColors.white : AppColors.onSurfaceLight)))),
        Expanded(child: reviewsAsync.when(
          data: (reviews) => reviews.isEmpty
              ? Center(child: Text(isAr ? 'لا توجد تقييمات حتى الآن' : 'No reviews yet', style: const TextStyle(fontFamily: 'Outfit')))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: reviews.length,
                  itemBuilder: (ctx, i) {
                    final r = reviews[i];
                    final rating = r['rating'] as int? ?? 0;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: isDark ? AppColors.surfaceDark : AppColors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 4)]),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Row(children: List.generate(5, (si) => Icon(si < rating ? Icons.star_rounded : Icons.star_outline_rounded, color: AppColors.star, size: 16))),
                          const SizedBox(width: 8),
                          Text('${r['rating']}/5', style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, color: AppColors.star)),
                          const Spacer(),
                          Text(_formatDate(r['created_at']), style: TextStyle(fontFamily: 'Outfit', fontSize: 11, color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight)),
                          IconButton(
                            icon: const Icon(Icons.delete_rounded, size: 18, color: AppColors.error),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
                                title: Text(isAr ? 'حذف التقييم' : 'Delete Review', style: const TextStyle(fontFamily: 'Outfit')),
                                content: Text(isAr ? 'هل أنت متأكد من حذف هذا التقييم؟' : 'Are you sure you want to delete this review?', style: const TextStyle(fontFamily: 'Outfit')),
                                actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(isAr ? 'إلغاء' : 'Cancel')), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.error), onPressed: () => Navigator.pop(ctx, true), child: Text(isAr ? 'حذف' : 'Delete', style: const TextStyle(color: Colors.white)))],
                              ));
                              if (confirm == true) {
                                await ref.read(adminDataSourceProvider).deleteReview(r['id'] as String);
                                ref.invalidate(adminReviewsProvider);
                              }
                            },
                            constraints: const BoxConstraints(),
                            tooltip: 'Delete',
                          ),
                        ]),
                        if (r['comment'] != null && (r['comment'] as String).isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(r['comment'] as String, style: const TextStyle(fontFamily: 'Outfit', fontSize: 13)),
                        ],
                        const SizedBox(height: 6),
                        Text('${isAr ? 'المنتج' : 'Product'}: ${(r['product_id'] as String).substring(0, 8)}... | ${isAr ? 'المستخدم' : 'User'}: ${(r['user_id'] as String).substring(0, 8)}...', style: TextStyle(fontFamily: 'Outfit', fontSize: 11, color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight)),
                      ]),
                    );
                  },
                ),
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: AppColors.error))),
        )),
      ]),
    );
  }

  String _formatDate(dynamic raw) {
    if (raw == null) return '';
    final dt = DateTime.tryParse(raw.toString());
    if (dt == null) return '';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
