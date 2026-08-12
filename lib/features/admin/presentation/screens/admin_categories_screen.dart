import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_categories_notifier.dart';

class AdminCategoriesScreen extends ConsumerStatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  ConsumerState<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends ConsumerState<AdminCategoriesScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(adminCategoriesNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryDialog(context, ref, isDark, isAr),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          isAr ? 'إضافة قسم' : 'Add Category',
          style: const TextStyle(color: Colors.white, fontFamily: 'Outfit', fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + Count
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAr ? 'إدارة الأقسام' : 'Categories Management',
                            style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w800, fontFamily: 'Outfit',
                              color: isDark ? AppColors.white : AppColors.onSurfaceLight,
                            ),
                          ),
                          if (stateAsync.value != null)
                            Text(
                              isAr ? 'اسحب لإعادة الترتيب' : 'Drag to reorder',
                              style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (stateAsync.value != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          '${stateAsync.value!.categories.length} ${isAr ? 'قسم' : 'categories'}',
                          style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.primary),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),

                // Search Field
                TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => ref.read(adminCategoriesNotifierProvider.notifier).setSearch(v),
                  decoration: InputDecoration(
                    hintText: isAr ? 'البحث في الأقسام...' : 'Search categories...',
                    hintStyle: const TextStyle(fontFamily: 'Outfit'),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchCtrl.clear();
                              ref.read(adminCategoriesNotifierProvider.notifier).setSearch('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: isDark ? AppColors.surfaceDark : AppColors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
          ),

          // ── Categories List ─────────────────────────────────────────────
          Expanded(
            child: stateAsync.when(
              data: (st) {
                final categories = st.filteredCategories;
                final isSearching = st.search.isNotEmpty;

                return categories.isEmpty
                    ? _EmptyState(isAr: isAr, isSearching: isSearching)
                    : isSearching
                        // When searching: plain ListView (no drag)
                        ? ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                            itemCount: categories.length,
                            itemBuilder: (ctx, i) => _CategoryCard(
                              category: categories[i],
                              isDark: isDark,
                              isAr: isAr,
                              isDraggable: false,
                              onEdit: () => _showCategoryDialog(context, ref, isDark, isAr, existing: categories[i]),
                              onDelete: () => _confirmDelete(context, ref, categories[i], isAr),
                              onToggle: (val) async {
                                try {
                                  await ref.read(adminCategoriesNotifierProvider.notifier).toggleActive(categories[i]['id'] as String, val);
                                } catch (_) {}
                              },
                            ),
                          )
                        // Normal mode: ReorderableListView for drag & drop
                        : ReorderableListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                            proxyDecorator: (child, index, animation) => Material(
                              elevation: 8,
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              child: child,
                            ),
                            onReorder: (oldIndex, newIndex) async {
                              try {
                                await ref.read(adminCategoriesNotifierProvider.notifier).reorder(oldIndex, newIndex);
                              } catch (_) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(isAr ? 'فشل تحديث الترتيب' : 'Failed to update order', style: const TextStyle(fontFamily: 'Outfit')),
                                    backgroundColor: AppColors.error,
                                    behavior: SnackBarBehavior.floating,
                                  ));
                                }
                              }
                            },
                            itemCount: categories.length,
                            itemBuilder: (ctx, i) => _CategoryCard(
                              key: ValueKey(categories[i]['id']),
                              category: categories[i],
                              isDark: isDark,
                              isAr: isAr,
                              isDraggable: true,
                              onEdit: () => _showCategoryDialog(context, ref, isDark, isAr, existing: categories[i]),
                              onDelete: () => _confirmDelete(context, ref, categories[i], isAr),
                              onToggle: (val) async {
                                try {
                                  await ref.read(adminCategoriesNotifierProvider.notifier).toggleActive(categories[i]['id'] as String, val);
                                } catch (_) {}
                              },
                            ),
                          );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (e, _) => _ErrorState(
                isAr: isAr,
                onRetry: () => ref.invalidate(adminCategoriesNotifierProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Map<String, dynamic> category, bool isAr) {
    final productCount = category['product_count'] as int? ?? 0;
    final name = category[isAr ? 'name_ar' : 'name_en'] as String? ?? '';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isAr ? 'حذف القسم' : 'Delete Category', style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAr ? 'هل أنت متأكد من حذف قسم "$name"؟' : 'Delete category "$name"?',
              style: const TextStyle(fontFamily: 'Outfit'),
            ),
            if (productCount > 0) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(
                    isAr ? 'يحتوي على $productCount منتج! سيتأثر هذه المنتجات بالحذف.' : 'Contains $productCount products! These products will be affected.',
                    style: const TextStyle(fontFamily: 'Outfit', color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w600),
                  )),
                ]),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isAr ? 'إلغاء' : 'Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(adminCategoriesNotifierProvider.notifier).deleteCategory(category['id'] as String);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(isAr ? 'تم حذف القسم' : 'Category deleted', style: const TextStyle(fontFamily: 'Outfit')),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ));
                }
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(isAr ? 'فشل الحذف' : 'Delete failed', style: const TextStyle(fontFamily: 'Outfit')),
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

  void _showCategoryDialog(BuildContext context, WidgetRef ref, bool isDark, bool isAr, {Map<String, dynamic>? existing}) {
    final nameEnCtrl = TextEditingController(text: existing?['name_en'] as String? ?? '');
    final nameArCtrl = TextEditingController(text: existing?['name_ar'] as String? ?? '');
    final slugCtrl = TextEditingController(text: existing?['slug'] as String? ?? '');
    bool isActive = existing?['is_active'] as bool? ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(children: [
            const Icon(Icons.category_rounded, color: AppColors.primary, size: 22),
            const SizedBox(width: 8),
            Text(
              existing == null ? (isAr ? 'إضافة قسم' : 'Add Category') : (isAr ? 'تعديل القسم' : 'Edit Category'),
              style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ]),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                controller: nameEnCtrl,
                decoration: InputDecoration(
                  labelText: isAr ? 'الاسم (إنجليزي)' : 'Name (English)',
                  labelStyle: const TextStyle(fontFamily: 'Outfit'),
                  prefixIcon: const Icon(Icons.translate_rounded, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: nameArCtrl,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  labelText: isAr ? 'الاسم (عربي)' : 'Name (Arabic)',
                  labelStyle: const TextStyle(fontFamily: 'Outfit'),
                  prefixIcon: const Icon(Icons.translate_rounded, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: slugCtrl,
                decoration: InputDecoration(
                  labelText: isAr ? 'الرابط (Slug)' : 'Slug (URL)',
                  hintText: 'electronics',
                  labelStyle: const TextStyle(fontFamily: 'Outfit'),
                  prefixIcon: const Icon(Icons.link_rounded, color: AppColors.primary),
                  helperText: isAr ? 'اتركه فارغاً ليُنشأ تلقائياً' : 'Leave empty to auto-generate',
                ),
              ),
              const SizedBox(height: 6),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(isAr ? 'نشط' : 'Active', style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600)),
                value: isActive,
                onChanged: (v) => setS(() => isActive = v),
                activeColor: AppColors.success,
              ),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isAr ? 'إلغاء' : 'Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () async {
                final nameEn = nameEnCtrl.text.trim();
                final nameAr = nameArCtrl.text.trim();

                if (nameEn.isEmpty || nameAr.isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                    content: Text(isAr ? 'يرجى ملء جميع الحقول الإلزامية' : 'Please fill required fields', style: const TextStyle(fontFamily: 'Outfit')),
                    backgroundColor: AppColors.error,
                  ));
                  return;
                }

                final slug = slugCtrl.text.trim().isNotEmpty
                    ? slugCtrl.text.trim().toLowerCase().replaceAll(' ', '-')
                    : nameEn.toLowerCase().replaceAll(' ', '-');

                final data = <String, dynamic>{
                  'name_en': nameEn,
                  'name_ar': nameAr,
                  'slug': slug,
                  'is_active': isActive,
                };

                Navigator.pop(ctx);
                try {
                  if (existing == null) {
                    await ref.read(adminCategoriesNotifierProvider.notifier).createCategory(data);
                  } else {
                    await ref.read(adminCategoriesNotifierProvider.notifier).updateCategory(existing['id'] as String, data);
                  }
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(isAr ? 'تم الحفظ بنجاح' : 'Saved successfully', style: const TextStyle(fontFamily: 'Outfit')),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ));
                  }
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(isAr ? 'فشل الحفظ' : 'Save failed', style: const TextStyle(fontFamily: 'Outfit')),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                    ));
                  }
                }
              },
              child: Text(isAr ? 'حفظ' : 'Save', style: const TextStyle(color: Colors.white, fontFamily: 'Outfit', fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Category Card ─────────────────────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    super.key,
    required this.category, required this.isDark, required this.isAr,
    required this.isDraggable, required this.onEdit, required this.onDelete, required this.onToggle,
  });
  final Map<String, dynamic> category;
  final bool isDark, isAr, isDraggable;
  final VoidCallback onEdit, onDelete;
  final void Function(bool) onToggle;

  @override
  Widget build(BuildContext context) {
    final isActive = category['is_active'] as bool? ?? true;
    final productCount = category['product_count'] as int? ?? 0;
    final imageUrl = category['image_url'] as String?;
    final nameMain = category[isAr ? 'name_ar' : 'name_en'] as String? ?? '';
    final nameSub = category[isAr ? 'name_en' : 'name_ar'] as String? ?? '';
    final slug = category['slug'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: isDark ? Colors.black26 : AppColors.shadowLight, blurRadius: 8, offset: const Offset(0, 3))],
        border: !isActive ? Border.all(color: Colors.grey.withValues(alpha: 0.3)) : Border.all(color: Colors.transparent),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Drag Handle
            if (isDraggable)
              Padding(
                padding: const EdgeInsets.only(right: 6, left: 2),
                child: Icon(Icons.drag_indicator_rounded, color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight, size: 24),
              ),

            // Category Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl, width: 56, height: 56, fit: BoxFit.cover,
                      memCacheWidth: 120,
                      errorWidget: (_, __, ___) => _PlaceholderIcon(isDark: isDark),
                    )
                  : _PlaceholderIcon(isDark: isDark),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(nameMain, style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, fontSize: 15, color: isDark ? AppColors.white : AppColors.onSurfaceLight), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 8),
                      // Active Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.successLight : Colors.grey.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isActive ? (isAr ? 'نشط' : 'Active') : (isAr ? 'معطل' : 'Inactive'),
                          style: TextStyle(color: isActive ? AppColors.success : Colors.grey, fontSize: 10, fontWeight: FontWeight.w800, fontFamily: 'Outfit'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(nameSub, style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // Product count badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                        child: Text(
                          '$productCount ${isAr ? 'منتج' : 'products'}',
                          style: const TextStyle(fontFamily: 'Outfit', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                        ),
                      ),
                      if (slug.isNotEmpty)
                        Text('/$slug', style: TextStyle(fontFamily: 'Outfit', fontSize: 11, color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Actions Column
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Transform.scale(
                  scale: 0.85,
                  child: Switch(value: isActive, onChanged: onToggle, activeColor: AppColors.success, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: onEdit,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.edit_rounded, size: 16, color: AppColors.primary)),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: onDelete,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.error)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderIcon extends StatelessWidget {
  const _PlaceholderIcon({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52, height: 52,
      decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
      child: const Icon(Icons.category_rounded, color: AppColors.primary, size: 26),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isAr, required this.isSearching});
  final bool isAr, isSearching;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(isSearching ? Icons.search_off_rounded : Icons.category_outlined, size: 72, color: Colors.grey.shade400),
        const SizedBox(height: 16),
        Text(
          isSearching ? (isAr ? 'لا نتائج للبحث' : 'No search results') : (isAr ? 'لا توجد أقسام' : 'No categories yet'),
          style: TextStyle(fontFamily: 'Outfit', fontSize: 18, fontWeight: FontWeight.w700, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 8),
        Text(
          isSearching ? (isAr ? 'جرّب كلمة بحث أخرى' : 'Try a different keyword') : (isAr ? 'اضغط + لإضافة أول قسم' : 'Tap + to add the first category'),
          style: TextStyle(fontFamily: 'Outfit', fontSize: 13, color: Colors.grey.shade500),
        ),
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
        Text(isAr ? 'فشل تحميل الأقسام' : 'Failed to load categories', style: const TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.error)),
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
