import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/guest_auth_prompt.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../domain/entities/cart_entity.dart';
import '../providers/cart_notifier.dart';

/// Full Cart Screen — Professional redesign with visible items & rich details.
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF0F0F8),
      appBar: _CartAppBar(cart: cart, isDark: isDark, isAr: isAr, ref: ref),
      body: cart.isEmpty
          ? const _EmptyCartView()
          : _CartBody(cart: cart, isDark: isDark, isAr: isAr),
      bottomNavigationBar: cart.isEmpty
          ? null
          : _CheckoutBar(total: cart.total, isDark: isDark, isAr: isAr),
    );
  }
}

// ─── AppBar ───────────────────────────────────────────────────────────────────

class _CartAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _CartAppBar({
    required this.cart,
    required this.isDark,
    required this.isAr,
    required this.ref,
  });

  final CartEntity cart;
  final bool isDark;
  final bool isAr;
  final WidgetRef ref;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor:
          isDark ? Colors.black26 : AppColors.primary.withValues(alpha: 0.08),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text( 
            isAr ? 'سلة التسوق' : 'Shopping Cart',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
          ),
          if (!cart.isEmpty) ...[
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF8B85FF)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${cart.totalItems}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Outfit',
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (!cart.isEmpty)
          TextButton.icon(
            onPressed: () => _confirmClear(context, ref, isAr),
            icon: const Icon(Icons.delete_sweep_rounded,
                size: 18, color: AppColors.badge),
            label: Text(
              isAr ? 'مسح الكل' : 'Clear All',
              style: const TextStyle(
                color: AppColors.badge,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        const SizedBox(width: 4),
      ],
    );
  }

  void _confirmClear(BuildContext context, WidgetRef ref, bool isAr) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.badge.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.delete_outline, color: AppColors.badge, size: 22),
            ),
            const SizedBox(width: 12),
            Text(
              isAr ? 'مسح السلة؟' : 'Clear Cart?',
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(isAr
            ? 'سيتم حذف جميع المنتجات من سلة التسوق الخاصة بك.'
            : 'All items will be removed from your cart.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(isAr ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              ref.read(cartNotifierProvider.notifier).clearCart();
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(80, 40),
              backgroundColor: AppColors.badge,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(isAr ? 'مسح' : 'Clear'),
          ),
        ],
      ),
    );
  }
}

// ─── Cart Body ────────────────────────────────────────────────────────────────

class _CartBody extends StatelessWidget {
  const _CartBody({
    required this.cart,
    required this.isDark,
    required this.isAr,
  });

  final CartEntity cart;
  final bool isDark;
  final bool isAr;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      children: [
        // ── Free shipping banner ─────────────────────────────────
        if (cart.subtotal < 100) _FreeShippingBanner(cart: cart, isAr: isAr),
        if (cart.subtotal < 100) const SizedBox(height: 12),

        // ── Cart Items ───────────────────────────────────────────
        ...cart.items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _CartItemCard(item: item, isDark: isDark, isAr: isAr),
          ),
        ),

        const SizedBox(height: 4),

        // ── Coupon ───────────────────────────────────────────────
        _CouponSection(cart: cart, isDark: isDark, isAr: isAr),
        const SizedBox(height: 12),

        // ── Delivery Info ────────────────────────────────────────
        _DeliveryInfoCard(isDark: isDark, isAr: isAr),
        const SizedBox(height: 12),

        // ── Order Summary ────────────────────────────────────────
        _OrderSummary(cart: cart, isDark: isDark, isAr: isAr),
        const SizedBox(height: 12),

        // ── Trust Badges ─────────────────────────────────────────
        _TrustBadges(isDark: isDark, isAr: isAr),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ─── Free Shipping Banner ─────────────────────────────────────────────────────

class _FreeShippingBanner extends StatelessWidget {
  const _FreeShippingBanner({required this.cart, required this.isAr});
  final CartEntity cart;
  final bool isAr;

  @override
  Widget build(BuildContext context) {
    final remaining = 100 - cart.subtotal;
    final progress = (cart.subtotal / 100).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.12),
            AppColors.secondary.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🚚', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isAr
                      ? 'أضف ${remaining.toStringAsFixed(2)} ر.س للحصول على شحن مجاني!'
                      : 'Add ${remaining.toStringAsFixed(2)} SAR for FREE shipping!',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Cart Item Card ───────────────────────────────────────────────────────────

class _CartItemCard extends ConsumerWidget {
  const _CartItemCard({
    required this.item,
    required this.isDark,
    required this.isAr,
  });

  final CartItemEntity item;
  final bool isDark;
  final bool isAr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(cartNotifierProvider.notifier);
    final langCode = isAr ? 'ar' : 'en';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? const Color(0xFF2E2E45)
              : const Color(0xFFE8E8F4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : AppColors.primary.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Product Image ──────────────────────────────────
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: item.product.primaryImageUrl != null
                          ? Image.network(
                              item.product.primaryImageUrl!,
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _ImagePlaceholder(isDark: isDark),
                              loadingBuilder: (ctx, child, progress) {
                                if (progress == null) return child;
                                return _ImagePlaceholder(isDark: isDark);
                              },
                            )
                          : _ImagePlaceholder(isDark: isDark),
                    ),
                    // Discount badge
                    if (item.product.hasDiscount)
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.badge,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomRight: Radius.circular(8),
                            ),
                          ),
                          child: Text(
                            '-${item.product.discountPercenti}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),

                // ── Product Info ───────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Store / Brand badge
                      if (item.product.brandId != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.store_rounded,
                                  size: 10,
                                  color: AppColors.primary.withValues(
                                      alpha: 0.8)),
                              const SizedBox(width: 3),
                              Text(
                                isAr ? 'متجر رسمي' : 'Official Store',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary.withValues(
                                      alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                      ],

                      // Product name
                      Text(
                        item.localizedName(langCode),
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1A1A2E),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // SKU
                      if (item.sku != null || item.product.sku != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          'SKU: ${item.sku ?? item.product.sku}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? const Color(0xFF9999AA)
                                : const Color(0xFF9898A8),
                          ),
                        ),
                      ],

                      // Variant chips
                      if (item.hasVariant) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 5,
                          runSpacing: 4,
                          children: [
                            if (item.color != null)
                              _VariantChip(
                                label: item.color!,
                                icon: Icons.circle,
                                isDark: isDark,
                                isColor: true,
                              ),
                            if (item.size != null)
                              _VariantChip(
                                label: isAr
                                    ? 'المقاس: ${item.size}'
                                    : 'Size: ${item.size}',
                                isDark: isDark,
                              ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 8),

                      // Price display (Wrap ensures no overflow on narrow screens)
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 2,
                        children: [
                          Text(
                            '${item.effectivePrice.toStringAsFixed(2)} ر.س',
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: AppColors.primary,
                            ),
                          ),
                          if (item.product.hasDiscount)
                            Text(
                              '${item.product.basePrice.toStringAsFixed(2)} ر.س',
                              style: const TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 12,
                                color: AppColors.originalPrice,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Delete Button ──────────────────────────────────
                IconButton(
                  onPressed: () => notifier.removeItem(
                    item.product.id,
                    variantId: item.variantId,
                    color: item.color,
                    size: item.size,
                  ),
                  icon: Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: isDark
                        ? const Color(0xFF9999AA)
                        : const Color(0xFFB0B0C0),
                  ),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // ── Bottom bar: Qty Controls + Subtotal ───────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF242438)
                  : const Color(0xFFF8F8FF),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Quantity stepper
                Row(
                  children: [
                    _QtyButton(
                      icon: item.quantity <= 1
                          ? Icons.delete_outline_rounded
                          : Icons.remove_rounded,
                      onTap: () => notifier.decrement(
                        item.product.id,
                        variantId: item.variantId,
                        color: item.color,
                        size: item.size,
                      ),
                      isDestructive: item.quantity <= 1,
                      isDark: isDark,
                    ),
                    Container(
                      width: 44,
                      height: 34,
                      alignment: Alignment.center,
                      child: Text(
                        '${item.quantity}',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                        ),
                      ),
                    ),
                    _QtyButton(
                      icon: Icons.add_rounded,
                      onTap: () => notifier.increment(
                        item.product.id,
                        variantId: item.variantId,
                        color: item.color,
                        size: item.size,
                      ),
                      isDark: isDark,
                    ),
                  ],
                ),

                // Subtotal
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isAr ? 'المجموع' : 'Subtotal',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? const Color(0xFF9999AA)
                            : const Color(0xFF9898A8),
                      ),
                    ),
                    Text(
                      '${item.subtotal.toStringAsFixed(2)} ر.س',
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Variant Chip ─────────────────────────────────────────────────────────────

class _VariantChip extends StatelessWidget {
  const _VariantChip({
    required this.label,
    required this.isDark,
    this.icon,
    this.isColor = false,
  });

  final String label;
  final bool isDark;
  final IconData? icon;
  final bool isColor;

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(maxWidth: 160),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF2E2E45)
              : const Color(0xFFEEEEFA),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isDark
                ? const Color(0xFF3E3E58)
                : const Color(0xFFDDDDEE),
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFCCCCDD) : const Color(0xFF555568),
          ),
        ),
      );
}

// ─── Qty Button ───────────────────────────────────────────────────────────────

class _QtyButton extends StatelessWidget {
  const _QtyButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
    this.isDestructive = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: isDestructive
                ? AppColors.badge.withValues(alpha: 0.12)
                : AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDestructive
                  ? AppColors.badge.withValues(alpha: 0.25)
                  : AppColors.primary.withValues(alpha: 0.25),
            ),
          ),
          child: Icon(
            icon,
            size: 17,
            color: isDestructive ? AppColors.badge : AppColors.primary,
          ),
        ),
      );
}

// ─── Image Placeholder ────────────────────────────────────────────────────────

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) => Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF242438) : const Color(0xFFF0F0F8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.image_outlined,
          size: 32,
          color: isDark ? const Color(0xFF4A4A6A) : const Color(0xFFBBBBCC),
        ),
      );
}

// ─── Delivery Info ────────────────────────────────────────────────────────────

class _DeliveryInfoCard extends StatelessWidget {
  const _DeliveryInfoCard({required this.isDark, required this.isAr});
  final bool isDark;
  final bool isAr;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.local_shipping_outlined, isAr ? 'التوصيل خلال 2-5 أيام' : 'Delivery in 2-5 days'),
      (Icons.replay_rounded, isAr ? 'إرجاع مجاني خلال 30 يوم' : 'Free returns within 30 days'),
      (Icons.verified_user_outlined, isAr ? 'منتجات أصلية ومضمونة' : 'Authentic & guaranteed'),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2E2E45) : const Color(0xFFE8E8F4),
          width: 1.5,
        ),
      ),
      child: Column(
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(item.$1,
                          size: 15, color: AppColors.primary),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.$2,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? const Color(0xFFCCCCDD)
                              : const Color(0xFF444455),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ─── Order Summary ────────────────────────────────────────────────────────────

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({
    required this.cart,
    required this.isDark,
    required this.isAr,
  });

  final CartEntity cart;
  final bool isDark;
  final bool isAr;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF2E2E45) : const Color(0xFFE8E8F4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            isAr ? 'ملخص الطلب' : 'Order Summary',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 14),

          // Items count
          _SummaryRow(
            label: isAr
                ? '${cart.items.length} منتج (${cart.totalItems} قطعة)'
                : '${cart.items.length} items (${cart.totalItems} qty)',
            value:
                '${cart.subtotal.toStringAsFixed(2)} ر.س',
            isDark: isDark,
          ),

          // Discount
          if (cart.discountAmount > 0) ...[
            const SizedBox(height: 4),
            _SummaryRow(
              label: isAr
                  ? 'خصم (${cart.appliedCoupon?.code})'
                  : 'Discount (${cart.appliedCoupon?.code})',
              value:
                  '-${cart.discountAmount.toStringAsFixed(2)} ر.س',
              valueColor: AppColors.success,
              isBold: true,
              isDark: isDark,
            ),
          ],

          const SizedBox(height: 4),

          // Shipping
          _SummaryRow(
            label: isAr ? 'رسوم الشحن' : 'Shipping',
            value: cart.shippingCost == 0
                ? (isAr ? 'مجاني 🎉' : 'Free 🎉')
                : '${cart.shippingCost.toStringAsFixed(2)} ر.س',
            valueColor: cart.shippingCost == 0 ? AppColors.success : null,
            isDark: isDark,
          ),
          const SizedBox(height: 4),

          // Tax
          _SummaryRow(
            label: isAr ? 'ضريبة القيمة المضافة (8%)' : 'VAT (8%)',
            value: '${cart.tax.toStringAsFixed(2)} ر.س',
            isDark: isDark,
          ),

          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(
              color: isDark
                  ? const Color(0xFF2E2E45)
                  : const Color(0xFFEEEEFA),
              thickness: 1.5,
            ),
          ),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isAr ? 'الإجمالي النهائي' : 'Total Amount',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF8B85FF)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${cart.total.toStringAsFixed(2)} ر.س',
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          // Savings banner
          if (cart.discountAmount > 0) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.savings_outlined,
                      size: 16, color: AppColors.success),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      isAr
                          ? 'وفّرت ${cart.discountAmount.toStringAsFixed(2)} ر.س في هذا الطلب!'
                          : 'You saved ${cart.discountAmount.toStringAsFixed(2)} SAR on this order!',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.isDark,
    this.isBold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool isDark;
  final bool isBold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
                fontSize: 14,
                color: isDark
                    ? const Color(0xFFAAAAAA)
                    : const Color(0xFF777788),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              fontSize: 14,
              color: valueColor ??
                  (isDark ? const Color(0xFFDDDDEE) : const Color(0xFF333344)),
            ),
          ),
        ],
      );
}

// ─── Trust Badges ─────────────────────────────────────────────────────────────

class _TrustBadges extends StatelessWidget {
  const _TrustBadges({required this.isDark, required this.isAr});
  final bool isDark;
  final bool isAr;

  @override
  Widget build(BuildContext context) {
    final badges = [
      (Icons.lock_outline_rounded, isAr ? 'دفع آمن' : 'Secure Pay'),
      (Icons.verified_outlined, isAr ? 'منتجات أصلية' : 'Authentic'),
      (Icons.support_agent_rounded, isAr ? 'دعم 24/7' : '24/7 Support'),
      (Icons.replay_rounded, isAr ? 'ارجاع مجاني' : 'Free Returns'),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: badges
          .map(
            (b) => Column(
              children: [
                Icon(b.$1,
                    size: 20,
                    color: isDark
                        ? const Color(0xFF9999AA)
                        : const Color(0xFFAAAAAB)),
                const SizedBox(height: 4),
                Text(
                  b.$2,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? const Color(0xFF8888AA)
                        : const Color(0xFFAAAABB),
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}

// ─── Checkout Bar ─────────────────────────────────────────────────────────────

class _CheckoutBar extends ConsumerWidget {
  const _CheckoutBar({
    required this.total,
    required this.isDark,
    required this.isAr,
  });

  final double total;
  final bool isDark;
  final bool isAr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.paddingOf(context).bottom + 12,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF2E2E45) : const Color(0xFFEEEEF5),
            width: 1.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.4)
                : AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: () {
            final authState = ref.read(authNotifierProvider);
            if (authState is! AuthAuthenticated) {
              GuestAuthPrompt.show(
                context,
                title: isAr
                    ? 'تسجيل الدخول مطلوب للشراء'
                    : 'Sign in to Checkout',
                message: isAr
                    ? 'يرجى تسجيل الدخول أو إنشاء حساب لإتمام الطلب وتحديد عنوان التوصيل. ستبقى منتجاتك في السلة بأمان.'
                    : 'Please sign in or register to complete your order. Your cart will be saved.',
                icon: Icons.shopping_bag_outlined,
              );
              return;
            }
            context.push(AppRoutes.checkout);
          },
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5A52E8), Color(0xFF8B85FF)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_bag_outlined,
                    color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    isAr
                        ? 'إتمام الطلب'
                        : 'Proceed to Checkout',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  height: 32,
                  width: 1,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                const SizedBox(width: 10),
                Text(
                  '${total.toStringAsFixed(2)} ر.س',
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Empty Cart View ──────────────────────────────────────────────────────────

class _EmptyCartView extends StatelessWidget {
  const _EmptyCartView();

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.12),
                    AppColors.secondary.withValues(alpha: 0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 56,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isAr ? 'سلتك فارغة' : 'Your cart is empty',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isAr
                  ? 'اكتشف آلاف المنتجات وأضف ما يعجبك إلى سلتك'
                  : 'Discover thousands of products and add your favourites',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? const Color(0xFF9999AA)
                    : const Color(0xFF9898A8),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () => context.go(AppRoutes.home),
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 32),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF8B85FF)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.explore_outlined,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      isAr ? 'تصفح المنتجات' : 'Shop Now',
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Coupon Section ───────────────────────────────────────────────────────────

class _CouponSection extends ConsumerStatefulWidget {
  const _CouponSection({
    required this.cart,
    required this.isDark,
    required this.isAr,
  });

  final CartEntity cart;
  final bool isDark;
  final bool isAr;

  @override
  ConsumerState<_CouponSection> createState() => _CouponSectionState();
}

class _CouponSectionState extends ConsumerState<_CouponSection> {
  final _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _applyCoupon() async {
    final code = _controller.text.trim();
    if (code.isEmpty) return;

    setState(() => _isLoading = true);
    final result = await ref.read(cartNotifierProvider.notifier).applyCoupon(
          code,
          isAr: widget.isAr,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    result.fold(
      (error) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(error), backgroundColor: AppColors.error),
      ),
      (coupon) {
        _controller.clear();
        FocusScope.of(context).unfocus();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isAr
                ? 'تم تفعيل كود الخصم \"${coupon.code}\" بنجاح! 🎉'
                : 'Coupon \"${coupon.code}\" applied! 🎉'),
            backgroundColor: AppColors.success,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appliedCoupon = widget.cart.appliedCoupon;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: appliedCoupon != null
              ? AppColors.success.withValues(alpha: 0.4)
              : (widget.isDark
                  ? const Color(0xFF2E2E45)
                  : const Color(0xFFE8E8F4)),
          width: 1.5,
        ),
      ),
      child: appliedCoupon != null
          ? Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.local_offer_rounded,
                      color: AppColors.success, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            appliedCoupon.code,
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              appliedCoupon.formattedDiscount('ر.س'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        widget.isAr
                            ? 'خصم ${widget.cart.discountAmount.toStringAsFixed(2)} ر.س مطبق'
                            : '${widget.cart.discountAmount.toStringAsFixed(2)} SAR discount applied',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.success),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.badge, size: 18),
                  onPressed: () =>
                      ref.read(cartNotifierProvider.notifier).removeCoupon(),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textCapitalization: TextCapitalization.characters,
                    style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w600,
                        fontSize: 14),
                    decoration: InputDecoration(
                      hintText: widget.isAr
                          ? 'كود الخصم (مثال: SAVE20)'
                          : 'Promo Code (e.g. SAVE20)',
                      prefixIcon: const Icon(
                          Icons.confirmation_number_outlined,
                          size: 20),
                      filled: true,
                      fillColor: widget.isDark
                          ? const Color(0xFF242438)
                          : const Color(0xFFF5F5FC),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _applyCoupon,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(80, 48),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            widget.isAr ? 'تطبيق' : 'Apply',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}
