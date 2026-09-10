import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../cart/presentation/providers/cart_notifier.dart';
import '../../domain/entities/order_entity.dart';
import '../providers/orders_providers.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredOrdersAsync = ref.watch(filteredUserOrdersProvider);
    final currentFilter = ref.watch(orderStatusFilterProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          isAr ? 'طلباتي' : 'My Orders',
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _FilterTabs(
            selected: currentFilter,
            isAr: isAr,
            onSelect: (filter) {
              ref.read(orderStatusFilterProvider.notifier).setFilter(filter);
            },
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(userOrdersProvider.notifier).refreshOrders(),
        child: filteredOrdersAsync.when(
          data: (orders) {
            if (orders.isEmpty) {
              return _buildEmptyState(context, ref, currentFilter, isAr);
            }
            return ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return _OrderCard(order: order, isAr: isAr);
              },
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => _buildErrorState(context, ref, error, isAr),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    WidgetRef ref,
    OrderStatusFilter currentFilter,
    bool isAr,
  ) {
    final theme = Theme.of(context);
    final isFiltered = currentFilter != OrderStatusFilter.all;

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isFiltered
                    ? Icons.filter_alt_off_rounded
                    : Icons.shopping_bag_outlined,
                size: 76,
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                isFiltered
                    ? (isAr
                        ? 'لا توجد طلبات في هذا القسم'
                        : 'No orders in this section')
                    : (isAr ? 'لا توجد طلبات حتى الآن' : 'No Orders Yet'),
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                isFiltered
                    ? (isAr
                        ? 'جرّب التبديل لعرض كل الطلبات لمشاهدة سجل مشترياتك الكامل.'
                        : 'Switch to "All" to view your entire purchase history.')
                    : (isAr
                        ? 'لم تقم بإنشاء أي طلب بعد. تصفح آلاف المنتجات المميزة الآن!'
                        : 'You haven\'t placed any orders yet. Start shopping now!'),
                style: TextStyle(
                  fontFamily: 'Outfit',
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: () {
                  if (isFiltered) {
                    ref
                        .read(orderStatusFilterProvider.notifier)
                        .setFilter(OrderStatusFilter.all);
                  } else {
                    context.go(AppRoutes.home);
                  }
                },
                child: Text(
                  isFiltered
                      ? (isAr ? 'عرض كل الطلبات' : 'View All Orders')
                      : (isAr ? 'تسوق الآن' : 'Shop Now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    WidgetRef ref,
    Object error,
    bool isAr,
  ) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 70,
                color: AppColors.error,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                isAr ? 'فشل تحميل الطلبات' : 'Failed to Load Orders',
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                error.toString().replaceAll('Exception: ', ''),
                style: TextStyle(
                  fontFamily: 'Outfit',
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: () =>
                    ref.read(userOrdersProvider.notifier).refreshOrders(),
                child: Text(isAr ? 'إعادة المحاولة' : 'Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Filter Tabs Bar ──────────────────────────────────────────────────────────

class _FilterTabs extends StatelessWidget {
  const _FilterTabs({
    required this.selected,
    required this.isAr,
    required this.onSelect,
  });

  final OrderStatusFilter selected;
  final bool isAr;
  final ValueChanged<OrderStatusFilter> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: 6,
      ),
      child: Row(
        children: OrderStatusFilter.values.map((filter) {
          final isSelected = filter == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter.label(isAr)),
              selected: isSelected,
              onSelected: (_) => onSelect(filter),
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : null,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Order Card with Live Actions ─────────────────────────────────────────────

class _OrderCard extends ConsumerWidget {
  const _OrderCard({required this.order, required this.isAr});
  final OrderEntity order;
  final bool isAr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sar = context.l10n.general_sar;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => context.push(AppRoutes.orderDetailPath(order.id)),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Order ID & Status Chip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.receipt_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        order.orderNumber,
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  _StatusChip(status: order.status),
                ],
              ),
              const SizedBox(height: 8),

              // Date & Item summary
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 13,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(order.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    isAr
                        ? '${order.totalItemCount} قطعة'
                        : '${order.totalItemCount} items',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const Divider(height: AppSpacing.lg),

              // Total Price & Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAr ? 'الإجمالي' : 'Total',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        '${order.total.toStringAsFixed(2)} $sar',
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  // Actions row
                  Row(
                    children: [
                      // 1-Tap Re-order Button
                      OutlinedButton.icon(
                        onPressed: () {
                          ref
                              .read(cartNotifierProvider.notifier)
                              .reorderItems(order.items);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isAr
                                    ? 'تمت إضافة منتجات الطلب إلى السلة!'
                                    : 'Items added to cart!',
                                style: const TextStyle(fontFamily: 'Outfit'),
                              ),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                              action: SnackBarAction(
                                label: isAr ? 'عرض السلة' : 'View Cart',
                                textColor: Colors.white,
                                onPressed: () => context.push(AppRoutes.cart),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.replay_rounded, size: 14),
                        label: Text(
                          isAr ? 'إعادة الطلب' : 'Re-order',
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          minimumSize: Size.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Track button
                      ElevatedButton(
                        onPressed: () => context.push(
                          AppRoutes.orderDetailPath(order.id),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          minimumSize: Size.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          isAr ? 'تتبع' : 'Track',
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

// ─── Status Chip ──────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, text, label) = _getColors();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          fontFamily: 'Outfit',
        ),
      ),
    );
  }

  (Color, Color, String) _getColors() {
    switch (status) {
      case OrderStatus.pending:
        return (
          Colors.orange.withValues(alpha: 0.15),
          Colors.orange.shade800,
          'Pending'
        );
      case OrderStatus.processing:
        return (
          Colors.blue.withValues(alpha: 0.15),
          Colors.blue.shade800,
          'Processing'
        );
      case OrderStatus.shipped:
        return (
          Colors.purple.withValues(alpha: 0.15),
          Colors.purple.shade800,
          'Shipped'
        );
      case OrderStatus.delivered:
        return (
          Colors.green.withValues(alpha: 0.15),
          Colors.green.shade800,
          'Delivered'
        );
      case OrderStatus.cancelled:
        return (
          Colors.red.withValues(alpha: 0.15),
          Colors.red.shade800,
          'Cancelled'
        );
    }
  }
}
