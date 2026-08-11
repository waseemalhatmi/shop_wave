import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_providers.dart';

class AdminCategoriesScreen extends ConsumerStatefulWidget {
  const AdminCategoriesScreen({super.key});
  @override
  ConsumerState<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends ConsumerState<AdminCategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    final catsAsync = ref.watch(adminCategoriesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryDialog(context, ref, isDark, isAr),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(isAr ? 'إضافة قسم' : 'Add Category', style: const TextStyle(color: Colors.white, fontFamily: 'Outfit', fontWeight: FontWeight.w700)),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Align(alignment: Alignment.centerLeft, child: Text(isAr ? 'الأقسام' : 'Categories', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, fontFamily: 'Outfit', color: isDark ? AppColors.white : AppColors.onSurfaceLight))),
        ),
        Expanded(child: catsAsync.when(
          data: (cats) => ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            itemCount: cats.length,
            itemBuilder: (ctx, i) {
              final c = cats[i];
              final isActive = c['is_active'] as bool? ?? true;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: isDark ? AppColors.surfaceDark : AppColors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 4)]),
                child: Row(children: [
                  Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                    child: c['image_url'] != null ? ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(c['image_url']!.toString(), fit: BoxFit.cover)) : const Icon(Icons.category_rounded, color: AppColors.primary)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(c[isAr ? 'name_ar' : 'name_en']?.toString() ?? '', style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700)),
                    Text(c[isAr ? 'name_en' : 'name_ar']?.toString() ?? '', style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight)),
                  ])),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: isActive ? AppColors.successLight : AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                    child: Text(isActive ? (isAr ? 'نشط' : 'Active') : (isAr ? 'غير نشط' : 'Inactive'), style: TextStyle(color: isActive ? AppColors.success : AppColors.error, fontSize: 11, fontFamily: 'Outfit', fontWeight: FontWeight.w700))),
                  IconButton(icon: const Icon(Icons.edit_rounded, size: 18), color: AppColors.primary, onPressed: () => _showCategoryDialog(context, ref, isDark, isAr, existing: c)),
                  IconButton(icon: const Icon(Icons.delete_rounded, size: 18), color: AppColors.error, onPressed: () async {
                    await ref.read(adminDataSourceProvider).deleteCategory(c['id'] as String);
                    ref.invalidate(adminCategoriesProvider);
                  }),
                ]),
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (e, _) => Center(child: Text(isAr ? 'خطأ: $e' : 'Error: $e')),
        )),
      ]),
    );
  }

  void _showCategoryDialog(BuildContext context, WidgetRef ref, bool isDark, bool isAr, {Map<String, dynamic>? existing}) {
    final nameEn = TextEditingController(text: existing?['name_en'] as String? ?? '');
    final nameAr = TextEditingController(text: existing?['name_ar'] as String? ?? '');
    final slug = TextEditingController(text: existing?['slug'] as String? ?? '');
    bool isActive = existing?['is_active'] as bool? ?? true;

    showDialog(context: context, builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDlgState) => AlertDialog(
        title: Text(existing == null ? (isAr ? 'إضافة قسم' : 'Add Category') : (isAr ? 'تعديل القسم' : 'Edit Category'), style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameEn, decoration: InputDecoration(labelText: isAr ? 'الاسم (إنجليزي)' : 'Name (English)', labelStyle: const TextStyle(fontFamily: 'Outfit'))),
          const SizedBox(height: 8),
          TextField(controller: nameAr, decoration: InputDecoration(labelText: isAr ? 'الاسم (عربي)' : 'Name (Arabic)', labelStyle: const TextStyle(fontFamily: 'Outfit'))),
          const SizedBox(height: 8),
          TextField(controller: slug, decoration: InputDecoration(labelText: isAr ? 'الرابط (Slug)' : 'Slug', labelStyle: const TextStyle(fontFamily: 'Outfit'))),
          SwitchListTile(value: isActive, onChanged: (v) => setDlgState(() => isActive = v), title: Text(isAr ? 'نشط' : 'Active', style: const TextStyle(fontFamily: 'Outfit'))),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isAr ? 'إلغاء' : 'Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              final data = {'name_en': nameEn.text, 'name_ar': nameAr.text, 'slug': slug.text.isNotEmpty ? slug.text : nameEn.text.toLowerCase().replaceAll(' ', '-'), 'is_active': isActive};
              if (existing == null) {
                await ref.read(adminDataSourceProvider).createCategory(data);
              } else {
                await ref.read(adminDataSourceProvider).updateCategory(existing['id'] as String, data);
              }
              ref.invalidate(adminCategoriesProvider);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(isAr ? 'حفظ' : 'Save', style: const TextStyle(color: Colors.white, fontFamily: 'Outfit')),
          ),
        ],
      ),
    ));
  }
}

