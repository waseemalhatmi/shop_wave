import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../addresses/domain/entities/address_entity.dart';
import '../../../addresses/presentation/providers/addresses_providers.dart';
import '../../../cart/domain/entities/cart_entity.dart';
import '../../../cart/presentation/providers/cart_notifier.dart';
import '../../../coupons/presentation/providers/coupons_providers.dart';
import '../../../orders/presentation/providers/orders_providers.dart';

/// Checkout screen — Professional, multi-step checkout flow.
/// Supports saved shipping addresses, instant 1-click address picker,
/// inline new address creation with auto-save to account, coupon discounts,
/// and full Supabase backend synchronization.
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _currentStep = 0;
  final _addressFormKey = GlobalKey<FormState>();

  // New address controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _buildingController = TextEditingController();

  String? _selectedAddressId;
  bool _isNewAddressMode = false;
  bool _saveNewAddressToAccount = true;

  String _paymentMethod = 'card';
  bool _isPlacingOrder = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _buildingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartNotifierProvider);
    final addressesAsync = ref.watch(userAddressesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final savedAddresses = addressesAsync.asData?.value ?? [];

    // Auto-select default or first address if none is selected yet
    if (!_isNewAddressMode && savedAddresses.isNotEmpty && _selectedAddressId == null) {
      final defaultAddr = savedAddresses.firstWhere(
        (a) => a.isDefault,
        orElse: () => savedAddresses.first,
      );
      _selectedAddressId = defaultAddr.id;
    }

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          isAr ? 'إتمام الطلب' : 'Checkout',
          style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.transparent,
        elevation: 0,
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () => _onStepContinue(savedAddresses),
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
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isPlacingOrder && _currentStep == 2
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _currentStep == 2
                              ? (isAr ? 'تأكيد وإرسال الطلب' : 'Place Order')
                              : (isAr ? 'متابعة' : 'Continue'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Outfit',
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              if (_currentStep > 0) ...[
                const SizedBox(width: AppSpacing.md),
                OutlinedButton(
                  onPressed: details.onStepCancel,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(80, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isAr ? 'رجوع' : 'Back',
                    style: const TextStyle(fontFamily: 'Outfit'),
                  ),
                ),
              ],
            ],
          ),
        ),
        steps: [
          // ── Step 1: Shipping Address ──────────────────────────────
          Step(
            title: Text(
              isAr ? 'عنوان التوصيل' : 'Shipping Address',
              style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600),
            ),
            subtitle: !_isNewAddressMode && _selectedAddressId != null && savedAddresses.isNotEmpty
                ? Text(
                    savedAddresses.firstWhere((a) => a.id == _selectedAddressId, orElse: () => savedAddresses.first).fullName,
                    style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                  )
                : null,
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            content: _buildShippingStepContent(isDark, isAr, addressesAsync, savedAddresses),
          ),

          // ── Step 2: Payment Method ───────────────────────────────
          Step(
            title: Text(
              isAr ? 'طريقة الدفع' : 'Payment',
              style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600),
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
            title: Text(
              isAr ? 'مراجعة الطلب' : 'Review Order',
              style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600),
            ),
            isActive: _currentStep >= 2,
            state: StepState.indexed,
            content: _OrderReview(
              cart: cart,
              shippingSummary: _getShippingSummaryText(savedAddresses, isAr),
              paymentMethodName: _getPaymentMethodLabel(_paymentMethod, isAr),
              onEditShipping: () => setState(() => _currentStep = 0),
              onEditPayment: () => setState(() => _currentStep = 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingStepContent(
    bool isDark,
    bool isAr,
    AsyncValue<List<AddressEntity>> addressesAsync,
    List<AddressEntity> savedAddresses,
  ) {
    if (addressesAsync.isLoading && savedAddresses.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (savedAddresses.isEmpty || _isNewAddressMode) {
      return _AddressForm(
        formKey: _addressFormKey,
        nameController: _nameController,
        phoneController: _phoneController,
        addressController: _addressController,
        cityController: _cityController,
        districtController: _districtController,
        buildingController: _buildingController,
        saveToAccount: _saveNewAddressToAccount,
        onSaveToAccountChanged: (val) => setState(() => _saveNewAddressToAccount = val ?? true),
        onBackToSaved: savedAddresses.isNotEmpty
            ? () => setState(() => _isNewAddressMode = false)
            : null,
      );
    }

    // List of saved addresses
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.local_shipping_outlined, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              isAr ? 'اختر عنوان التوصيل المحفوظ:' : 'Choose a saved delivery address:',
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ...savedAddresses.map((address) {
          final isSelected = address.id == _selectedAddressId;
          return _SavedAddressSelectCard(
            address: address,
            isSelected: isSelected,
            onTap: () => setState(() => _selectedAddressId = address.id),
          );
        }),
        const SizedBox(height: AppSpacing.xs),
        OutlinedButton.icon(
          onPressed: () => setState(() => _isNewAddressMode = true),
          icon: const Icon(Icons.add_location_alt_outlined, size: 18),
          label: Text(
            isAr ? '+ التوصيل إلى عنوان جديد' : '+ Deliver to a new address',
            style: const TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Outfit'),
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  void _onStepContinue(List<AddressEntity> savedAddresses) async {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    if (_currentStep == 0) {
      if (!_isNewAddressMode && savedAddresses.isNotEmpty) {
        if (_selectedAddressId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isAr
                    ? 'يرجى تحديد عنوان التوصيل للمتابعة'
                    : 'Please select a delivery address to continue',
              ),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }
        setState(() => _currentStep++);
      } else {
        if (_addressFormKey.currentState?.validate() ?? false) {
          if (_saveNewAddressToAccount) {
            final authUser = ref.read(supabaseClientProvider).auth.currentUser;
            if (authUser != null) {
              final newAddress = AddressEntity(
                id: '',
                userId: authUser.id,
                label: isAr ? 'عنوان التوصيل' : 'Delivery Address',
                fullName: _nameController.text.trim(),
                phone: _phoneController.text.trim(),
                country: 'SA',
                city: _cityController.text.trim(),
                district: _districtController.text.trim().isNotEmpty
                    ? _districtController.text.trim()
                    : null,
                street: _addressController.text.trim(),
                building: _buildingController.text.trim().isNotEmpty
                    ? _buildingController.text.trim()
                    : null,
                postalCode: null,
                isDefault: savedAddresses.isEmpty,
              );
              unawaited(ref.read(userAddressesProvider.notifier).addAddress(newAddress));
            }
          }
          setState(() => _currentStep++);
        }
      }
    } else if (_currentStep == 1) {
      setState(() => _currentStep++);
    } else {
      await _placeOrder(savedAddresses);
    }
  }

  Map<String, dynamic> _buildShippingAddressMap(List<AddressEntity> savedAddresses) {
    if (!_isNewAddressMode && _selectedAddressId != null && savedAddresses.isNotEmpty) {
      final selected = savedAddresses.firstWhere(
        (a) => a.id == _selectedAddressId,
        orElse: () => savedAddresses.first,
      );
      return {
        'name': selected.fullName,
        'phone': selected.phone,
        'street': selected.building != null && selected.building!.isNotEmpty
            ? '${selected.street}, ${selected.building}'
            : selected.street,
        'city': selected.district != null && selected.district!.isNotEmpty
            ? '${selected.city}, ${selected.district}'
            : selected.city,
        'country': selected.country,
      };
    }

    return {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'street': _buildingController.text.trim().isNotEmpty
          ? '${_addressController.text.trim()}, ${_buildingController.text.trim()}'
          : _addressController.text.trim(),
      'city': _districtController.text.trim().isNotEmpty
          ? '${_cityController.text.trim()}, ${_districtController.text.trim()}'
          : _cityController.text.trim(),
      'country': 'SA',
    };
  }

  String _getShippingSummaryText(List<AddressEntity> savedAddresses, bool isAr) {
    if (!_isNewAddressMode && _selectedAddressId != null && savedAddresses.isNotEmpty) {
      final selected = savedAddresses.firstWhere(
        (a) => a.id == _selectedAddressId,
        orElse: () => savedAddresses.first,
      );
      final parts = [
        selected.street,
        if (selected.building != null && selected.building!.isNotEmpty) selected.building,
        if (selected.district != null && selected.district!.isNotEmpty) selected.district,
        selected.city,
      ];
      return '${selected.fullName} — ${selected.phone}\n${parts.join(', ')}';
    }

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final parts = [
      _addressController.text.trim(),
      if (_buildingController.text.trim().isNotEmpty) _buildingController.text.trim(),
      if (_districtController.text.trim().isNotEmpty) _districtController.text.trim(),
      _cityController.text.trim(),
    ].where((s) => s.isNotEmpty).toList();

    if (name.isEmpty) return isAr ? 'لم يتم تحديد العنوان' : 'No address specified';
    return '$name — $phone\n${parts.join(', ')}';
  }

  String _getPaymentMethodLabel(String methodId, bool isAr) {
    switch (methodId) {
      case 'card':
        return isAr ? 'بطاقة مدى / بطاقة ائتمانية' : 'Credit / Mada Card';
      case 'apple_pay':
        return 'Apple Pay';
      case 'cod':
        return isAr ? 'الدفع نقدًا عند الاستلام' : 'Cash on Delivery';
      case 'wallet':
        return isAr ? 'المحفظة الرقمية' : 'Digital Wallet';
      default:
        return methodId;
    }
  }

  Future<void> _placeOrder(List<AddressEntity> savedAddresses) async {
    setState(() => _isPlacingOrder = true);

    final cart = ref.read(cartNotifierProvider);
    final items = cart.items.map((e) => {
      'product_id': e.product.id,
      'product_name_en': e.variantLabel != null
          ? '${e.product.nameEn} (${e.variantLabel})'
          : e.product.nameEn,
      'product_name_ar': e.variantLabel != null
          ? '${e.product.nameAr} (${e.variantLabel})'
          : e.product.nameAr,
      'product_image': e.product.primaryImageUrl,
      'quantity': e.quantity,
      'price_at_purchase': e.effectivePrice,
      'variant_id': e.variantId,
      'variant_label': e.variantLabel,
      'color': e.color,
      'size': e.size,
      'sku': e.sku ?? e.product.sku,
    }).toList();

    final address = _buildShippingAddressMap(savedAddresses);

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
        ref.invalidate(userOrdersProvider);
        context.go(AppRoutes.orderConfirmedPath(order.orderNumber));
      },
    );
  }
}

// ─── Saved Address Selection Card ─────────────────────────────────────────────

class _SavedAddressSelectCard extends StatelessWidget {
  const _SavedAddressSelectCard({
    required this.address,
    required this.isSelected,
    required this.onTap,
  });

  final AddressEntity address;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final label = address.label ?? (isAr ? 'عنوان' : 'Address');
    final isHome = label.toLowerCase().contains('home') || label.contains('منزل') || label.contains('بيت');
    final isWork = label.toLowerCase().contains('work') || label.contains('عمل') || label.contains('مكتب');

    final fullAddressDetails = [
      address.street,
      if (address.building != null && address.building!.isNotEmpty) address.building,
      if (address.district != null && address.district!.isNotEmpty) address.district,
      address.city,
    ].join(', ');

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.06)
              : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? AppColors.shadowDark : AppColors.shadowLight,
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: isSelected ? AppColors.primary : theme.colorScheme.onSurfaceVariant,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isHome
                                  ? Icons.home_rounded
                                  : isWork
                                      ? Icons.business_rounded
                                      : Icons.location_on_rounded,
                              size: 12,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              label.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (address.isDefault) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isAr ? 'الافتراضي' : 'DEFAULT',
                            style: const TextStyle(
                              color: AppColors.success,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    address.fullName,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: 13,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        address.phone,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_city_outlined,
                        size: 13,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          fullAddressDetails,
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
    required this.districtController,
    required this.buildingController,
    required this.saveToAccount,
    required this.onSaveToAccountChanged,
    this.onBackToSaved,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController cityController;
  final TextEditingController districtController;
  final TextEditingController buildingController;
  final bool saveToAccount;
  final ValueChanged<bool?> onSaveToAccountChanged;
  final VoidCallback? onBackToSaved;

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (onBackToSaved != null) ...[
            TextButton.icon(
              onPressed: onBackToSaved,
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: Text(
                isAr ? 'العودة للعناوين المحفوظة' : 'Back to saved addresses',
                style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Outfit'),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          _Field(
            controller: nameController,
            label: isAr ? 'الاسم الكامل' : 'Full Name',
            icon: Icons.person_outline_rounded,
            validator: (v) =>
                v == null || v.trim().isEmpty ? (isAr ? 'هذا الحقل مطلوب' : 'Required') : null,
          ),
          const SizedBox(height: AppSpacing.md),
          _Field(
            controller: phoneController,
            label: isAr ? 'رقم الهاتف' : 'Phone Number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (v) =>
                v == null || v.trim().isEmpty ? (isAr ? 'هذا الحقل مطلوب' : 'Required') : null,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _Field(
                  controller: cityController,
                  label: isAr ? 'المدينة' : 'City',
                  icon: Icons.location_city_outlined,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? (isAr ? 'مطلوب' : 'Required') : null,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _Field(
                  controller: districtController,
                  label: isAr ? 'الحي / المنطقة' : 'District',
                  icon: Icons.map_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _Field(
            controller: addressController,
            label: isAr ? 'اسم الشارع / العنوان' : 'Street Address',
            icon: Icons.location_on_outlined,
            validator: (v) =>
                v == null || v.trim().isEmpty ? (isAr ? 'هذا الحقل مطلوب' : 'Required') : null,
          ),
          const SizedBox(height: AppSpacing.md),
          _Field(
            controller: buildingController,
            label: isAr ? 'رقم المبنى / الشقة (اختياري)' : 'Building / Apt (Optional)',
            icon: Icons.apartment_outlined,
          ),
          const SizedBox(height: AppSpacing.sm),
          CheckboxListTile(
            value: saveToAccount,
            onChanged: onSaveToAccountChanged,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: AppColors.primary,
            title: Text(
              isAr
                  ? 'حفظ هذا العنوان في حسابي للطلبات المستقبلية'
                  : 'Save this address to my account for future orders',
              style: const TextStyle(
                fontSize: 13,
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
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
    ('card', 'Credit / Mada Card', 'بطاقة مدى / ائتمانية', Icons.credit_card_rounded),
    ('apple_pay', 'Apple Pay', 'أبل باي', Icons.apple_rounded),
    ('cod', 'Cash on Delivery', 'الدفع عند الاستلام', Icons.money_outlined),
    ('wallet', 'Digital Wallet', 'المحفظة الرقمية', Icons.account_balance_wallet_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Column(
      children: _methods.map((m) {
        final (id, labelEn, labelAr, icon) = m;
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
              borderRadius: BorderRadius.circular(14),
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
                  isAr ? labelAr : labelEn,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
  const _OrderReview({
    required this.cart,
    required this.shippingSummary,
    required this.paymentMethodName,
    required this.onEditShipping,
    required this.onEditPayment,
  });

  final CartEntity cart;
  final String shippingSummary;
  final String paymentMethodName;
  final VoidCallback onEditShipping;
  final VoidCallback onEditPayment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Shipping Address summary card
        _ReviewInfoCard(
          title: isAr ? 'عنوان التوصيل' : 'Delivery Address',
          icon: Icons.location_on_rounded,
          content: shippingSummary,
          onEdit: onEditShipping,
          editText: isAr ? 'تغيير' : 'Change',
        ),
        const SizedBox(height: AppSpacing.md),

        // Payment Method summary card
        _ReviewInfoCard(
          title: isAr ? 'طريقة الدفع' : 'Payment Method',
          icon: Icons.payment_rounded,
          content: paymentMethodName,
          onEdit: onEditPayment,
          editText: isAr ? 'تغيير' : 'Change',
        ),
        const SizedBox(height: AppSpacing.lg),

        // Cart Items List
        Text(
          isAr ? 'عناصر الطلب (${cart.totalItems})' : 'Order Items (${cart.totalItems})',
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...cart.items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: item.product.primaryImageUrl != null
                      ? Image.network(
                          item.product.primaryImageUrl!,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 44,
                            height: 44,
                            color: AppColors.surfaceVariantLight,
                            child: const Icon(Icons.image_outlined, size: 20),
                          ),
                        )
                      : Container(
                          width: 44,
                          height: 44,
                          color: AppColors.surfaceVariantLight,
                          child: const Icon(Icons.image_outlined, size: 20),
                        ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.localizedName(Localizations.localeOf(context).languageCode),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item.hasVariant)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            [
                              if (item.color != null) item.color!,
                              if (item.size != null) 'Size: ${item.size}',
                              if (item.sku != null) 'SKU: ${item.sku}',
                            ].join(' | '),
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      Text(
                        '${item.quantity} x ${item.effectivePrice.toStringAsFixed(2)} ${context.l10n.general_sar}',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${item.subtotal.toStringAsFixed(2)} ${context.l10n.general_sar}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: AppSpacing.xl),
        _ReviewRow(
          label: context.l10n.cart_subtotal,
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
          label: context.l10n.cart_shipping,
          value: cart.shippingCost == 0
              ? (isAr ? 'مجاني 🎉' : 'Free 🎉')
              : '${cart.shippingCost.toStringAsFixed(2)} ${context.l10n.general_sar}',
          color: cart.shippingCost == 0 ? AppColors.success : null,
        ),
        _ReviewRow(
          label: isAr ? 'الضريبة (8%)' : 'Tax (8%)',
          value: '${cart.tax.toStringAsFixed(2)} ${context.l10n.general_sar}',
        ),
        const Divider(height: AppSpacing.lg),
        _ReviewRow(
          label: context.l10n.cart_total,
          value: '${cart.total.toStringAsFixed(2)} ${context.l10n.general_sar}',
          isBold: true,
          color: AppColors.primary,
        ),
      ],
    );
  }
}

class _ReviewInfoCard extends StatelessWidget {
  const _ReviewInfoCard({
    required this.title,
    required this.icon,
    required this.content,
    required this.onEdit,
    required this.editText,
  });

  final String title;
  final IconData icon;
  final String content;
  final VoidCallback onEdit;
  final String editText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: onEdit,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Text(
                    editText,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
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
