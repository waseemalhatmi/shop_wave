import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/guest_auth_prompt.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../domain/entities/cart_entity.dart';
import '../providers/cart_notifier.dart';

/// Full Cart Screen connected to CartNotifier.
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          '${context.l10n.cart_title} (${cart.totalItems})',
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.transparent,
        elevation: 0,
        actions: [
          if (!cart.isEmpty)
            TextButton(
              onPressed: () => _confirmClear(context, ref),
              child: Text(
                isAr ? 'مسح الكل' : 'Clear All',
                style: const TextStyle(color: AppColors.badge),
              ),
            ),
        ],
      ),

      body: cart.isEmpty
          ? _EmptyCartView()
          : Column(
              children: [
                // ── Cart Items, Coupon & Summary ────────────────────
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal,
                      vertical: AppSpacing.sm,
                    ),
                    children: [
                      ...cart.items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _CartItemCard(item: item),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _CouponSection(cart: cart),
                      const SizedBox(height: AppSpacing.sm),
                      _OrderSummary(cart: cart),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ),
                ),
              ],
            ),

      // ── Checkout Button ─────────────────────────────────────────
      bottomNavigationBar: cart.isEmpty
          ? null
          : _CheckoutBar(total: cart.total),
    );
  }

  void _confirmClear(BuildContext context, WidgetRef ref) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isAr ? 'مسح السلة؟' : 'Clear Cart?'),
        content: Text(isAr
            ? 'سيتم حذف جميع المنتجات من سلة التسوق الخاصة بك.'
            : 'All items will be removed from your cart.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.general_cancel),
          ),
          TextButton(
            onPressed: () {
              ref.read(cartNotifierProvider.notifier).clearCart();
              Navigator.pop(context);
            },
            child: Text(
              isAr ? 'مسح' : 'Clear',
              style: const TextStyle(color: AppColors.badge),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyCartView extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 56,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              context.l10n.cart_empty,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              context.l10n.cart_empty_desc,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: () => context.go(AppRoutes.home),
              icon: const Icon(Icons.explore_outlined),
              label: Text(context.l10n.cart_shop_now),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, AppSpacing.buttonHeight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      );
}

// ─── Cart Item Card ───────────────────────────────────────────────────────────

class _CartItemCard extends ConsumerWidget {
  const _CartItemCard({required this.item});
  final CartItemEntity item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final notifier = ref.read(cartNotifierProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.shadowDark : AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: item.product.primaryImageUrl != null
                ? Image.network(
                    item.product.primaryImageUrl!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _ProductImagePlaceholder(),
                  )
                : _ProductImagePlaceholder(),
          ),
          const SizedBox(width: AppSpacing.md),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.localizedName(Localizations.localeOf(context).languageCode),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.hasVariant) ...[
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (item.color != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.color!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      if (item.size != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Size: ${item.size}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      if (item.sku != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceVariantDark.withValues(alpha: 0.5) : AppColors.surfaceVariantLight.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'SKU: ${item.sku}',
                            style: TextStyle(
                              fontSize: 10,
                              fontFamily: 'Outfit',
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${item.effectivePrice.toStringAsFixed(2)} ${context.l10n.general_sar}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Quantity Controls
                Row(
                  children: [
                    _QtyButton(
                      icon: Icons.remove_rounded,
                      onTap: () => notifier.decrement(
                        item.product.id,
                        variantId: item.variantId,
                        color: item.color,
                        size: item.size,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
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
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Delete
          Column(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.badge,
                  size: 20,
                ),
                onPressed: () => notifier.removeItem(
                  item.product.id,
                  variantId: item.variantId,
                  color: item.color,
                  size: item.size,
                ),
              ),
              Text(
                '${item.subtotal.toStringAsFixed(2)} ${context.l10n.general_sar}',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurfaceVariantLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
}

class _ProductImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 80,
        height: 80,
        color: AppColors.surfaceVariantLight,
        child: const Icon(
          Icons.image_outlined,
          color: AppColors.onSurfaceVariantLight,
        ),
      );
}

// ─── Order Summary ────────────────────────────────────────────────────────────

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.cart});
  final CartEntity cart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.shadowDark : AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: context.l10n.cart_subtotal,
            value: '${cart.subtotal.toStringAsFixed(2)} ${context.l10n.general_sar}',
          ),
          if (cart.discountAmount > 0)
            _SummaryRow(
              label: isAr
                  ? 'الخصم (${cart.appliedCoupon?.code})'
                  : 'Discount (${cart.appliedCoupon?.code})',
              value: '-${cart.discountAmount.toStringAsFixed(2)} ${context.l10n.general_sar}',
              valueColor: AppColors.success,
              isBold: true,
            ),
          _SummaryRow(
            label: context.l10n.cart_shipping,
            value: cart.shippingCost == 0
                ? (isAr ? 'مجاني 🎉' : 'Free 🎉')
                : '${cart.shippingCost.toStringAsFixed(2)} ${context.l10n.general_sar}',
            valueColor:
                cart.shippingCost == 0 ? AppColors.success : null,
          ),
          _SummaryRow(
            label: isAr ? 'الضريبة (8%)' : 'Tax (8%)',
            value: '${cart.tax.toStringAsFixed(2)} ${context.l10n.general_sar}',
          ),
          const Divider(height: AppSpacing.lg),
          _SummaryRow(
            label: context.l10n.cart_total,
            value: '${cart.total.toStringAsFixed(2)} ${context.l10n.general_sar}',
            isBold: true,
            valueColor: AppColors.primary,
          ),
          if (cart.subtotal < 100)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                isAr 
                    ? 'أضف ${(100 - cart.subtotal).toStringAsFixed(2)} ${context.l10n.general_sar} إضافية للحصول على شحن مجاني!'
                    : 'Add \$${(100 - cart.subtotal).toStringAsFixed(2)} more for free shipping!',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.warning,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

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
                fontSize: isBold ? 16 : 14,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                fontSize: isBold ? 18 : 14,
                color: valueColor,
              ),
            ),
          ],
        ),
      );
}

// ─── Checkout Bar ─────────────────────────────────────────────────────────────

class _CheckoutBar extends ConsumerWidget {
  const _CheckoutBar({required this.total});
  final double total;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.sm,
        AppSpacing.screenHorizontal,
        MediaQuery.paddingOf(context).bottom + AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.shadowDark : AppColors.shadowLight,
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          final authState = ref.read(authNotifierProvider);
          if (authState is! AuthAuthenticated) {
            GuestAuthPrompt.show(
              context,
              title: isAr ? 'تسجيل الدخول مطلوب للشراء' : 'Sign in required to Checkout',
              message: isAr
                  ? 'يرجى تسجيل الدخول أو إنشاء حساب لإتمام الطلب وتحديد عنوان التوصيل. ستبقى منتجاتك في السلة بأمان.'
                  : 'Please sign in or register to complete your order and specify your delivery address. Your cart items will remain saved.',
              icon: Icons.shopping_bag_outlined,
            );
            return;
          }
          context.push(AppRoutes.checkout);
        },
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_bag_outlined, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Text(
              isAr 
                  ? 'إتمام الدفع — ${total.toStringAsFixed(2)} ${context.l10n.general_sar}'
                  : 'Checkout — ${total.toStringAsFixed(2)} ${context.l10n.general_sar}',
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 16,
                fontWeight: FontWeight.w700,
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
  const _CouponSection({required this.cart});
  final CartEntity cart;

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
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final result = await ref.read(cartNotifierProvider.notifier).applyCoupon(
      code,
      isAr: isAr,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    result.fold(
      (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppColors.error,
          ),
        );
      },
      (coupon) {
        _controller.clear();
        FocusScope.of(context).unfocus();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isAr
                  ? 'تم تفعيل كود الخصم "${coupon.code}" بنجاح! 🎉'
                  : 'Coupon code "${coupon.code}" applied! 🎉',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final appliedCoupon = widget.cart.appliedCoupon;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: appliedCoupon != null
            ? Border.all(
                color: AppColors.success.withValues(alpha: 0.5),
                width: 1.5,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.shadowDark : AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: appliedCoupon != null
          ? Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_offer_rounded,
                    color: AppColors.success,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
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
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              appliedCoupon.formattedDiscount(
                                context.l10n.general_sar,
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isAr
                            ? 'تم تطبيق خصم بقيمة ${widget.cart.discountAmount.toStringAsFixed(2)} ${context.l10n.general_sar}'
                            : '${widget.cart.discountAmount.toStringAsFixed(2)} ${context.l10n.general_sar} discount applied',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.badge,
                    size: 20,
                  ),
                  tooltip: isAr ? 'إزالة الكوبون' : 'Remove Coupon',
                  onPressed: () {
                    ref.read(cartNotifierProvider.notifier).removeCoupon();
                  },
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
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: isAr
                          ? 'أدخل كود الخصم (مثال: SAVE20)'
                          : 'Promo Code (e.g. SAVE20)',
                      prefixIcon: const Icon(
                        Icons.confirmation_number_outlined,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.surfaceVariantDark.withValues(alpha: 0.5)
                          : AppColors.surfaceVariantLight.withValues(alpha: 0.5),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _applyCoupon,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isAr ? 'تطبيق' : 'Apply',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}
