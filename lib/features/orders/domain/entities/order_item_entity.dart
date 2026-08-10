import 'package:equatable/equatable.dart';

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
      ];
}
