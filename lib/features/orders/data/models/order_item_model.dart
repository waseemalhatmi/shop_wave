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
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      productId: json['product_id'] as String,
      productNameEn: json['product_name_en'] as String,
      productNameAr: json['product_name_ar'] as String,
      productImage: json['product_image'] as String,
      quantity: json['quantity'] as int,
      priceAtPurchase: (json['price_at_purchase'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
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
      );
}
