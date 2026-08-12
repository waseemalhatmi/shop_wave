import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../providers/admin_orders_notifier.dart';

// ── Constants ────────────────────────────────────────────────────────────────

const _kStatuses = ['all', 'pending', 'processing', 'shipped', 'delivered', 'cancelled'];

// ── Screen ───────────────────────────────────────────────────────────────────

class AdminOrdersScreen extends ConsumerStatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  ConsumerState<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends ConsumerState<AdminOrdersScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 250) {
      ref.read(adminOrdersNotifierProvider.notifier).loadMore();
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
    final stateAsync = ref.watch(adminOrdersNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        isAr ? 'إدارة الطلبات' : 'Orders Management',
                        style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w800,
                          fontFamily: 'Outfit',
                          color: isDark ? AppColors.white : AppColors.onSurfaceLight,
                        ),
                      ),
                    ),
                    // Date Filter Button
                    _DateFilterButton(
                      currentFilter: stateAsync.value?.dateFilter ?? OrderDateFilter.all,
                      isDark: isDark,
                      isAr: isAr,
                      onSelected: (f) => ref.read(adminOrdersNotifierProvider.notifier).setDateFilter(f),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Summary Stats Row (shown when data loaded)
                if (stateAsync.value != null) ...[
                  _OrderSummaryRow(orders: stateAsync.value!.orders, isAr: isAr, isDark: isDark),
                  const SizedBox(height: 12),
                ],

                // Search Field
                TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => ref.read(adminOrdersNotifierProvider.notifier).setSearch(v),
                  decoration: InputDecoration(
                    hintText: isAr ? 'البحث برقم الطلب...' : 'Search by order number...',
                    hintStyle: const TextStyle(fontFamily: 'Outfit'),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchCtrl.clear();
                              ref.read(adminOrdersNotifierProvider.notifier).setSearch('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: isDark ? AppColors.surfaceDark : AppColors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 10),

                // Status Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _kStatuses.map((s) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _StatusChip(
                        status: s,
                        isSelected: stateAsync.value?.status == s,
                        isAr: isAr,
                        onTap: () => ref.read(adminOrdersNotifierProvider.notifier).setStatus(s),
                      ),
                    )).toList(),
                  ),
                ),
              ],
            ),
          ),

          // ── Orders List ─────────────────────────────────────────────────
          Expanded(
            child: stateAsync.when(
              data: (st) => st.orders.isEmpty
                  ? _EmptyState(isAr: isAr)
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      itemCount: st.orders.length + (st.isLoadingMore ? 1 : 0),
                      itemBuilder: (ctx, i) {
                        if (i == st.orders.length) {
                          return const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                          );
                        }
                        final order = st.orders[i];
                        return _OrderCard(
                          order: order,
                          isDark: isDark,
                          isAr: isAr,
                          onTap: () => context.push(AppRoutes.adminOrderDetail, extra: order),
                          onStatusChange: (newStatus) async {
                            try {
                              await ref.read(adminOrdersNotifierProvider.notifier)
                                  .updateOrderStatus(order['id'] as String, newStatus);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                    isAr ? 'تم تحديث حالة الطلب' : 'Order status updated',
                                    style: const TextStyle(fontFamily: 'Outfit'),
                                  ),
                                  backgroundColor: AppColors.success,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ));
                              }
                            } catch (_) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                    isAr ? 'فشل تحديث الحالة' : 'Failed to update status',
                                    style: const TextStyle(fontFamily: 'Outfit'),
                                  ),
                                  backgroundColor: AppColors.error,
                                  behavior: SnackBarBehavior.floating,
                                ));
                              }
                            }
                          },
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (e, _) => _ErrorState(
                isAr: isAr,
                error: '$e',
                onRetry: () => ref.invalidate(adminOrdersNotifierProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Summary Row ──────────────────────────────────────────────────────────────

class _OrderSummaryRow extends StatelessWidget {
  const _OrderSummaryRow({required this.orders, required this.isAr, required this.isDark});
  final List<Map<String, dynamic>> orders;
  final bool isAr;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    int pending = 0, processing = 0, delivered = 0;
    double totalRevenue = 0;
    for (final o in orders) {
      final s = o['status'] as String? ?? '';
      if (s == 'pending') pending++;
      if (s == 'processing') processing++;
      if (s == 'delivered') delivered++;
      totalRevenue += (o['total'] as num?)?.toDouble() ?? 0;
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _StatMini(label: isAr ? 'انتظار' : 'Pending', value: '$pending', color: AppColors.warning),
        _StatMini(label: isAr ? 'تجهيز' : 'Processing', value: '$processing', color: AppColors.info),
        _StatMini(label: isAr ? 'موصّل' : 'Delivered', value: '$delivered', color: AppColors.success),
      ],
    );
  }
}

class _StatMini extends StatelessWidget {
  const _StatMini({required this.label, required this.value, required this.color});
  final String label, value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text('$value $label', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, fontSize: 11, color: color)),
      ]),
    );
  }
}

// ── Date Filter Button ───────────────────────────────────────────────────────

class _DateFilterButton extends StatelessWidget {
  const _DateFilterButton({required this.currentFilter, required this.isDark, required this.isAr, required this.onSelected});
  final OrderDateFilter currentFilter;
  final bool isDark, isAr;
  final void Function(OrderDateFilter) onSelected;

  String _label(OrderDateFilter f) {
    if (!isAr) {
      return switch (f) {
        OrderDateFilter.all => 'All Time',
        OrderDateFilter.today => 'Today',
        OrderDateFilter.yesterday => 'Yesterday',
        OrderDateFilter.last7Days => 'Last 7 Days',
        OrderDateFilter.last30Days => 'Last 30 Days',
      };
    }
    return switch (f) {
      OrderDateFilter.all => 'كل الوقت',
      OrderDateFilter.today => 'اليوم',
      OrderDateFilter.yesterday => 'أمس',
      OrderDateFilter.last7Days => 'آخر 7 أيام',
      OrderDateFilter.last30Days => 'آخر 30 يوم',
    };
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<OrderDateFilter>(
      initialValue: currentFilter,
      onSelected: onSelected,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (_) => OrderDateFilter.values.map((f) => PopupMenuItem(
        value: f,
        child: Row(children: [
          if (currentFilter == f) ...[const Icon(Icons.check, size: 16, color: AppColors.primary), const SizedBox(width: 8)],
          Text(_label(f), style: const TextStyle(fontFamily: 'Outfit')),
        ]),
      )).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: currentFilter != OrderDateFilter.all
              ? Border.all(color: AppColors.primary, width: 1.5)
              : null,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.calendar_month_rounded,
              size: 16,
              color: currentFilter != OrderDateFilter.all ? AppColors.primary : AppColors.onSurfaceVariantLight),
          const SizedBox(width: 4),
          Text(
            _label(currentFilter),
            style: TextStyle(
              fontFamily: 'Outfit', fontWeight: FontWeight.w600, fontSize: 12,
              color: currentFilter != OrderDateFilter.all ? AppColors.primary : AppColors.onSurfaceVariantLight,
            ),
          ),
          const SizedBox(width: 2),
          Icon(Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: currentFilter != OrderDateFilter.all ? AppColors.primary : AppColors.onSurfaceVariantLight),
        ]),
      ),
    );
  }
}

// ── Status Chip ──────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.isSelected, required this.isAr, required this.onTap});
  final String status;
  final bool isSelected, isAr;
  final VoidCallback onTap;

  Color get _color => switch (status) {
    'pending' => AppColors.warning,
    'processing' => AppColors.info,
    'shipped' => AppColors.primary,
    'delivered' => AppColors.success,
    'cancelled' => AppColors.error,
    _ => AppColors.primary,
  };

  String _label() {
    if (!isAr) return status == 'all' ? 'ALL' : status.toUpperCase();
    return switch (status) {
      'all' => 'الكل',
      'pending' => 'انتظار',
      'processing' => 'تجهيز',
      'shipped' => 'شحن',
      'delivered' => 'توصيل',
      'cancelled' => 'ملغي',
      _ => status,
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? _color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? _color : Colors.grey.shade400),
        ),
        child: Text(
          _label(),
          style: TextStyle(
            fontFamily: 'Outfit', fontWeight: FontWeight.w600, fontSize: 11,
            color: isSelected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}

// ── Order Card ───────────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order, required this.isDark, required this.isAr,
    required this.onTap, required this.onStatusChange,
  });
  final Map<String, dynamic> order;
  final bool isDark, isAr;
  final VoidCallback onTap;
  final void Function(String newStatus) onStatusChange;

  static const _nextStatus = {
    'pending': 'processing',
    'processing': 'shipped',
    'shipped': 'delivered',
  };

  Color _statusColor(String s) => switch (s) {
    'pending' => AppColors.warning,
    'processing' => AppColors.info,
    'shipped' => AppColors.primary,
    'delivered' => AppColors.success,
    'cancelled' => AppColors.error,
    _ => Colors.grey,
  };

  IconData _statusIcon(String s) => switch (s) {
    'pending' => Icons.hourglass_top_rounded,
    'processing' => Icons.settings_rounded,
    'shipped' => Icons.local_shipping_rounded,
    'delivered' => Icons.check_circle_rounded,
    'cancelled' => Icons.cancel_rounded,
    _ => Icons.receipt_rounded,
  };

  String _localizeStatus(String s) {
    if (!isAr) return s.toUpperCase();
    return switch (s) {
      'pending' => 'قيد الانتظار',
      'processing' => 'جاري التجهيز',
      'shipped' => 'تم الشحن',
      'delivered' => 'تم التوصيل',
      'cancelled' => 'ملغي',
      _ => s,
    };
  }

  String _localizeNextAction(String? next) {
    if (next == null) return '';
    if (!isAr) return 'Mark as ${next.toUpperCase()}';
    return switch (next) {
      'processing' => 'نقل لـ: جاري التجهيز',
      'shipped' => 'نقل لـ: تم الشحن',
      'delivered' => 'نقل لـ: تم التوصيل',
      _ => next,
    };
  }

  @override
  Widget build(BuildContext context) {
    final status = order['status']?.toString() ?? 'pending';
    final total = (order['total'] as num?)?.toStringAsFixed(2) ?? '0.00';
    final orderNumber = order['order_number']?.toString() ?? 'N/A';
    final itemsCount = (order['order_items'] as List?)?.length ?? 0;
    final customerData = order['profiles'] as Map<String, dynamic>?;
    final customerName = customerData?['full_name'] as String? ?? (isAr ? 'عميل' : 'Customer');
    final statusColor = _statusColor(status);
    final next = _nextStatus[status];

    // Parse date
    String formattedDate = '';
    if (order['created_at'] != null) {
      final dt = DateTime.tryParse(order['created_at'].toString())?.toLocal();
      if (dt != null) {
        final diff = DateTime.now().difference(dt);
        if (diff.inDays == 0) {
          final h = dt.hour.toString().padLeft(2, '0');
          final m = dt.minute.toString().padLeft(2, '0');
          formattedDate = isAr ? 'اليوم $h:$m' : 'Today $h:$m';
        } else if (diff.inDays == 1) {
          formattedDate = isAr ? 'أمس' : 'Yesterday';
        } else {
          formattedDate = '${dt.day}/${dt.month}/${dt.year}';
        }
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Bar: Status Color Strip ──────────────────────────────
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),

            // ── Card Body ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Order number + Status Badge
                  Row(children: [
                    Icon(_statusIcon(status), size: 18, color: statusColor),
                    const SizedBox(width: 8),
                    Text(
                      '#$orderNumber',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontFamily: 'Outfit', fontSize: 16),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        _localizeStatus(status),
                        style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'Outfit'),
                      ),
                    ),
                  ]),

                  const SizedBox(height: 12),

                  // Row 2: Customer name + Date
                  Row(children: [
                    const Icon(Icons.person_rounded, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        customerName,
                        style: TextStyle(
                          fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.white : AppColors.onSurfaceLight,
                        ),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.access_time_rounded, size: 14, color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight),
                    const SizedBox(width: 4),
                    Text(
                      formattedDate,
                      style: TextStyle(fontSize: 12, fontFamily: 'Outfit', color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight),
                    ),
                  ]),

                  const SizedBox(height: 12),
                  Divider(height: 1, color: isDark ? Colors.white12 : Colors.black12),
                  const SizedBox(height: 12),

                  // Row 3: Items count + Total + Action
                  Row(children: [
                    Text(
                      '$itemsCount ${isAr ? 'منتج' : 'item${itemsCount != 1 ? 's' : ''}'}',
                      style: TextStyle(
                        fontFamily: 'Outfit', fontSize: 13,
                        color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$total ${isAr ? 'ر.س' : 'SAR'}',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, fontFamily: 'Outfit', color: AppColors.primary),
                    ),
                  ]),

                  // Row 4: Quick status advance button (only if not final state)
                  if (next != null) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => onStatusChange(next),
                        icon: Icon(_statusIcon(next), size: 15, color: _statusColor(next)),
                        label: Text(
                          _localizeNextAction(next),
                          style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, fontSize: 12, color: _statusColor(next)),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: _statusColor(next).withValues(alpha: 0.5)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          backgroundColor: _statusColor(next).withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                  ],

                  // Cancel option (for pending only)
                  if (status == 'pending') ...[
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => _confirmCancel(context, isAr),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          foregroundColor: AppColors.error,
                        ),
                        child: Text(
                          isAr ? 'إلغاء الطلب' : 'Cancel Order',
                          style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context, bool isAr) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isAr ? 'إلغاء الطلب' : 'Cancel Order', style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700)),
        content: Text(isAr ? 'هل أنت متأكد من إلغاء هذا الطلب؟' : 'Are you sure you want to cancel this order?', style: const TextStyle(fontFamily: 'Outfit')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isAr ? 'تراجع' : 'Back')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              onStatusChange('cancelled');
            },
            child: Text(isAr ? 'إلغاء الطلب' : 'Cancel Order', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Empty & Error States ─────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isAr});
  final bool isAr;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.receipt_long_rounded, size: 72, color: Colors.grey.shade400),
        const SizedBox(height: 16),
        Text(
          isAr ? 'لا توجد طلبات' : 'No orders found',
          style: TextStyle(fontFamily: 'Outfit', fontSize: 18, fontWeight: FontWeight.w700, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 8),
        Text(
          isAr ? 'جرّب تغيير الفلاتر أو نطاق التاريخ' : 'Try adjusting your filters or date range',
          style: TextStyle(fontFamily: 'Outfit', fontSize: 13, color: Colors.grey.shade500),
          textAlign: TextAlign.center,
        ),
      ]),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.isAr, required this.error, required this.onRetry});
  final bool isAr;
  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.cloud_off_rounded, color: AppColors.error, size: 64),
        const SizedBox(height: 16),
        Text(
          isAr ? 'حدث خطأ في تحميل الطلبات' : 'Failed to load orders',
          style: const TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.error),
        ),
        const SizedBox(height: 8),
        Text(error, style: const TextStyle(fontSize: 12, fontFamily: 'Outfit', color: AppColors.error), textAlign: TextAlign.center),
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
