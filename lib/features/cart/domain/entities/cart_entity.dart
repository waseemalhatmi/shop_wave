import '../../../products/domain/entities/product_entity.dart';

/// A single item in the shopping cart.
class CartItemEntity {
  const CartItemEntity({
    required this.product,
    required this.quantity,
    this.variantId,
    this.variantLabel,
    this.unitPrice,
  });

  final ProductEntity product;
  final int quantity;

  /// Optional product variant (size, color, etc.)
  final String? variantId;
  final String? variantLabel;

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

  CartItemEntity copyWith({int? quantity, String? variantId, String? variantLabel}) =>
      CartItemEntity(
        product: product,
        quantity: quantity ?? this.quantity,
        variantId: variantId ?? this.variantId,
        variantLabel: variantLabel ?? this.variantLabel,
        unitPrice: unitPrice,
      );
}

/// The full cart state — computed properties, no mutation logic here.
class CartEntity {
  const CartEntity({this.items = const []});

  final List<CartItemEntity> items;

  bool get isEmpty => items.isEmpty;
  int get totalItems => items.fold(0, (sum, i) => sum + i.quantity);
  double get subtotal => items.fold(0.0, (sum, i) => sum + i.subtotal);

  // Shipping: free over $100, else $9.99
  double get shippingCost => subtotal >= 100 ? 0 : 9.99;

  // Tax 8%
  double get tax => subtotal * 0.08;

  double get total => subtotal + shippingCost + tax;

  bool containsProduct(String productId) =>
      items.any((i) => i.product.id == productId);

  int quantityOf(String productId) => items
      .where((i) => i.product.id == productId)
      .fold(0, (sum, i) => sum + i.quantity);

  CartEntity copyWith({List<CartItemEntity>? items}) =>
      CartEntity(items: items ?? this.items);
}
