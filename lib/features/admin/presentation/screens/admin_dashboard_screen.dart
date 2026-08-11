import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../providers/admin_providers.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminDashboardStatsProvider);
    final recentOrdersAsync = ref.watch(adminRecentOrdersProvider);
    final topProductsAsync = ref.watch(adminTopProductsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(adminDashboardStatsProvider);
          ref.invalidate(adminRecentOrdersProvider);
          ref.invalidate(adminTopProductsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(isAr ? 'لوحة التحكم' : 'Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, fontFamily: 'Outfit', color: isDark ? AppColors.white : AppColors.onSurfaceLight)),
                Text(isAr ? 'مرحباً بعودتك أيها المدير!' : 'Welcome back, Admin!', style: TextStyle(color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight, fontFamily: 'Outfit')),
              ]),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]), borderRadius: BorderRadius.circular(20)),
                child: Row(children: [
                  const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(isAr ? 'مدير' : 'ADMIN', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12, fontFamily: 'Outfit', letterSpacing: 1)),
                ]),
              ),
            ]),
            const SizedBox(height: 24),
            statsAsync.when(
              data: (stats) => _buildStatsGrid(context, stats, isDark, isAr),
              loading: () => GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.2,
                children: List.generate(8, (i) => Container(decoration: BoxDecoration(color: AppColors.skeletonBase, borderRadius: BorderRadius.circular(16))))),
              error: (e, _) => Center(child: TextButton(onPressed: () => ref.invalidate(adminDashboardStatsProvider), child: Text(isAr ? 'إعادة تحميل الإحصائيات' : 'Retry loading stats'))),
            ),
            const SizedBox(height: 24),
            _sectionHeader(isAr ? 'أحدث الطلبات' : 'Recent Orders', () => context.go(AppRoutes.adminOrders), isDark, isAr),
            const SizedBox(height: 12),
            recentOrdersAsync.when(
              data: (orders) => _buildRecentOrdersList(orders, isDark, isAr),
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (e, _) => TextButton(onPressed: () => ref.invalidate(adminRecentOrdersProvider), child: Text(isAr ? 'إعادة المحاولة' : 'Retry')),
            ),
            const SizedBox(height: 24),
            _sectionHeader(isAr ? 'المنتجات الأكثر مبيعاً' : 'Top Selling Products', () => context.go(AppRoutes.adminProducts), isDark, isAr),
            const SizedBox(height: 12),
            topProductsAsync.when(
              data: (products) => _buildTopProductsList(products, isDark, isAr),
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (e, _) => TextButton(onPressed: () => ref.invalidate(adminTopProductsProvider), child: Text(isAr ? 'إعادة المحاولة' : 'Retry')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, Map<String, dynamic> stats, bool isDark, bool isAr) {
    return GridView.count(
      crossAxisCount: MediaQuery.sizeOf(context).width > 600 ? 4 : 2,
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.2,
      children: [
        _StatCard(label: isAr ? 'إجمالي الأرباح' : 'Total Revenue', value: '${(stats['total_revenue'] as num?)?.toStringAsFixed(0) ?? '0'} ${isAr ? 'ر.س' : 'SAR'}', icon: Icons.attach_money_rounded, color: AppColors.success, isDark: isDark),
        _StatCard(label: isAr ? 'إجمالي الطلبات' : 'Total Orders', value: '${stats['total_orders'] ?? 0}', icon: Icons.receipt_long_rounded, color: AppColors.primary, isDark: isDark),
        _StatCard(label: isAr ? 'طلبات قيد الانتظار' : 'Pending Orders', value: '${stats['pending_orders'] ?? 0}', icon: Icons.pending_actions_rounded, color: AppColors.warning, isDark: isDark),
        _StatCard(label: isAr ? 'المنتجات النشطة' : 'Active Products', value: '${stats['total_active_products'] ?? 0}', icon: Icons.inventory_2_rounded, color: AppColors.info, isDark: isDark),
        _StatCard(label: isAr ? 'أرباح اليوم' : "Today's Revenue", value: '${(stats['revenue_today'] as num?)?.toStringAsFixed(0) ?? '0'} ${isAr ? 'ر.س' : 'SAR'}', icon: Icons.today_rounded, color: AppColors.secondary, isDark: isDark),
        _StatCard(label: isAr ? 'طلبات اليوم' : "Today's Orders", value: '${stats['orders_today'] ?? 0}', icon: Icons.shopping_bag_rounded, color: const Color(0xFF8B5CF6), isDark: isDark),
        _StatCard(label: isAr ? 'أرباح 7 أيام' : '7-Day Revenue', value: '${(stats['revenue_7_days'] as num?)?.toStringAsFixed(0) ?? '0'} ${isAr ? 'ر.س' : 'SAR'}', icon: Icons.bar_chart_rounded, color: const Color(0xFFEC4899), isDark: isDark),
        _StatCard(label: isAr ? 'إجمالي المستخدمين' : 'Total Users', value: '${stats['total_users'] ?? 0}', icon: Icons.people_rounded, color: const Color(0xFF14B8A6), isDark: isDark),
      ],
    );
  }

  Widget _sectionHeader(String title, VoidCallback onViewAll, bool isDark, bool isAr) {
    return Row(children: [
      Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, fontFamily: 'Outfit', color: isDark ? AppColors.white : AppColors.onSurfaceLight)),
      const Spacer(),
      TextButton(onPressed: onViewAll, child: Text(isAr ? 'عرض الكل' : 'View All', style: const TextStyle(color: AppColors.primary, fontFamily: 'Outfit', fontWeight: FontWeight.w600))),
    ]);
  }

  Widget _buildRecentOrdersList(List<Map<String, dynamic>> orders, bool isDark, bool isAr) {
    if (orders.isEmpty) return Center(child: Text(isAr ? 'لا يوجد طلبات بعد' : 'No orders yet'));
    return Column(children: orders.map((o) {
      final status = o['status']?.toString() ?? 'pending';
      final orderNum = o['order_number']?.toString() ?? 'N/A';
      final total = (o['total'] as num?)?.toStringAsFixed(2) ?? '0.00';
      final statusColor = _statusColor(status);
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: isDark ? AppColors.surfaceDark : AppColors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 4)]),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.receipt_long_rounded, color: statusColor, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(orderNum, style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, fontSize: 14)),
            Text(_formatDate(o['created_at']), style: TextStyle(color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight, fontSize: 12, fontFamily: 'Outfit')),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('$total SAR', style: const TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Outfit', color: AppColors.primary)),
            Container(margin: const EdgeInsets.only(top: 4), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w700, fontFamily: 'Outfit'))),
          ]),
        ]),
      );
    }).toList());
  }

  Widget _buildTopProductsList(List<Map<String, dynamic>> products, bool isDark, bool isAr) {
    if (products.isEmpty) return Center(child: Text(isAr ? 'لا يوجد منتجات بعد' : 'No products yet'));
    return Column(children: products.asMap().entries.map((entry) {
      final i = entry.key;
      final p = entry.value;
      final images = p['product_images'] as List? ?? [];
      final imgUrl = images.isNotEmpty ? images.first['url']?.toString() : null;
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: isDark ? AppColors.surfaceDark : AppColors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 4)]),
        child: Row(children: [
          Container(width: 32, height: 32, decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]), borderRadius: BorderRadius.circular(8)),
            child: Center(child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontFamily: 'Outfit')))),
          const SizedBox(width: 12),
          if (imgUrl != null)
            ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(imgUrl, width: 40, height: 40, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image)))
          else
            Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.inventory_2_rounded, color: AppColors.primary)),
          const SizedBox(width: 12),
          Expanded(child: Text(p[isAr ? 'name_ar' : 'name_en']?.toString() ?? (isAr ? 'منتج' : 'Product'), style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600, fontSize: 13), overflow: TextOverflow.ellipsis)),
          Text('${p['sold_count'] ?? 0} ${isAr ? 'مبيعاً' : 'sold'}', style: const TextStyle(color: AppColors.primary, fontFamily: 'Outfit', fontWeight: FontWeight.w700)),
        ]),
      );
    }).toList());
  }

  Color _statusColor(String status) => switch (status) {
    'pending' => AppColors.warning,
    'processing' => AppColors.info,
    'shipped' => AppColors.primary,
    'delivered' => AppColors.success,
    'cancelled' => AppColors.error,
    _ => Colors.grey,
  };

  String _formatDate(dynamic raw) {
    if (raw == null) return '';
    final dt = DateTime.tryParse(raw.toString());
    if (dt == null) return '';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon, required this.color, required this.isDark});
  final String label, value;
  final IconData icon;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: isDark ? AppColors.surfaceDark : AppColors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20)),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, fontFamily: 'Outfit', color: isDark ? AppColors.white : AppColors.onSurfaceLight), overflow: TextOverflow.ellipsis),
          Text(label, style: TextStyle(fontSize: 10, fontFamily: 'Outfit', color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight)),
        ]),
      ]),
    );
  }
}
