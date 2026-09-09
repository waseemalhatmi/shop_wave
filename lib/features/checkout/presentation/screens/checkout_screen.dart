import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../cart/domain/entities/cart_entity.dart';
import '../../../cart/presentation/providers/cart_notifier.dart';
import '../../../coupons/presentation/providers/coupons_providers.dart';
import '../../../orders/presentation/providers/orders_providers.dart';

/// Checkout screen — Phase 4.
/// Phase 5: Full Supabase order creation, payment integration.
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _currentStep = 0;
  final _addressFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  String _paymentMethod = 'card';
  bool _isPlacingOrder = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.transparent,
        elevation: 0,
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: _onStepContinue,
        onStepCancel: () {
          if (_currentStep > 0) setState(() => _currentStep--);
        },
        controlsBuilder: (context, details) => Padding(
          padding: const EdgeInsets.only(top: AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isPlacingOrder ? null : details.onStepContinue,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isPlacingOrder && _currentStep == 2
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _currentStep == 2 ? 'Place Order' : 'Continue',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              ),
              if (_currentStep > 0) ...[
                const SizedBox(width: AppSpacing.md),
                OutlinedButton(
                  onPressed: details.onStepCancel,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Back'),
                ),
              ],
            ],
          ),
        ),
        steps: [
          // ── Step 1: Shipping Address ──────────────────────────────
          Step(
            title: const Text(
              'Shipping Address',
              style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600),
            ),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            content: _AddressForm(
              formKey: _addressFormKey,
              nameController: _nameController,
              phoneController: _phoneController,
              addressController: _addressController,
              cityController: _cityController,
            ),
          ),

          // ── Step 2: Payment Method ───────────────────────────────
          Step(
            title: const Text(
              'Payment',
              style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600),
            ),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            content: _PaymentStep(
              selected: _paymentMethod,
              onChanged: (m) => setState(() => _paymentMethod = m),
            ),
          ),

          // ── Step 3: Order Summary ─────────────────────────────────
          Step(
            title: const Text(
              'Review Order',
              style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600),
            ),
            isActive: _currentStep >= 2,
            state: StepState.indexed,
            content: _OrderReview(cart: cart),
          ),
        ],
      ),
    );
  }

  void _onStepContinue() async {
    if (_currentStep == 0) {
      if (_addressFormKey.currentState?.validate() ?? false) {
        setState(() => _currentStep++);
      }
    } else if (_currentStep == 1) {
      setState(() => _currentStep++);
    } else {
      // Place order
      await _placeOrder();
    }
  }

  Future<void> _placeOrder() async {
    setState(() => _isPlacingOrder = true);
    
    final cart = ref.read(cartNotifierProvider);
    final items = cart.items.map((e) => {
      'product_id': e.product.id,
      'product_name_en': e.product.nameEn,
      'product_name_ar': e.product.nameAr,
      'product_image': e.product.primaryImageUrl,
      'quantity': e.quantity,
      'price_at_purchase': e.effectivePrice,
    }).toList();

    final address = {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'street': _addressController.text.trim(),
      'city': _cityController.text.trim(),
    };

    final repository = ref.read(ordersRepositoryProvider);
    final result = await repository.createOrder(
      paymentMethod: _paymentMethod,
      subtotal: cart.subtotal,
      shippingCost: cart.shippingCost,
      tax: cart.tax,
      total: cart.total,
      shippingAddress: address,
      items: items,
      couponId: cart.appliedCoupon?.id,
      discountAmount: cart.discountAmount,
    );

    if (!mounted) return;
    
    setState(() => _isPlacingOrder = false);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.error,
          ),
        );
      },
      (order) {
        if (cart.appliedCoupon != null) {
          ref
              .read(couponsRepositoryProvider)
              .recordCouponUsage(cart.appliedCoupon!.id);
        }
        ref.read(cartNotifierProvider.notifier).clearCart();
        // Force refresh orders list so the new order shows up immediately
        ref.invalidate(userOrdersProvider);
        context.go(AppRoutes.orderConfirmedPath(order.orderNumber));
      },
    );
  }
}

// ─── Address Form ─────────────────────────────────────────────────────────────

class _AddressForm extends StatelessWidget {
  const _AddressForm({
    required this.formKey,
    required this.nameController,
    required this.phoneController,
    required this.addressController,
    required this.cityController,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController cityController;

  @override
  Widget build(BuildContext context) => Form(
        key: formKey,
        child: Column(
          children: [
            _Field(
              controller: nameController,
              label: 'Full Name',
              icon: Icons.person_outline_rounded,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            _Field(
              controller: phoneController,
              label: 'Phone Number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            _Field(
              controller: addressController,
              label: 'Street Address',
              icon: Icons.location_on_outlined,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            _Field(
              controller: cityController,
              label: 'City',
              icon: Icons.location_city_outlined,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
          ],
        ),
      );
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(fontFamily: 'Outfit'),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
}

// ─── Payment Step ─────────────────────────────────────────────────────────────

class _PaymentStep extends StatelessWidget {
  const _PaymentStep({required this.selected, required this.onChanged});
  final String selected;
  final ValueChanged<String> onChanged;

  static const _methods = [
    ('card', 'Credit / Debit Card', Icons.credit_card_rounded),
    ('cod', 'Cash on Delivery', Icons.money_outlined),
    ('wallet', 'Digital Wallet', Icons.account_balance_wallet_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: _methods.map((m) {
        final (id, label, icon) = m;
        final isSelected = selected == id;
        return GestureDetector(
          onTap: () => onChanged(id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : AppColors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Order Review ─────────────────────────────────────────────────────────────

class _OrderReview extends StatelessWidget {
  const _OrderReview({required this.cart});
  final CartEntity cart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...cart.items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item.localizedName(Localizations.localeOf(context).languageCode),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                Text(
                  '${item.quantity}x \$${item.effectivePrice.toStringAsFixed(2)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: AppSpacing.xl),
        _ReviewRow(
          label: isAr ? 'المجموع الفرعي' : 'Subtotal',
          value: '${cart.subtotal.toStringAsFixed(2)} ${context.l10n.general_sar}',
        ),
        if (cart.discountAmount > 0)
          _ReviewRow(
            label: isAr
                ? 'الخصم (${cart.appliedCoupon?.code})'
                : 'Discount (${cart.appliedCoupon?.code})',
            value: '-${cart.discountAmount.toStringAsFixed(2)} ${context.l10n.general_sar}',
            color: AppColors.success,
            isBold: true,
          ),
        _ReviewRow(
          label: isAr ? 'الشحن' : 'Shipping',
          value: cart.shippingCost == 0
              ? (isAr ? 'مجاني 🎉' : 'Free 🎉')
              : '${cart.shippingCost.toStringAsFixed(2)} ${context.l10n.general_sar}',
        ),
        _ReviewRow(
          label: isAr ? 'الضريبة (8%)' : 'Tax (8%)',
          value: '${cart.tax.toStringAsFixed(2)} ${context.l10n.general_sar}',
        ),
        const Divider(height: AppSpacing.lg),
        _ReviewRow(
          label: isAr ? 'الإجمالي النهائي' : 'Total',
          value: '${cart.total.toStringAsFixed(2)} ${context.l10n.general_sar}',
          isBold: true,
          color: AppColors.primary,
        ),
      ],
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
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
                  fontSize: isBold ? 16 : 14,
                )),
            Text(value,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                  fontSize: isBold ? 18 : 14,
                  color: color,
                )),
          ],
        ),
      );
}
