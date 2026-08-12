import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_providers.dart';

class AdminBannersScreen extends ConsumerWidget {
  const AdminBannersScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannersAsync = ref.watch(adminBannersProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBannerDialog(context, ref, isDark, isAr),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(isAr ? 'إضافة بنر' : 'Add Banner', style: const TextStyle(color: Colors.white, fontFamily: 'Outfit', fontWeight: FontWeight.w700)),
      ),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(20), child: Align(alignment: Alignment.centerLeft, child: Text(isAr ? 'إدارة البنرات' : 'Banners Management', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, fontFamily: 'Outfit', color: isDark ? AppColors.white : AppColors.onSurfaceLight)))),
        Expanded(child: bannersAsync.when(
          data: (banners) => ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            itemCount: banners.length,
            itemBuilder: (ctx, i) {
              final b = banners[i];
              final isActive = b['is_active'] as bool? ?? false;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(color: isDark ? AppColors.surfaceDark : AppColors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 6)]),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (b['image_url'] != null)
                    ClipRRect(borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
                      child: Image.network(b['image_url'] as String, width: double.infinity, height: 120, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(height: 120, color: AppColors.primaryLight, child: const Icon(Icons.image, color: AppColors.primary, size: 40)))),
                  Padding(padding: const EdgeInsets.all(12), child: Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(b[isAr ? 'title_ar' : 'title_en'] as String? ?? (isAr ? 'بنر' : 'Banner'), style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700)),
                      Text('${isAr ? 'النوع' : 'Action'}: ${b['action_type'] ?? (isAr ? 'لا يوجد' : 'none')}', style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight)),
                    ])),
                    Switch(value: isActive, activeColor: AppColors.success, onChanged: (val) async {
                      await ref.read(adminDataSourceProvider).updateBanner(b['id'] as String, {'is_active': val});
                      ref.invalidate(adminBannersProvider);
                    }),
                    IconButton(icon: const Icon(Icons.edit_rounded, size: 18), color: AppColors.primary, onPressed: () => _showBannerDialog(context, ref, isDark, isAr, existing: b)),
                    IconButton(icon: const Icon(Icons.delete_rounded, size: 18), color: AppColors.error, onPressed: () async {
                      await ref.read(adminDataSourceProvider).deleteBanner(b['id'] as String);
                      ref.invalidate(adminBannersProvider);
                    }),
                  ])),
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

  void _showBannerDialog(BuildContext context, WidgetRef ref, bool isDark, bool isAr, {Map<String, dynamic>? existing}) {
    final titleEn = TextEditingController(text: existing?['title_en'] as String? ?? '');
    final titleAr = TextEditingController(text: existing?['title_ar'] as String? ?? '');
    final imageUrl = TextEditingController(text: existing?['image_url'] as String? ?? '');
    final actionValue = TextEditingController(text: existing?['action_value'] as String? ?? '');
    bool isActive = existing?['is_active'] as bool? ?? true;
    String? actionType = existing?['action_type'] as String?;

    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => AlertDialog(
      title: Text(existing == null ? (isAr ? 'إضافة بنر' : 'Add Banner') : (isAr ? 'تعديل البنر' : 'Edit Banner'), style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700)),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: titleEn, decoration: InputDecoration(labelText: isAr ? 'العنوان (إنجليزي)' : 'Title (EN)')),
        const SizedBox(height: 8),
        TextField(controller: titleAr, decoration: InputDecoration(labelText: isAr ? 'العنوان (عربي)' : 'Title (AR)')),
        const SizedBox(height: 8),
        TextField(controller: imageUrl, decoration: InputDecoration(labelText: isAr ? 'رابط الصورة' : 'Image URL')),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(value: actionType, hint: Text(isAr ? 'نوع الإجراء' : 'Action Type'), items: ['product','category','url'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(), onChanged: (v) => setS(() => actionType = v)),
        const SizedBox(height: 8),
        TextField(controller: actionValue, decoration: InputDecoration(labelText: isAr ? 'قيمة الإجراء' : 'Action Value')),
        SwitchListTile(value: isActive, onChanged: (v) => setS(() => isActive = v), title: Text(isAr ? 'نشط' : 'Active')),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isAr ? 'إلغاء' : 'Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          onPressed: () async {
            final data = {'title_en': titleEn.text, 'title_ar': titleAr.text, 'image_url': imageUrl.text, 'action_type': actionType, 'action_value': actionValue.text, 'is_active': isActive};
            if (existing == null) {
              await ref.read(adminDataSourceProvider).createBanner(data);
            } else {
              await ref.read(adminDataSourceProvider).updateBanner(existing['id'] as String, data);
            }
            ref.invalidate(adminBannersProvider);
            if (ctx.mounted) Navigator.pop(ctx);
          },
          child: Text(isAr ? 'حفظ' : 'Save', style: const TextStyle(color: Colors.white)),
        ),
      ],
    )));
  }
}
