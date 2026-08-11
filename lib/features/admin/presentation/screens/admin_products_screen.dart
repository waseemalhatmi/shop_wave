import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../providers/admin_providers.dart';

class AdminProductsScreen extends ConsumerStatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  ConsumerState<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends ConsumerState<AdminProductsScreen> {
  String _search = '';
  bool? _isActive;
  final _searchCtrl = TextEditingController();

  Map<String, dynamic> get _params => {
    'search': _search,
    'isActive': _isActive,
  };

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(adminProductsProvider(_params));
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
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isAr ? 'إدارة المنتجات' : 'Products Management', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, fontFamily: 'Outfit', color: isDark ? AppColors.white : AppColors.onSurfaceLight)),
                const SizedBox(height: 16),
                // Search
                TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _search = v),
                  decoration: InputDecoration(
                    hintText: isAr ? 'ابحث عن منتجات...' : 'Search products...',
                    hintStyle: const TextStyle(fontFamily: 'Outfit'),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                    suffixIcon: _search.isNotEmpty ? IconButton(icon: const Icon(Icons.clear_rounded), onPressed: () { _searchCtrl.clear(); setState(() => _search = ''); }) : null,
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
                      _FilterChip(label: isAr ? 'الكل' : 'All', selected: _isActive == null, onTap: () => setState(() => _isActive = null)),
                      const SizedBox(width: 8),
                      _FilterChip(label: isAr ? 'نشط' : 'Active', selected: _isActive == true, onTap: () => setState(() => _isActive = true), color: AppColors.success),
                      const SizedBox(width: 8),
                      _FilterChip(label: isAr ? 'غير نشط' : 'Inactive', selected: _isActive == false, onTap: () => setState(() => _isActive = false), color: AppColors.error),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Products list
          Expanded(
            child: productsAsync.when(
              data: (products) => products.isEmpty
                  ? Center(child: Text(isAr ? 'لا توجد منتجات' : 'No products found', style: const TextStyle(fontFamily: 'Outfit', fontSize: 16)))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      itemCount: products.length,
                      itemBuilder: (ctx, i) => _AdminProductTile(
                        product: products[i],
                        isDark: isDark,
                        isAr: isAr,
                        onEdit: () => context.push(AppRoutes.adminProductForm, extra: products[i]),
                        onDelete: () => _confirmDelete(context, ref, products[i]['id'] as String, products[i]['name_en'] as String? ?? '', isAr),
                        onToggle: (val) async {
                          await ref.read(adminDataSourceProvider).toggleProductActive(products[i]['id'] as String, val);
                          ref.invalidate(adminProductsProvider(_params));
                        },
                      ),
                    ),
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (e, _) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                const SizedBox(height: 8),
                Text('$e', style: const TextStyle(color: AppColors.error)),
                TextButton(onPressed: () => ref.invalidate(adminProductsProvider(_params)), child: Text(isAr ? 'إعادة المحاولة' : 'Retry')),
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
              await ref.read(adminDataSourceProvider).softDeleteProduct(id);
              ref.invalidate(adminProductsProvider(_params));
            },
            child: Text(isAr ? 'حذف' : 'Delete', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _AdminProductTile extends StatelessWidget {
  const _AdminProductTile({required this.product, required this.isDark, required this.onEdit, required this.onDelete, required this.onToggle, required this.isAr});
  final Map<String, dynamic> product;
  final bool isDark;
  final bool isAr;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final void Function(bool) onToggle;

  @override
  Widget build(BuildContext context) {
    final images = product['product_images'] as List? ?? [];
    final imgUrl = images.isNotEmpty ? (images.firstWhere((i) => i['is_primary'] == true, orElse: () => images.first)['url']?.toString()) : null;
    final isActive = product['is_active'] as bool? ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), bottomLeft: Radius.circular(14)),
            child: imgUrl != null
                ? CachedNetworkImage(imageUrl: imgUrl, width: 80, height: 80, fit: BoxFit.cover)
                : Container(width: 80, height: 80, color: AppColors.primaryLight, child: const Icon(Icons.inventory_2_rounded, color: AppColors.primary, size: 32)),
          ),
          // Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product[isAr ? 'name_ar' : 'name_en'] ?? '', style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(product[isAr ? 'name_en' : 'name_ar'] ?? '', style: TextStyle(fontFamily: 'Outfit', fontSize: 11, color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('${product['base_price'] ?? 0} ${isAr ? 'ر.س' : 'SAR'}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontFamily: 'Outfit', fontSize: 13)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.successLight : AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(isActive ? (isAr ? 'نشط' : 'Active') : (isAr ? 'غير نشط' : 'Inactive'), style: TextStyle(color: isActive ? AppColors.success : AppColors.error, fontSize: 10, fontWeight: FontWeight.w700, fontFamily: 'Outfit')),
                      ),
                    ],
                  ),
                  Text('${isAr ? 'رقم الصنف' : 'SKU'}: ${product['sku'] ?? (isAr ? 'غير متوفر' : 'N/A')} | ${isAr ? 'المبيعات' : 'Sold'}: ${product['sold_count'] ?? 0}', style: TextStyle(fontSize: 10, fontFamily: 'Outfit', color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight)),
                ],
              ),
            ),
          ),
          // Actions
          Column(
            children: [
              Switch(value: isActive, onChanged: onToggle, activeColor: AppColors.success, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
              IconButton(icon: const Icon(Icons.edit_rounded, size: 18), color: AppColors.primary, onPressed: onEdit, tooltip: isAr ? 'تعديل' : 'Edit', constraints: const BoxConstraints()),
              IconButton(icon: const Icon(Icons.delete_rounded, size: 18), color: AppColors.error, onPressed: onDelete, tooltip: isAr ? 'حذف' : 'Delete', constraints: const BoxConstraints()),
              const SizedBox(height: 4),
            ],
          ),
          const SizedBox(width: 8),
        ],
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

