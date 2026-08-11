import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../providers/admin_providers.dart';

class AdminOrdersScreen extends ConsumerStatefulWidget {
  const AdminOrdersScreen({super.key});
  @override
  ConsumerState<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends ConsumerState<AdminOrdersScreen> {
  String _status = 'all';
  String _search = '';
  final _searchCtrl = TextEditingController();
  final _statuses = ['all', 'pending', 'processing', 'shipped', 'delivered', 'cancelled'];

  Map<String, dynamic> get _params => {'status': _status, 'search': _search};

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(adminOrdersProvider(_params));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(isAr ? 'إدارة الطلبات' : 'Orders Management', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, fontFamily: 'Outfit', color: isDark ? AppColors.white : AppColors.onSurfaceLight)),
            const SizedBox(height: 12),
            TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: isAr ? 'البحث برقم الطلب...' : 'Search by order number...', hintStyle: const TextStyle(fontFamily: 'Outfit'),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                filled: true, fillColor: isDark ? AppColors.surfaceDark : AppColors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: _statuses.map((s) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _status = s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: _status == s ? _statusColor(s) : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _status == s ? _statusColor(s) : Colors.grey.shade400),
                    ),
                    child: Text(
                      _localizeStatus(s, isAr), 
                      style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600, fontSize: 11, color: _status == s ? Colors.white : Colors.grey.shade600)
                    ),
                  ),
                ),
              )).toList()),
            ),
          ]),
        ),
        Expanded(child: ordersAsync.when(
          data: (orders) => orders.isEmpty
              ? Center(child: Text(isAr ? 'لا توجد طلبات' : 'No orders found', style: const TextStyle(fontFamily: 'Outfit')))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: orders.length,
                  itemBuilder: (ctx, i) => _OrderTile(order: orders[i], isDark: isDark, isAr: isAr, onTap: () => context.push(AppRoutes.adminOrderDetail, extra: orders[i])),
                ),
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: AppColors.error))),
        )),
      ]),
    );
  }

  String _localizeStatus(String s, bool isAr) {
    if (!isAr) return s.toUpperCase();
    switch (s) {
      case 'all': return 'الكل';
      case 'pending': return 'قيد الانتظار';
      case 'processing': return 'جاري التجهيز';
      case 'shipped': return 'تم الشحن';
      case 'delivered': return 'تم التوصيل';
      case 'cancelled': return 'ملغي';
      default: return s;
    }
  }

  Color _statusColor(String s) => switch (s) {
    'pending' => AppColors.warning,
    'processing' => AppColors.info,
    'shipped' => AppColors.primary,
    'delivered' => AppColors.success,
    'cancelled' => AppColors.error,
    _ => Colors.blueGrey,
  };
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({required this.order, required this.isDark, required this.isAr, required this.onTap});
  final Map<String, dynamic> order;
  final bool isDark;
  final bool isAr;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = order['status']?.toString() ?? 'pending';
    final total = (order['total'] as num?)?.toStringAsFixed(2) ?? '0.00';
    final date = order['created_at'] != null ? DateTime.parse(order['created_at'].toString()).toLocal().toString().split(' ')[0] : (isAr ? 'غير معروف' : 'Unknown');
    final itemsCount = (order['order_items'] as List?)?.length ?? 0;
    
    // Status localization (using same approach as above)
    String locStatus = status.toUpperCase();
    if (isAr) {
      switch (status) {
        case 'pending': locStatus = 'قيد الانتظار'; break;
        case 'processing': locStatus = 'جاري التجهيز'; break;
        case 'shipped': locStatus = 'تم الشحن'; break;
        case 'delivered': locStatus = 'تم التوصيل'; break;
        case 'cancelled': locStatus = 'ملغي'; break;
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: isDark ? AppColors.surfaceDark : AppColors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 6, offset: const Offset(0, 2))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('${isAr ? 'طلب' : 'Order'} #${order['order_number'] ?? 'N/A'}', style: const TextStyle(fontWeight: FontWeight.w800, fontFamily: 'Outfit', fontSize: 16))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: _statusColor(status).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(locStatus, style: TextStyle(color: _statusColor(status), fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'Outfit')),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 14, color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight),
                const SizedBox(width: 4),
                Text(date, style: TextStyle(fontSize: 12, fontFamily: 'Outfit', color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight)),
                const Spacer(),
                Text('$itemsCount ${isAr ? 'عناصر' : 'Items'}', style: TextStyle(fontSize: 12, fontFamily: 'Outfit', color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight)),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Text(isAr ? 'الإجمالي' : 'Total', style: TextStyle(fontSize: 14, fontFamily: 'Outfit', color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight)),
                const Spacer(),
                Text('$total ${isAr ? 'ر.س' : 'SAR'}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, fontFamily: 'Outfit', color: AppColors.primary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String s) => switch (s) {
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

