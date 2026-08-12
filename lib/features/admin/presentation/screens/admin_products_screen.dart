import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../providers/admin_products_notifier.dart';

class AdminProductsScreen extends ConsumerStatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  ConsumerState<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends ConsumerState<AdminProductsScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      ref.read(adminProductsNotifierProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(adminProductsNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.adminProductForm),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(isAr ? 'إضافة منتج' : 'Add Product', style: const TextStyle(color: Colors.white, fontFamily: 'Outfit', fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          // Header / Bulk Actions Bar
          if (stateAsync.value?.selectedIds.isNotEmpty == true)
            Container(
              padding: const EdgeInsets.all(20),
              color: isDark ? AppColors.surfaceDark : AppColors.primaryLight,
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => ref.read(adminProductsNotifierProvider.notifier).clearSelection()),
                  Text('${stateAsync.value!.selectedIds.length} ${isAr ? 'محدد' : 'Selected'}', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, fontSize: 16, color: isDark ? AppColors.white : AppColors.onSurfaceLight)),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.check_circle_outline, color: AppColors.success), tooltip: isAr ? 'تنشيط' : 'Activate', onPressed: () => _confirmBulkAction(context, ref, true, isAr)),
                  IconButton(icon: const Icon(Icons.cancel_outlined, color: Colors.orange), tooltip: isAr ? 'تعطيل' : 'Deactivate', onPressed: () => _confirmBulkAction(context, ref, false, isAr)),
                  IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.error), tooltip: isAr ? 'حذف' : 'Delete', onPressed: () => _confirmBulkDelete(context, ref, isAr)),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(isAr ? 'إدارة المنتجات' : 'Products Management', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, fontFamily: 'Outfit', color: isDark ? AppColors.white : AppColors.onSurfaceLight))),
                      IconButton(
                        onPressed: () => _showFiltersBottomSheet(context, ref, stateAsync.value, isAr, isDark),
                        icon: const Icon(Icons.tune_rounded, color: AppColors.primary),
                        style: IconButton.styleFrom(backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                // Search
                TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => ref.read(adminProductsNotifierProvider.notifier).setSearch(v),
                  decoration: InputDecoration(
                    hintText: isAr ? 'ابحث عن منتجات...' : 'Search products...',
                    hintStyle: const TextStyle(fontFamily: 'Outfit'),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                    suffixIcon: _searchCtrl.text.isNotEmpty ? IconButton(icon: const Icon(Icons.clear_rounded), onPressed: () { _searchCtrl.clear(); ref.read(adminProductsNotifierProvider.notifier).setSearch(''); }) : null,
                    filled: true,
                    fillColor: isDark ? AppColors.surfaceDark : AppColors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(label: isAr ? 'الكل' : 'All', selected: stateAsync.value?.isActive == null, onTap: () => ref.read(adminProductsNotifierProvider.notifier).setFilter(null)),
                      const SizedBox(width: 8),
                      _FilterChip(label: isAr ? 'نشط' : 'Active', selected: stateAsync.value?.isActive == true, onTap: () => ref.read(adminProductsNotifierProvider.notifier).setFilter(true), color: AppColors.success),
                      const SizedBox(width: 8),
                      _FilterChip(label: isAr ? 'غير نشط' : 'Inactive', selected: stateAsync.value?.isActive == false, onTap: () => ref.read(adminProductsNotifierProvider.notifier).setFilter(false), color: AppColors.error),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Products list
          Expanded(
            child: stateAsync.when(
              data: (state) => state.products.isEmpty
                  ? Center(child: Text(isAr ? 'لا توجد منتجات' : 'No products found', style: const TextStyle(fontFamily: 'Outfit', fontSize: 16)))
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      itemCount: state.products.length + (state.isLoadingMore ? 1 : 0),
                      itemBuilder: (ctx, i) {
                        if (i == state.products.length) {
                          return const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator(color: AppColors.primary)));
                        }
                        final product = state.products[i];
                        return _AdminProductTile(
                          product: product,
                          isDark: isDark,
                          isAr: isAr,
                          isSelected: state.selectedIds.contains(product['id']),
                          onSelect: () => ref.read(adminProductsNotifierProvider.notifier).toggleSelection(product['id'] as String),
                          onQuickEdit: () => _showQuickEditDialog(context, ref, product, isAr),
                          onEdit: () => context.push(AppRoutes.adminProductForm, extra: product),
                          onDelete: () => _confirmDelete(context, ref, product['id'] as String, product['name_en'] as String? ?? '', isAr),
                          onToggle: (val) async {
                            try {
                              await ref.read(adminProductsNotifierProvider.notifier).toggleActive(product['id'] as String, val);
                            } catch (e) {
                              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update status', style: const TextStyle(fontFamily: 'Outfit')), backgroundColor: AppColors.error));
                            }
                          },
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (e, _) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                const SizedBox(height: 8),
                Text('$e', style: const TextStyle(color: AppColors.error)),
                TextButton(onPressed: () => ref.invalidate(adminProductsNotifierProvider), child: Text(isAr ? 'إعادة المحاولة' : 'Retry')),
              ])),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id, String name, bool isAr) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isAr ? 'حذف المنتج' : 'Delete Product', style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700)),
        content: Text(isAr ? 'هل أنت متأكد من حذف "$name"؟ لا يمكن التراجع عن هذا.' : 'Are you sure you want to delete "$name"? This action cannot be undone.', style: const TextStyle(fontFamily: 'Outfit')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isAr ? 'إلغاء' : 'Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(adminProductsNotifierProvider.notifier).deleteProduct(id);
              } catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete product', style: const TextStyle(fontFamily: 'Outfit')), backgroundColor: AppColors.error));
              }
            },
            child: Text(isAr ? 'حذف' : 'Delete', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  void _confirmBulkAction(BuildContext context, WidgetRef ref, bool isActive, bool isAr) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isAr ? 'تأكيد الإجراء' : 'Confirm Action', style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700)),
        content: Text(isAr ? 'هل أنت متأكد من ${isActive ? 'تنشيط' : 'تعطيل'} المنتجات المحددة؟' : 'Are you sure you want to ${isActive ? 'activate' : 'deactivate'} selected products?', style: const TextStyle(fontFamily: 'Outfit')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isAr ? 'إلغاء' : 'Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(adminProductsNotifierProvider.notifier).bulkToggleActive(isActive);
              } catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to bulk update', style: const TextStyle(fontFamily: 'Outfit')), backgroundColor: AppColors.error));
              }
            },
            child: Text(isAr ? 'تأكيد' : 'Confirm', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmBulkDelete(BuildContext context, WidgetRef ref, bool isAr) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isAr ? 'حذف المنتجات' : 'Delete Products', style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700)),
        content: Text(isAr ? 'هل أنت متأكد من حذف المنتجات المحددة؟ لا يمكن التراجع عن هذا.' : 'Are you sure you want to delete selected products? This action cannot be undone.', style: const TextStyle(fontFamily: 'Outfit')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isAr ? 'إلغاء' : 'Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(adminProductsNotifierProvider.notifier).bulkDelete();
              } catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to bulk delete', style: const TextStyle(fontFamily: 'Outfit')), backgroundColor: AppColors.error));
              }
            },
            child: Text(isAr ? 'حذف' : 'Delete', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showFiltersBottomSheet(BuildContext context, WidgetRef ref, AdminProductsState? state, bool isAr, bool isDark) {
    bool? localFeatured = state?.isFeatured;
    bool? localSale = state?.isOnSale;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateSheet) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isAr ? 'الفلترة المتقدمة' : 'Advanced Filters', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, fontFamily: 'Outfit')),
              const SizedBox(height: 20),
              SwitchListTile(
                title: Text(isAr ? 'منتجات مميزة فقط' : 'Featured Only', style: const TextStyle(fontFamily: 'Outfit')),
                value: localFeatured == true,
                onChanged: (v) => setStateSheet(() => localFeatured = v ? true : null),
                activeColor: AppColors.primary,
              ),
              SwitchListTile(
                title: Text(isAr ? 'منتجات مخفضة فقط' : 'On Sale Only', style: const TextStyle(fontFamily: 'Outfit')),
                value: localSale == true,
                onChanged: (v) => setStateSheet(() => localSale = v ? true : null),
                activeColor: AppColors.primary,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ref.read(adminProductsNotifierProvider.notifier).applyAdvancedFilters(
                      isFeatured: localFeatured,
                      isOnSale: localSale,
                    );
                  },
                  child: Text(isAr ? 'تطبيق الفلتر' : 'Apply Filters'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuickEditDialog(BuildContext context, WidgetRef ref, Map<String, dynamic> product, bool isAr) {
    final priceCtrl = TextEditingController(text: product['base_price']?.toString() ?? '');
    final discountCtrl = TextEditingController(text: product['discount_percent']?.toString() ?? '0');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isAr ? 'تعديل سريع: ${product['name_ar']}' : 'Quick Edit: ${product['name_en']}', style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: isAr ? 'السعر الأساسي' : 'Base Price')),
            const SizedBox(height: 12),
            TextField(controller: discountCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: isAr ? 'نسبة الخصم %' : 'Discount %')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isAr ? 'إلغاء' : 'Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final double? p = double.tryParse(priceCtrl.text);
                final double? d = double.tryParse(discountCtrl.text);
                if (p != null) {
                  final finalPrice = d != null && d > 0 ? p - (p * (d / 100)) : p;
                  final data = {'base_price': p, 'discount_percent': d ?? 0, 'final_price': finalPrice};
                  await ref.read(adminProductsNotifierProvider.notifier).updateProduct(product['id'] as String, data);
                }
              } catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error', style: const TextStyle(fontFamily: 'Outfit')), backgroundColor: AppColors.error));
              }
            },
            child: Text(isAr ? 'حفظ' : 'Save'),
          ),
        ],
      ),
    );
  }
}

class _AdminProductTile extends StatelessWidget {
  const _AdminProductTile({required this.product, required this.isDark, required this.onEdit, required this.onToggle, required this.isAr, required this.isSelected, required this.onSelect, required this.onQuickEdit, required this.onDelete});
  final Map<String, dynamic> product;
  final bool isDark;
  final bool isAr;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onQuickEdit;
  final VoidCallback onDelete;
  final void Function(bool) onToggle;

  @override
  Widget build(BuildContext context) {
    final images = product['product_images'] as List? ?? [];
    final imgUrl = images.isNotEmpty ? (images.firstWhere((i) => i['is_primary'] == true, orElse: () => images.first)['url']?.toString()) : null;
    final isActive = product['is_active'] as bool? ?? false;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onLongPress: onSelect,
      onTap: onSelect,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isSelected ? (isDark ? AppColors.primary.withValues(alpha: 0.15) : AppColors.primaryLight) : (isDark ? AppColors.surfaceDark : AppColors.white),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: isDark ? Colors.black26 : AppColors.shadowLight, blurRadius: 8, offset: const Offset(0, 3))],
          border: isSelected ? Border.all(color: AppColors.primary, width: 1.5) : Border.all(color: Colors.transparent, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Checkbox
              SizedBox(
                width: 32,
                child: Checkbox(
                  value: isSelected,
                  onChanged: (v) => onSelect(),
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
              ),
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: imgUrl != null
                    ? CachedNetworkImage(imageUrl: imgUrl, width: 65, height: 65, fit: BoxFit.cover, memCacheWidth: 150)
                    : Container(width: 65, height: 65, color: AppColors.primaryLight, child: const Icon(Icons.inventory_2_rounded, color: AppColors.primary, size: 28)),
              ),
              const SizedBox(width: 12),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text((product[isAr ? 'name_ar' : 'name_en'] as String?) ?? '', style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, fontSize: 14, height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Builder(
                          builder: (context) {
                            final double base = double.tryParse(product['base_price'].toString()) ?? 0;
                            final double discount = double.tryParse(product['discount_percent']?.toString() ?? '0') ?? 0;
                            final double finalPrice = base * (1 - (discount / 100));
                            
                            return Text(
                              '${finalPrice.toStringAsFixed(2)} ${isAr ? 'ر.س' : 'SAR'}', 
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontFamily: 'Outfit', fontSize: 13)
                            );
                          }
                        ),
                        if ((num.tryParse(product['discount_percent']?.toString() ?? '0') ?? 0) > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(6)),
                            child: Text('-${product['discount_percent']}%', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700, fontFamily: 'Outfit')),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('${isAr ? 'رقم الصنف' : 'SKU'}: ${product['sku'] ?? (isAr ? 'غير متوفر' : 'N/A')} • ${isAr ? 'المبيعات' : 'Sold'}: ${product['sold_count'] ?? 0}', style: TextStyle(fontSize: 11, fontFamily: 'Outfit', color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              // Actions
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Transform.scale(
                    scale: 0.85,
                    child: Switch(value: isActive, onChanged: onToggle, activeColor: AppColors.success, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ActionButton(icon: Icons.bolt_rounded, color: Colors.orange, onTap: onQuickEdit),
                      const SizedBox(width: 4),
                      _ActionButton(icon: Icons.edit_rounded, color: AppColors.primary, onTap: onEdit),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.color, required this.onTap});
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap, this.color = AppColors.primary});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? color : Colors.grey.shade400),
        ),
        child: Text(label, style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600, color: selected ? Colors.white : Colors.grey.shade600, fontSize: 13)),
      ),
    );
  }
}

