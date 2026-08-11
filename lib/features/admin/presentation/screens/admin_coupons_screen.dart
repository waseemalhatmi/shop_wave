import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_providers.dart';

class AdminCouponsScreen extends ConsumerWidget {
  const AdminCouponsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couponsAsync = ref.watch(adminCouponsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCouponDialog(context, ref, isDark, isAr),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(isAr ? 'إضافة كوبون' : 'Add Coupon', style: const TextStyle(color: Colors.white, fontFamily: 'Outfit', fontWeight: FontWeight.w700)),
      ),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(20), child: Align(alignment: Alignment.centerLeft, child: Text(isAr ? 'إدارة الكوبونات' : 'Coupons Management', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, fontFamily: 'Outfit', color: isDark ? AppColors.white : AppColors.onSurfaceLight)))),
        Expanded(child: couponsAsync.when(
          data: (coupons) => ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            itemCount: coupons.length,
            itemBuilder: (ctx, i) {
              final c = coupons[i];
              final isActive = c['is_active'] as bool? ?? false;
              final type = c['type'] as String? ?? 'percentage';
              final value = c['value'] as num? ?? 0;
              final usedCount = c['used_count'] as int? ?? 0;
              final maxUses = c['max_uses'] as int?;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: isDark ? AppColors.surfaceDark : AppColors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 6)]),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.primary, style: BorderStyle.solid)),
                      child: Text(c['code'] as String? ?? '', style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primary, letterSpacing: 1.5))),
                    const Spacer(),
                    Switch(value: isActive, activeColor: AppColors.success, onChanged: (val) async {
                      await ref.read(adminDataSourceProvider).updateCoupon(c['id'] as String, {'is_active': val});
                      ref.invalidate(adminCouponsProvider);
                    }),
                    IconButton(icon: const Icon(Icons.edit_rounded, size: 18), color: AppColors.primary, onPressed: () => _showCouponDialog(context, ref, isDark, isAr, existing: c)),
                    IconButton(icon: const Icon(Icons.delete_rounded, size: 18), color: AppColors.error, onPressed: () async {
                      await ref.read(adminDataSourceProvider).deleteCoupon(c['id'] as String);
                      ref.invalidate(adminCouponsProvider);
                    }),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    _BadgeChip(label: type == 'percentage' ? '$value% ${isAr ? 'خصم' : 'OFF'}' : '$value ${isAr ? 'ر.س خصم' : 'SAR OFF'}', color: AppColors.secondary),
                    const SizedBox(width: 8),
                    _BadgeChip(label: isActive ? (isAr ? 'نشط' : 'Active') : (isAr ? 'غير نشط' : 'Inactive'), color: isActive ? AppColors.success : AppColors.error),
                    const SizedBox(width: 8),
                    _BadgeChip(label: '${isAr ? 'مستخدم' : 'Used'}: $usedCount/${maxUses ?? '∞'}', color: AppColors.info),
                  ]),
                  if (c['expires_at'] != null) ...[
                    const SizedBox(height: 6),
                    Text('${isAr ? 'ينتهي في' : 'Expires'}: ${_formatDate(c['expires_at'])}', style: TextStyle(fontFamily: 'Outfit', fontSize: 11, color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight)),
                  ],
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

  void _showCouponDialog(BuildContext context, WidgetRef ref, bool isDark, bool isAr, {Map<String, dynamic>? existing}) {
    final code = TextEditingController(text: existing?['code'] as String? ?? '');
    final value = TextEditingController(text: existing?['value']?.toString() ?? '');
    final minOrder = TextEditingController(text: existing?['min_order_amount']?.toString() ?? '0');
    final maxUses = TextEditingController(text: existing?['max_uses']?.toString() ?? '');
    bool isActive = existing?['is_active'] as bool? ?? true;
    String type = existing?['type'] as String? ?? 'percentage';

    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => AlertDialog(
      title: Text(existing == null ? (isAr ? 'إضافة كوبون' : 'Add Coupon') : (isAr ? 'تعديل الكوبون' : 'Edit Coupon'), style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700)),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: code, decoration: InputDecoration(labelText: isAr ? 'كود الخصم' : 'Coupon Code'), textCapitalization: TextCapitalization.characters),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(value: type, items: ['percentage','fixed'].map((t) => DropdownMenuItem(value: t, child: Text(t == 'percentage' ? (isAr ? 'نسبة مئوية %' : 'Percentage %') : (isAr ? 'مبلغ ثابت' : 'Fixed Amount')))).toList(), onChanged: (v) => setS(() => type = v!), decoration: InputDecoration(labelText: isAr ? 'النوع' : 'Type')),
        const SizedBox(height: 8),
        TextField(controller: value, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: type == 'percentage' ? (isAr ? 'نسبة الخصم %' : 'Discount %') : (isAr ? 'مبلغ الخصم' : 'Discount Amount'))),
        const SizedBox(height: 8),
        TextField(controller: minOrder, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: isAr ? 'الحد الأدنى للطلب' : 'Min. Order Amount')),
        const SizedBox(height: 8),
        TextField(controller: maxUses, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: isAr ? 'الحد الأقصى للاستخدام (فارغ لعدد غير محدود)' : 'Max Uses (Empty for unlimited)')),
        SwitchListTile(value: isActive, onChanged: (v) => setS(() => isActive = v), title: Text(isAr ? 'نشط' : 'Active')),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isAr ? 'إلغاء' : 'Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          onPressed: () async {
            final data = {'code': code.text, 'type': type, 'value': num.tryParse(value.text) ?? 0, 'min_order_amount': num.tryParse(minOrder.text) ?? 0, 'max_uses': int.tryParse(maxUses.text), 'is_active': isActive};
            if (existing == null) {
              await ref.read(adminDataSourceProvider).createCoupon(data);
            } else {
              await ref.read(adminDataSourceProvider).updateCoupon(existing['id'] as String, data);
            }
            ref.invalidate(adminCouponsProvider);
            if (ctx.mounted) Navigator.pop(ctx);
          },
          child: Text(isAr ? 'حفظ' : 'Save', style: const TextStyle(color: Colors.white)),
        ),
      ],
    )));
  }
}

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'Outfit')),
    );
  }
}
