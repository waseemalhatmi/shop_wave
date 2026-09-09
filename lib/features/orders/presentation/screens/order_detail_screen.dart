import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
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
    final orderDetailsAsync = ref.watch(orderDetailsProvider(orderId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Order Details',
          style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.transparent,
        elevation: 0,
      ),
      body: orderDetailsAsync.when(
        data: (order) => _buildBody(context, order),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 60, color: AppColors.error),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Failed to load order details',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              ElevatedButton(
                onPressed: () => ref.invalidate(orderDetailsProvider(orderId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, OrderEntity order) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          _buildHeaderCard(context, order),
          const SizedBox(height: AppSpacing.lg),

          // Order Timeline (Status tracker)
          _buildTimeline(context, order.status),
          const SizedBox(height: AppSpacing.lg),

          // Product list
          const Text(
            'Order Items',
            style: TextStyle(
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
          const Text(
            'Shipping Information',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildShippingCard(context, order.shippingAddress),
          const SizedBox(height: AppSpacing.lg),

          // Financial summary
          const Text(
            'Payment Summary',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildPaymentSummaryCard(context, order),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, OrderEntity order) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order ID',
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
    );
  }

  Widget _buildTimeline(BuildContext context, OrderStatus currentStatus) {
    final steps = [
      (OrderStatus.pending, 'Pending', Icons.receipt_long_outlined),
      (OrderStatus.processing, 'Processing', Icons.build_circle_outlined),
      (OrderStatus.shipped, 'Shipped', Icons.local_shipping_outlined),
      (OrderStatus.delivered, 'Delivered', Icons.task_alt_rounded),
    ];

    if (currentStatus == OrderStatus.cancelled) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.cancel_outlined, color: Colors.red),
            SizedBox(width: AppSpacing.md),
            Text(
              'This order has been cancelled.',
              style: TextStyle(
                fontFamily: 'Outfit',
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    final currentIndex = steps.indexWhere((step) => step.$1 == currentStatus);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isActive = index <= currentIndex;
        final color = isActive ? AppColors.primary : Colors.grey.shade400;

        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: index == 0
                        ? const SizedBox()
                        : Divider(color: index <= currentIndex ? AppColors.primary : Colors.grey.shade300, thickness: 2),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isActive ? color.withValues(alpha: 0.1) : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(color: color, width: 2),
                    ),
                    child: Icon(step.$3, size: 18, color: color),
                  ),
                  Expanded(
                    child: index == steps.length - 1
                        ? const SizedBox()
                        : Divider(color: index < currentIndex ? AppColors.primary : Colors.grey.shade300, thickness: 2),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                step.$2,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? AppColors.primary : Colors.grey,
                ),
              ),
            ],
          ),
        );
      }),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
          _Row(label: isRtl ? 'طريقة الدفع' : 'Payment Method', value: order.paymentMethod.toUpperCase()),
          const Divider(height: AppSpacing.lg),
          _Row(label: isRtl ? 'المجموع الفرعي' : 'Subtotal', value: '${order.subtotal.toStringAsFixed(2)} $sar'),
          if (order.discountAmount > 0)
            _Row(
              label: isRtl ? 'الخصم' : 'Discount',
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
          _Row(label: isRtl ? 'الضريبة' : 'Tax', value: '${order.tax.toStringAsFixed(2)} $sar'),
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
}

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
                child: const Icon(Icons.image_not_supported_outlined, size: 20),
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
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
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
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
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
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
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
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surfaceVariantDark.withValues(alpha: 0.5)
                                : AppColors.surfaceVariantLight.withValues(alpha: 0.5),
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
            Text(label,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
                  fontSize: isBold ? 15 : 13,
                )),
            Text(value,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                  fontSize: isBold ? 16 : 13,
                  color: color,
                )),
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
        return (Colors.orange.withValues(alpha: 0.15), Colors.orange.shade800, 'Pending');
      case OrderStatus.processing:
        return (Colors.blue.withValues(alpha: 0.15), Colors.blue.shade800, 'Processing');
      case OrderStatus.shipped:
        return (Colors.purple.withValues(alpha: 0.15), Colors.purple.shade800, 'Shipped');
      case OrderStatus.delivered:
        return (Colors.green.withValues(alpha: 0.15), Colors.green.shade800, 'Delivered');
      case OrderStatus.cancelled:
        return (Colors.red.withValues(alpha: 0.15), Colors.red.shade800, 'Cancelled');
    }
  }
}
