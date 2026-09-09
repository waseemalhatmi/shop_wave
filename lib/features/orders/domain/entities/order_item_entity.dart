import 'package:equatable/equatable.dart';

/// Domain entity representing an individual item within an order,
/// including variant tracking (color, size, SKU) and immutable purchase price.
class OrderItemEntity extends Equatable {
  const OrderItemEntity({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productNameEn,
    required this.productNameAr,
    required this.productImage,
    required this.quantity,
    required this.priceAtPurchase,
    required this.createdAt,
    this.variantId,
    this.variantLabel,
    this.color,
    this.size,
    this.sku,
  });

  final String id;
  final String orderId;
  final String productId;
  final String productNameEn;
  final String productNameAr;
  final String productImage;
  final int quantity;
  final double priceAtPurchase;
  final DateTime createdAt;

  /// Product variant tracking properties
  final String? variantId;
  final String? variantLabel;
  final String? color;
  final String? size;
  final String? sku;

  /// Returns true if this item represents a specific product variant
  bool get hasVariant =>
      (variantLabel != null && variantLabel!.isNotEmpty) ||
      (color != null && color!.isNotEmpty) ||
      (size != null && size!.isNotEmpty);

  /// Formatted variant description for display (e.g. "Color: Black / Size: L")
  String? get displayVariant {
    if (variantLabel != null && variantLabel!.isNotEmpty) {
      return variantLabel;
    }
    final parts = [
      if (color != null && color!.isNotEmpty) color!,
      if (size != null && size!.isNotEmpty) size!,
    ];
    return parts.isEmpty ? null : parts.join(' / ');
  }

  @override
  List<Object?> get props => [
        id,
        orderId,
        productId,
        productNameEn,
        productNameAr,
        productImage,
        quantity,
        priceAtPurchase,
        createdAt,
        variantId,
        variantLabel,
        color,
        size,
        sku,
      ];
}
