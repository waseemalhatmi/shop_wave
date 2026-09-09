import 'package:equatable/equatable.dart';
import 'order_item_entity.dart';

enum OrderStatus { pending, processing, shipped, delivered, cancelled }

class OrderEntity extends Equatable {
  const OrderEntity({
    required this.id,
    required this.userId,
    required this.orderNumber,
    required this.status,
    required this.paymentMethod,
    required this.subtotal,
    required this.shippingCost,
    required this.tax,
    required this.total,
    required this.shippingAddress,
    required this.createdAt,
    required this.updatedAt,
    this.items = const [],
    this.discountAmount = 0.0,
    this.couponId,
  });

  final String id;
  final String userId;
  final String orderNumber;
  final OrderStatus status;
  final String paymentMethod;
  final double subtotal;
  final double shippingCost;
  final double tax;
  final double total;
  final Map<String, dynamic> shippingAddress;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItemEntity> items;
  final double discountAmount;
  final String? couponId;

  @override
  List<Object?> get props => [
        id,
        userId,
        orderNumber,
        status,
        paymentMethod,
        subtotal,
        shippingCost,
        tax,
        total,
        shippingAddress,
        createdAt,
        updatedAt,
        items,
        discountAmount,
        couponId,
      ];
}
