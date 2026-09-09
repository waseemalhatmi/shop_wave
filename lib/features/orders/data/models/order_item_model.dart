import '../../domain/entities/order_item_entity.dart';

class OrderItemModel {
  final String id;
  final String orderId;
  final String productId;
  final String productNameEn;
  final String productNameAr;
  final String productImage;
  final int quantity;
  final double priceAtPurchase;
  final DateTime createdAt;
  final String? variantId;
  final String? variantLabel;
  final String? color;
  final String? size;
  final String? sku;

  const OrderItemModel({
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

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    String? variantLabel = json['variant_label'] as String?;
    String? color = json['color'] as String?;
    String? size = json['size'] as String?;
    final nameEn = json['product_name_en'] as String;

    // Fallback extraction from product name if stored as "Name (Color / Size)"
    if (variantLabel == null && nameEn.contains('(') && nameEn.contains(')')) {
      final startIndex = nameEn.lastIndexOf('(');
      final endIndex = nameEn.lastIndexOf(')');
      if (endIndex > startIndex) {
        variantLabel = nameEn.substring(startIndex + 1, endIndex).trim();
      }
    }

    return OrderItemModel(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      productId: json['product_id'] as String,
      productNameEn: nameEn,
      productNameAr: json['product_name_ar'] as String,
      productImage: json['product_image'] as String,
      quantity: json['quantity'] as int,
      priceAtPurchase: (json['price_at_purchase'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      variantId: json['variant_id'] as String?,
      variantLabel: variantLabel,
      color: color,
      size: size,
      sku: json['sku'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_name_en': productNameEn,
      'product_name_ar': productNameAr,
      'product_image': productImage,
      'quantity': quantity,
      'price_at_purchase': priceAtPurchase,
      'created_at': createdAt.toIso8601String(),
      if (variantId != null) 'variant_id': variantId,
      if (variantLabel != null) 'variant_label': variantLabel,
      if (color != null) 'color': color,
      if (size != null) 'size': size,
      if (sku != null) 'sku': sku,
    };
  }
}

extension OrderItemModelX on OrderItemModel {
  OrderItemEntity toDomain() => OrderItemEntity(
        id: id,
        orderId: orderId,
        productId: productId,
        productNameEn: productNameEn,
        productNameAr: productNameAr,
        productImage: productImage,
        quantity: quantity,
        priceAtPurchase: priceAtPurchase,
        createdAt: createdAt,
        variantId: variantId,
        variantLabel: variantLabel,
        color: color,
        size: size,
        sku: sku,
      );
}
