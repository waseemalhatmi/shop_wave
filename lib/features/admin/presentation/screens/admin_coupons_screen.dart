import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_coupons_notifier.dart';

class AdminCouponsScreen extends ConsumerWidget {
  const AdminCouponsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(adminCouponsNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final currentFilter = stateAsync.value?.filter ?? CouponStatusFilter.all;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCouponDialog(context, ref, isDark, isAr),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          isAr ? 'إضافة كوبون' : 'Add Coupon',
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
                // Title
                Text(
                  isAr ? 'إدارة الكوبونات' : 'Coupons Management',
                  style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800, fontFamily: 'Outfit',
                    color: isDark ? AppColors.white : AppColors.onSurfaceLight,
                  ),
                ),
                const SizedBox(height: 4),
                if (stateAsync.value != null)
                  Text(
                    '${stateAsync.value!.coupons.length} ${isAr ? 'كوبون إجمالاً' : 'total coupons'}',
                    style: TextStyle(fontFamily: 'Outfit', fontSize: 13, color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight),
                  ),
                const SizedBox(height: 12),

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(label: isAr ? 'الكل' : 'All', isSelected: currentFilter == CouponStatusFilter.all, color: AppColors.primary, onTap: () => ref.read(adminCouponsNotifierProvider.notifier).setFilter(CouponStatusFilter.all)),
                      const SizedBox(width: 8),
                      _FilterChip(label: isAr ? 'نشط' : 'Active', isSelected: currentFilter == CouponStatusFilter.active, color: AppColors.success, onTap: () => ref.read(adminCouponsNotifierProvider.notifier).setFilter(CouponStatusFilter.active)),
                      const SizedBox(width: 8),
                      _FilterChip(label: isAr ? 'غير نشط' : 'Inactive', isSelected: currentFilter == CouponStatusFilter.inactive, color: Colors.grey, onTap: () => ref.read(adminCouponsNotifierProvider.notifier).setFilter(CouponStatusFilter.inactive)),
                      const SizedBox(width: 8),
                      _FilterChip(label: isAr ? 'منتهي' : 'Expired', isSelected: currentFilter == CouponStatusFilter.expired, color: AppColors.error, onTap: () => ref.read(adminCouponsNotifierProvider.notifier).setFilter(CouponStatusFilter.expired)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Coupons List ────────────────────────────────────────────────
          Expanded(
            child: stateAsync.when(
              data: (st) {
                final coupons = st.filteredCoupons;
                return coupons.isEmpty
                    ? _EmptyState(isAr: isAr, filter: st.filter)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        itemCount: coupons.length,
                        itemBuilder: (ctx, i) => _CouponCard(
                          coupon: coupons[i],
                          isDark: isDark,
                          isAr: isAr,
                          onToggle: (val) async {
                            try {
                              await ref.read(adminCouponsNotifierProvider.notifier).toggleActive(coupons[i]['id'] as String, val);
                            } catch (_) {
                              if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(isAr ? 'فشل التحديث' : 'Update failed'), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating));
                            }
                          },
                          onEdit: () => _showCouponDialog(context, ref, isDark, isAr, existing: coupons[i]),
                          onDelete: () => _confirmDelete(context, ref, coupons[i]['id'] as String, coupons[i]['code'] as String? ?? '', isAr),
                          onCopyCode: () {
                            Clipboard.setData(ClipboardData(text: coupons[i]['code'] as String? ?? ''));
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(isAr ? 'تم نسخ الكود' : 'Code copied!', style: const TextStyle(fontFamily: 'Outfit')),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: AppColors.success,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              duration: const Duration(seconds: 1),
                            ));
                          },
                        ),
                      );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (e, _) => Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 64),
                  const SizedBox(height: 12),
                  Text(isAr ? 'فشل تحميل الكوبونات' : 'Failed to load coupons', style: const TextStyle(fontFamily: 'Outfit', color: AppColors.error, fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => ref.invalidate(adminCouponsNotifierProvider),
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(isAr ? 'إعادة المحاولة' : 'Retry'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  ),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id, String code, bool isAr) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isAr ? 'حذف الكوبون' : 'Delete Coupon', style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700)),
        content: Text(isAr ? 'هل أنت متأكد من حذف كوبون "$code"؟ لا يمكن التراجع.' : 'Delete coupon "$code"? This cannot be undone.', style: const TextStyle(fontFamily: 'Outfit')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isAr ? 'إلغاء' : 'Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(adminCouponsNotifierProvider.notifier).deleteCoupon(id);
              } catch (_) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isAr ? 'فشل الحذف' : 'Delete failed'), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating));
              }
            },
            child: Text(isAr ? 'حذف' : 'Delete', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCouponDialog(BuildContext context, WidgetRef ref, bool isDark, bool isAr, {Map<String, dynamic>? existing}) {
    final codeCtrl = TextEditingController(text: existing?['code'] as String? ?? '');
    final valueCtrl = TextEditingController(text: existing?['value']?.toString() ?? '');
    final minOrderCtrl = TextEditingController(text: existing?['min_order_amount']?.toString() ?? '0');
    final maxUsesCtrl = TextEditingController(text: existing?['max_uses']?.toString() ?? '');
    bool isActive = existing?['is_active'] as bool? ?? true;
    String type = existing?['type'] as String? ?? 'percentage';
    DateTime? expiresAt;
    if (existing?['expires_at'] != null) {
      expiresAt = DateTime.tryParse(existing!['expires_at'].toString());
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(children: [
            const Icon(Icons.local_offer_rounded, color: AppColors.primary, size: 22),
            const SizedBox(width: 8),
            Text(
              existing == null ? (isAr ? 'إضافة كوبون' : 'Add Coupon') : (isAr ? 'تعديل الكوبون' : 'Edit Coupon'),
              style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ]),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(
                  controller: codeCtrl,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w800, letterSpacing: 2),
                  decoration: InputDecoration(
                    labelText: isAr ? 'كود الخصم' : 'Coupon Code',
                    hintText: 'SAVE20',
                    prefixIcon: const Icon(Icons.confirmation_number_rounded, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: InputDecoration(
                    labelText: isAr ? 'نوع الخصم' : 'Discount Type',
                    prefixIcon: const Icon(Icons.percent_rounded, color: AppColors.primary),
                  ),
                  items: [
                    DropdownMenuItem(value: 'percentage', child: Text(isAr ? 'نسبة مئوية (%)' : 'Percentage (%)', style: const TextStyle(fontFamily: 'Outfit'))),
                    DropdownMenuItem(value: 'fixed', child: Text(isAr ? 'مبلغ ثابت (ر.س)' : 'Fixed Amount (SAR)', style: const TextStyle(fontFamily: 'Outfit'))),
                  ],
                  onChanged: (v) => setS(() => type = v!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: valueCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: type == 'percentage' ? (isAr ? 'نسبة الخصم %' : 'Discount %') : (isAr ? 'مبلغ الخصم ر.س' : 'Discount SAR'),
                    prefixIcon: Icon(type == 'percentage' ? Icons.percent_rounded : Icons.currency_bitcoin_rounded, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: minOrderCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: isAr ? 'الحد الأدنى للطلب (ر.س)' : 'Min Order (SAR)',
                    prefixIcon: const Icon(Icons.shopping_cart_rounded, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: maxUsesCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: isAr ? 'الحد الأقصى للاستخدام (اتركه فارغاً = غير محدود)' : 'Max Uses (empty = unlimited)',
                    prefixIcon: const Icon(Icons.people_rounded, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 12),
                // Expiry Date Picker
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_rounded, color: AppColors.primary),
                  title: Text(
                    expiresAt != null
                        ? '${isAr ? 'ينتهي في' : 'Expires'}: ${expiresAt!.day}/${expiresAt!.month}/${expiresAt!.year}'
                        : (isAr ? 'بدون تاريخ انتهاء' : 'No expiry date'),
                    style: const TextStyle(fontFamily: 'Outfit', fontSize: 14),
                  ),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(
                      icon: const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 20),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: expiresAt ?? DateTime.now().add(const Duration(days: 30)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                        );
                        if (picked != null) setS(() => expiresAt = picked);
                      },
                    ),
                    if (expiresAt != null)
                      IconButton(icon: const Icon(Icons.clear_rounded, size: 18), onPressed: () => setS(() => expiresAt = null)),
                  ]),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(isAr ? 'نشط' : 'Active', style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600)),
                  value: isActive,
                  onChanged: (v) => setS(() => isActive = v),
                  activeColor: AppColors.success,
                ),
              ]),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isAr ? 'إلغاء' : 'Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () async {
                final code = codeCtrl.text.trim().toUpperCase();
                final value = double.tryParse(valueCtrl.text.trim()) ?? 0;
                final minOrder = double.tryParse(minOrderCtrl.text.trim()) ?? 0;
                final maxUses = int.tryParse(maxUsesCtrl.text.trim());

                if (code.isEmpty || value <= 0) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                    content: Text(isAr ? 'تأكد من ملء الحقول الإلزامية' : 'Fill required fields', style: const TextStyle(fontFamily: 'Outfit')),
                    backgroundColor: AppColors.error,
                  ));
                  return;
                }

                final data = <String, dynamic>{
                  'code': code,
                  'type': type,
                  'value': value,
                  'min_order_amount': minOrder,
                  'is_active': isActive,
                  if (maxUses != null) 'max_uses': maxUses,
                  if (expiresAt != null) 'expires_at': expiresAt!.toIso8601String(),
                };

                Navigator.pop(ctx);
                try {
                  if (existing == null) {
                    await ref.read(adminCouponsNotifierProvider.notifier).createCoupon(data);
                  } else {
                    await ref.read(adminCouponsNotifierProvider.notifier).updateCoupon(existing['id'] as String, data);
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

// ── Coupon Card ───────────────────────────────────────────────────────────────

class _CouponCard extends StatelessWidget {
  const _CouponCard({
    required this.coupon, required this.isDark, required this.isAr,
    required this.onToggle, required this.onEdit, required this.onDelete, required this.onCopyCode,
  });
  final Map<String, dynamic> coupon;
  final bool isDark, isAr;
  final void Function(bool) onToggle;
  final VoidCallback onEdit, onDelete, onCopyCode;

  bool get _isExpired {
    final expiresAt = coupon['expires_at'];
    if (expiresAt == null) return false;
    final dt = DateTime.tryParse(expiresAt.toString());
    return dt != null && dt.isBefore(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final isActive = coupon['is_active'] as bool? ?? false;
    final type = coupon['type'] as String? ?? 'percentage';
    final value = coupon['value'] as num? ?? 0;
    final usedCount = coupon['used_count'] as int? ?? 0;
    final maxUses = coupon['max_uses'] as int?;
    final code = coupon['code'] as String? ?? '';
    final isExpired = _isExpired;
    final effectivelyActive = isActive && !isExpired;

    // Usage progress (0.0 - 1.0)
    final double progress = maxUses != null && maxUses > 0 ? (usedCount / maxUses).clamp(0.0, 1.0) : 0.0;
    final bool nearLimit = maxUses != null && progress >= 0.8;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 8, offset: const Offset(0, 3))],
        border: isExpired
            ? Border.all(color: AppColors.error.withValues(alpha: 0.4), width: 1)
            : (!effectivelyActive ? Border.all(color: Colors.grey.withValues(alpha: 0.3), width: 1) : null),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Row: Code + Toggle + Actions ──────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
            child: Row(
              children: [
                // Code with copy button
                GestureDetector(
                  onTap: onCopyCode,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: effectivelyActive ? AppColors.primaryLight : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: effectivelyActive ? AppColors.primary : Colors.grey.shade400,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(
                        code,
                        style: TextStyle(
                          fontFamily: 'Outfit', fontWeight: FontWeight.w800, fontSize: 16,
                          color: effectivelyActive ? AppColors.primary : Colors.grey.shade500,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.copy_rounded, size: 14, color: effectivelyActive ? AppColors.primary : Colors.grey.shade400),
                    ]),
                  ),
                ),
                const Spacer(),
                // Expired badge
                if (isExpired)
                  Container(
                    margin: const EdgeInsets.only(right: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(isAr ? 'منتهي' : 'Expired', style: const TextStyle(color: AppColors.error, fontSize: 10, fontWeight: FontWeight.w700, fontFamily: 'Outfit')),
                  ),
                Switch(
                  value: isActive,
                  onChanged: isExpired ? null : onToggle,
                  activeColor: AppColors.success,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                IconButton(
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  color: AppColors.primary,
                  onPressed: onEdit,
                  tooltip: isAr ? 'تعديل' : 'Edit',
                  constraints: const BoxConstraints(),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  color: AppColors.error,
                  onPressed: onDelete,
                  tooltip: isAr ? 'حذف' : 'Delete',
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),

          // ── Badges Row ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Wrap(
              spacing: 8, runSpacing: 6,
              children: [
                _BadgeChip(
                  label: type == 'percentage' ? '$value% ${isAr ? 'خصم' : 'OFF'}' : '$value ${isAr ? 'ر.س خصم' : 'SAR OFF'}',
                  color: AppColors.secondary,
                ),
                if (coupon['min_order_amount'] != null && (coupon['min_order_amount'] as num) > 0)
                  _BadgeChip(
                    label: '${isAr ? 'حد أدنى' : 'Min'}: ${coupon['min_order_amount']} ${isAr ? 'ر.س' : 'SAR'}',
                    color: AppColors.info,
                  ),
                if (coupon['expires_at'] != null) ...[
                  _BadgeChip(
                    label: () {
                      final dt = DateTime.tryParse(coupon['expires_at'].toString());
                      if (dt == null) return '';
                      return '${isAr ? 'ينتهي' : 'Exp'}: ${dt.day}/${dt.month}/${dt.year}';
                    }(),
                    color: isExpired ? AppColors.error : Colors.orange,
                  ),
                ],
              ],
            ),
          ),

          // ── Usage Progress Bar ────────────────────────────────────────
          if (maxUses != null && maxUses > 0) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(
                    isAr ? 'الاستخدام' : 'Usage',
                    style: TextStyle(fontFamily: 'Outfit', fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight),
                  ),
                  Text(
                    '$usedCount / $maxUses',
                    style: TextStyle(fontFamily: 'Outfit', fontSize: 11, fontWeight: FontWeight.w700, color: nearLimit ? AppColors.error : (isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight)),
                  ),
                ]),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: isDark ? Colors.white12 : Colors.black12,
                    valueColor: AlwaysStoppedAnimation<Color>(nearLimit ? AppColors.error : AppColors.success),
                    minHeight: 6,
                  ),
                ),
              ]),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Text(
                '${isAr ? 'مستخدم' : 'Used'}: $usedCount ${isAr ? 'مرة' : 'times'} | ${isAr ? 'غير محدود' : 'Unlimited uses'}',
                style: TextStyle(fontFamily: 'Outfit', fontSize: 11, color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight),
              ),
            ),

          const SizedBox(height: 14),
        ],
      ),
    );
  }
}

// ── Badge Chip ────────────────────────────────────────────────────────────────

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700, fontFamily: 'Outfit')),
    );
  }
}

// ── Filter Chip ───────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.isSelected, required this.color, required this.onTap});
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : Colors.grey.shade400),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Outfit', fontWeight: FontWeight.w600, fontSize: 12,
            color: isSelected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isAr, required this.filter});
  final bool isAr;
  final CouponStatusFilter filter;

  @override
  Widget build(BuildContext context) {
    final message = switch (filter) {
      CouponStatusFilter.active => isAr ? 'لا توجد كوبونات نشطة' : 'No active coupons',
      CouponStatusFilter.inactive => isAr ? 'لا توجد كوبونات غير نشطة' : 'No inactive coupons',
      CouponStatusFilter.expired => isAr ? 'لا توجد كوبونات منتهية' : 'No expired coupons',
      CouponStatusFilter.all => isAr ? 'لا توجد كوبونات' : 'No coupons yet',
    };

    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.local_offer_outlined, size: 72, color: Colors.grey.shade400),
        const SizedBox(height: 16),
        Text(message, style: TextStyle(fontFamily: 'Outfit', fontSize: 18, fontWeight: FontWeight.w700, color: Colors.grey.shade600)),
        const SizedBox(height: 8),
        if (filter == CouponStatusFilter.all)
          Text(isAr ? 'اضغط + لإضافة كوبون جديد' : 'Tap + to add a new coupon', style: TextStyle(fontFamily: 'Outfit', fontSize: 13, color: Colors.grey.shade500)),
      ]),
    );
  }
}
