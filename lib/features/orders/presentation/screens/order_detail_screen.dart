import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../cart/presentation/providers/cart_notifier.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_item_entity.dart';
import '../providers/orders_providers.dart';

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({
    required this.orderId,
    super.key,
  });

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch live stream first; fallback to future provider
    final streamAsync = ref.watch(orderDetailsStreamProvider(orderId));
    final futureAsync = ref.watch(orderDetailsProvider(orderId));
    final orderDetailsAsync =
        streamAsync.hasValue ? streamAsync : futureAsync;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          isAr ? 'تفاصيل الطلب' : 'Order Details',
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.transparent,
        elevation: 0,
        actions: [
          // Live indicator pill
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 12,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  isAr ? 'مباشر' : 'LIVE',
                  style: const TextStyle(
                    color: AppColors.success,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: orderDetailsAsync.when(
        data: (order) => _buildBody(context, ref, order),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 60,
                  color: AppColors.error,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  isAr
                      ? 'تعذر تحميل تفاصيل الطلب'
                      : 'Failed to load order details',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(orderDetailsProvider(orderId));
                    ref.invalidate(orderDetailsStreamProvider(orderId));
                  },
                  child: Text(isAr ? 'إعادة المحاولة' : 'Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: orderDetailsAsync.maybeWhen(
        data: (order) => _buildBottomBar(context, ref, order),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, OrderEntity order) {
    final isRtl = Localizations.localeOf(context).languageCode == 'ar';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card with order number, status, date
          _buildHeaderCard(context, order),
          const SizedBox(height: AppSpacing.lg),

          // Order Timeline (Status tracker)
          _buildTimeline(context, order),
          const SizedBox(height: AppSpacing.lg),

          // Product list
          Text(
            isRtl ? 'منتجات الطلب' : 'Order Items',
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.items.length,
            itemBuilder: (context, index) {
              final item = order.items[index];
              return _OrderItemRow(item: item, isRtl: isRtl);
            },
          ),
          const SizedBox(height: AppSpacing.lg),

          // Shipping details
          Text(
            isRtl ? 'بيانات الشحن والتوصيل' : 'Shipping Information',
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildShippingCard(context, order.shippingAddress),
          const SizedBox(height: AppSpacing.lg),

          // Financial summary
          Text(
            isRtl ? 'ملخص الدفع' : 'Payment Summary',
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildPaymentSummaryCard(context, order),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, OrderEntity order) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAr ? 'رقم الطلب' : 'Order ID',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    order.orderNumber,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              _StatusChip(status: order.status),
            ],
          ),
          const Divider(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(order.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Text(
                isAr
                    ? '${order.totalItemCount} قطعة'
                    : '${order.totalItemCount} items',
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context, OrderEntity order) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final currentStatus = order.status;

    if (currentStatus == OrderStatus.cancelled) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.cancel_rounded, color: AppColors.error, size: 26),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAr ? 'تم إلغاء هذا الطلب' : 'This order was cancelled',
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.cancellationReason ??
                        (isAr
                            ? 'تم إلغاء الطلب بناءً على رغبتك أو عدم توفر السلعة.'
                            : 'Order was cancelled at customer request or stock unavailability.'),
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 13,
                      color: Colors.red.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final steps = [
      (
        OrderStatus.pending,
        isAr ? 'تم الطلب' : 'Placed',
        isAr ? 'تم استلام الطلب وبانتظار التأكيد' : 'Order received & recorded',
        Icons.receipt_long_rounded,
      ),
      (
        OrderStatus.processing,
        isAr ? 'قيد التجهيز' : 'Processing',
        isAr ? 'جاري تجهيز وتغليف شحنتك' : 'Preparing at warehouse',
        Icons.inventory_2_rounded,
      ),
      (
        OrderStatus.shipped,
        isAr ? 'خرج للتوصيل' : 'Shipped',
        isAr ? 'الشحنة مع المندوب وفي الطريق' : 'Courier on the way',
        Icons.local_shipping_rounded,
      ),
      (
        OrderStatus.delivered,
        isAr ? 'تم التسليم' : 'Delivered',
        isAr ? 'تم تسليم الشحنة بنجاح' : 'Delivered successfully',
        Icons.verified_rounded,
      ),
    ];

    final currentIndex = steps.indexWhere((step) => step.$1 == currentStatus);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.borderDark
              : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isAr ? 'مراحل متابعة الطلب' : 'Order Progress Tracker',
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isAr ? 'تحديث فوري' : 'Live Sync',
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Column(
            children: List.generate(steps.length, (index) {
              final step = steps[index];
              final isCompleted = index < currentIndex;
              final isCurrent = index == currentIndex;
              final isUpcoming = index > currentIndex;
              final isLast = index == steps.length - 1;

              final circleColor = isCompleted
                  ? AppColors.success
                  : isCurrent
                      ? AppColors.primary
                      : Colors.grey.shade400;

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? AppColors.success
                                : isCurrent
                                    ? AppColors.primary
                                    : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: circleColor,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            isCompleted
                                ? Icons.check_rounded
                                : step.$4,
                            size: 16,
                            color: (isCompleted || isCurrent)
                                ? Colors.white
                                : Colors.grey.shade400,
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              color: isCompleted
                                  ? AppColors.success
                                  : Colors.grey.shade300,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: isLast ? 0 : AppSpacing.md,
                          top: 4,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  step.$2,
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 14,
                                    fontWeight: isCurrent
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: isCurrent
                                        ? AppColors.primary
                                        : isUpcoming
                                            ? Colors.grey
                                            : null,
                                  ),
                                ),
                                if (isCurrent) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 1.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      isAr ? 'الآن' : 'ACTIVE',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              step.$3,
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingCard(BuildContext context, Map<String, dynamic> addr) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline_rounded, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Text(
                (addr['name'] as String?) ?? 'Recipient Name',
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              const Icon(Icons.phone_outlined, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Text(
                (addr['phone'] as String?) ?? '-',
                style: const TextStyle(fontFamily: 'Outfit'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  '${addr['street'] ?? ''}, ${addr['city'] ?? ''}',
                  style: const TextStyle(fontFamily: 'Outfit'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummaryCard(BuildContext context, OrderEntity order) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = Localizations.localeOf(context).languageCode == 'ar';
    final sar = context.l10n.general_sar;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        children: [
          _Row(
            label: isRtl ? 'طريقة الدفع' : 'Payment Method',
            value: order.paymentMethod.toUpperCase(),
          ),
          const Divider(height: AppSpacing.lg),
          _Row(
            label: isRtl ? 'المجموع الفرعي' : 'Subtotal',
            value: '${order.subtotal.toStringAsFixed(2)} $sar',
          ),
          if (order.discountAmount > 0)
            _Row(
              label: isRtl ? 'الخصم (كوبون)' : 'Coupon Discount',
              value: '-${order.discountAmount.toStringAsFixed(2)} $sar',
              color: AppColors.success,
              isBold: true,
            ),
          _Row(
            label: isRtl ? 'الشحن' : 'Shipping',
            value: order.shippingCost == 0
                ? (isRtl ? 'مجاني 🎉' : 'Free 🎉')
                : '${order.shippingCost.toStringAsFixed(2)} $sar',
            color: order.shippingCost == 0 ? AppColors.success : null,
          ),
          _Row(
            label: isRtl ? 'الضريبة' : 'Tax',
            value: '${order.tax.toStringAsFixed(2)} $sar',
          ),
          const Divider(height: AppSpacing.lg),
          _Row(
            label: isRtl ? 'الإجمالي' : 'Total',
            value: '${order.total.toStringAsFixed(2)} $sar',
            isBold: true,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  // ─── Bottom Action Bar (Cancel & 1-Tap Reorder) ─────────────────────────────

  Widget _buildBottomBar(BuildContext context, WidgetRef ref, OrderEntity order) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Cancel Order (if order is pending or processing)
            if (order.canCancel) ...[
              Expanded(
                flex: 1,
                child: OutlinedButton.icon(
                  onPressed: () => _showCancelModal(context, ref, order),
                  icon: const Icon(
                    Icons.cancel_outlined,
                    size: 18,
                    color: AppColors.error,
                  ),
                  label: Text(
                    isAr ? 'إلغاء الطلب' : 'Cancel Order',
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppColors.error.withValues(alpha: 0.5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
            ],

            // 1-Tap Re-order (always available)
            Expanded(
              flex: 1,
              child: ElevatedButton.icon(
                onPressed: () => _handleReorder(context, ref, order),
                icon: const Icon(Icons.replay_rounded, size: 18),
                label: Text(
                  isAr ? 'إعادة الطلب' : 'Re-order',
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleReorder(BuildContext context, WidgetRef ref, OrderEntity order) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    ref.read(cartNotifierProvider.notifier).reorderItems(order.items);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                isAr
                    ? 'تمت إضافة جميع منتجات الطلب إلى السلة بنجاح!'
                    : 'All order items added to your cart!',
                style: const TextStyle(fontFamily: 'Outfit'),
              ),
            ),
          ],
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
  }

  void _showCancelModal(BuildContext context, WidgetRef ref, OrderEntity order) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) => _CancelOrderBottomSheet(
        order: order,
        onConfirmCancel: (reason) async {
          Navigator.pop(modalContext);
          final success = await ref
              .read(userOrdersProvider.notifier)
              .cancelOrder(order.id, reason: reason);

          if (context.mounted) {
            final isAr = Localizations.localeOf(context).languageCode == 'ar';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  success
                      ? (isAr
                          ? 'تم إلغاء الطلب بنجاح.'
                          : 'Order cancelled successfully.')
                      : (isAr
                          ? 'فشل إلغاء الطلب. يرجى المحاولة لاحقاً.'
                          : 'Failed to cancel order. Please try again.'),
                  style: const TextStyle(fontFamily: 'Outfit'),
                ),
                backgroundColor:
                    success ? AppColors.success : AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

// ─── Cancel Order Bottom Sheet Modal ──────────────────────────────────────────

class _CancelOrderBottomSheet extends StatefulWidget {
  const _CancelOrderBottomSheet({
    required this.order,
    required this.onConfirmCancel,
  });

  final OrderEntity order;
  final ValueChanged<String> onConfirmCancel;

  @override
  State<_CancelOrderBottomSheet> createState() =>
      _CancelOrderBottomSheetState();
}

class _CancelOrderBottomSheetState extends State<_CancelOrderBottomSheet> {
  int _selectedReasonIndex = 0;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final reasons = [
      isAr ? 'غيرت رأيي ولم أعد بحاجة للمنتج' : 'I changed my mind',
      isAr ? 'وقت الشحن والتوصيل طويل جداً' : 'Delivery time is too long',
      isAr ? 'وجدت سعراً أفضل في متجر آخر' : 'Found a better price elsewhere',
      isAr ? 'اخترت مقاس أو لون أو منتج خاطئ' : 'Ordered wrong item or variant',
      isAr ? 'أسباب أخرى' : 'Other reasons',
    ];

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.error,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  isAr ? 'إلغاء الطلب' : 'Cancel Order',
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              isAr
                  ? 'هل أنت متأكد من رغبتك في إلغاء الطلب ${widget.order.orderNumber}؟ يرجى إخبارنا بالسبب:'
                  : 'Are you sure you want to cancel order ${widget.order.orderNumber}? Please choose a reason:',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 13,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ...List.generate(reasons.length, (index) {
              final isSelected = _selectedReasonIndex == index;
              return InkWell(
                onTap: () => setState(() => _selectedReasonIndex = index),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 4,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: isSelected
                            ? AppColors.primary
                            : Colors.grey.shade400,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          reasons[index],
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isAr ? 'الاحتفاظ بالطلب' : 'Keep Order',
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            setState(() => _isLoading = true);
                            widget.onConfirmCancel(
                              reasons[_selectedReasonIndex],
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isAr ? 'تأكيد الإلغاء' : 'Confirm Cancel',
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Order Item Row (with Color, Size, SKU from Step 5) ───────────────────────

class _OrderItemRow extends StatelessWidget {
  const _OrderItemRow({required this.item, required this.isRtl});
  final OrderItemEntity item;
  final bool isRtl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.productImage,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 56,
                height: 56,
                color: Colors.grey.shade300,
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRtl ? item.productNameAr : item.productNameEn,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.hasVariant || item.displayVariant != null) ...[
                  const SizedBox(height: 3),
                  Wrap(
                    spacing: 6,
                    runSpacing: 3,
                    children: [
                      if (item.color != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.color!,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        )
                      else if (item.variantLabel != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.variantLabel!,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      if (item.size != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surfaceVariantDark
                                : AppColors.surfaceVariantLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Size: ${item.size}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      if (item.sku != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surfaceVariantDark
                                    .withValues(alpha: 0.5)
                                : AppColors.surfaceVariantLight
                                    .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'SKU: ${item.sku}',
                            style: TextStyle(
                              fontSize: 9,
                              fontFamily: 'Outfit',
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 3),
                Text(
                  '${isRtl ? 'الكمية' : 'Qty'}: ${item.quantity} × ${item.priceAtPurchase.toStringAsFixed(2)} ${context.l10n.general_sar}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '${(item.priceAtPurchase * item.quantity).toStringAsFixed(2)} ${context.l10n.general_sar}',
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.isBold = false,
    this.color,
  });

  final String label;
  final String value;
  final bool isBold;
  final Color? color;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
                fontSize: isBold ? 15 : 13,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                fontSize: isBold ? 16 : 13,
                color: color,
              ),
            ),
          ],
        ),
      );
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, text, label) = _getColors();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontSize: 12,
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
