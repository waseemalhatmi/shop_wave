import '../../../coupons/domain/entities/coupon_entity.dart';
import '../../../products/domain/entities/product_entity.dart';

/// A single item in the shopping cart.
class CartItemEntity {
  const CartItemEntity({
    required this.product,
    required this.quantity,
    this.variantId,
    this.variantLabel,
    this.unitPrice,
    this.color,
    this.size,
    this.sku,
  });

  final ProductEntity product;
  final int quantity;

  /// Optional product variant (size, color, etc.)
  final String? variantId;
  final String? variantLabel;
  final String? color;
  final String? size;
  final String? sku;

  /// Override price for variant — falls back to product.finalPrice
  final double? unitPrice;

  double get effectivePrice => unitPrice ?? product.finalPrice;
  double get subtotal => effectivePrice * quantity;

  String get displayName =>
      variantLabel != null ? '${product.nameEn} — $variantLabel' : product.nameEn;

  String localizedName(String langCode) =>
      variantLabel != null
          ? '${product.localizedName(langCode)} — $variantLabel'
          : product.localizedName(langCode);

  bool get hasVariant =>
      (variantLabel != null && variantLabel!.isNotEmpty) ||
      (color != null && color!.isNotEmpty) ||
      (size != null && size!.isNotEmpty);

  CartItemEntity copyWith({
    int? quantity,
    String? variantId,
    String? variantLabel,
    String? color,
    String? size,
    String? sku,
    double? unitPrice,
  }) =>
      CartItemEntity(
        product: product,
        quantity: quantity ?? this.quantity,
        variantId: variantId ?? this.variantId,
        variantLabel: variantLabel ?? this.variantLabel,
        color: color ?? this.color,
        size: size ?? this.size,
        sku: sku ?? this.sku,
        unitPrice: unitPrice ?? this.unitPrice,
      );
}

/// The full cart state — computed properties, no mutation logic here.
class CartEntity {
  const CartEntity({
    this.items = const [],
    this.appliedCoupon,
  });

  final List<CartItemEntity> items;
  final CouponEntity? appliedCoupon;

  bool get isEmpty => items.isEmpty;
  int get totalItems => items.fold(0, (sum, i) => sum + i.quantity);
  double get subtotal => items.fold(0.0, (sum, i) => sum + i.subtotal);

  double get discountAmount =>
      appliedCoupon != null ? appliedCoupon!.calculateDiscount(subtotal) : 0.0;

  double get subtotalAfterDiscount =>
      (subtotal - discountAmount).clamp(0.0, double.infinity);

  // Shipping: free over $100, else $9.99
  double get shippingCost =>
      items.isEmpty || subtotalAfterDiscount >= 100 ? 0 : 9.99;

  // Tax 8%
  double get tax => subtotalAfterDiscount * 0.08;

  double get total => subtotalAfterDiscount + shippingCost + tax;

  bool containsProduct(String productId) =>
      items.any((i) => i.product.id == productId);

  int quantityOf(String productId) => items
      .where((i) => i.product.id == productId)
      .fold(0, (sum, i) => sum + i.quantity);

  CartEntity copyWith({
    List<CartItemEntity>? items,
    CouponEntity? appliedCoupon,
    bool clearCoupon = false,
  }) =>
      CartEntity(
        items: items ?? this.items,
        appliedCoupon:
            clearCoupon ? null : (appliedCoupon ?? this.appliedCoupon),
      );
}
