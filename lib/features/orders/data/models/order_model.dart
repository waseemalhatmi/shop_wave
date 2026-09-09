import '../../domain/entities/order_entity.dart';
import 'order_item_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final String orderNumber;
  final String status;
  final String paymentMethod;
  final double subtotal;
  final double shippingCost;
  final double tax;
  final double total;
  final Map<String, dynamic> shippingAddress;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItemModel> items;
  final double discountAmount;
  final String? couponId;

  const OrderModel({
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

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      orderNumber: json['order_number'] as String,
      status: json['status'] as String,
      paymentMethod: json['payment_method'] as String,
      subtotal: (json['subtotal'] as num).toDouble(),
      shippingCost: (json['shipping_cost'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      shippingAddress: json['shipping_address'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      couponId: json['coupon_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'order_number': orderNumber,
      'status': status,
      'payment_method': paymentMethod,
      'subtotal': subtotal,
      'shipping_cost': shippingCost,
      'tax': tax,
      'total': total,
      'shipping_address': shippingAddress,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'items': items.map((e) => e.toJson()).toList(),
      'discount_amount': discountAmount,
      if (couponId != null) 'coupon_id': couponId,
    };
  }
}

extension OrderModelX on OrderModel {
  OrderEntity toDomain() => OrderEntity(
        id: id,
        userId: userId,
        orderNumber: orderNumber,
        status: _mapStatus(status),
        paymentMethod: paymentMethod,
        subtotal: subtotal,
        shippingCost: shippingCost,
        tax: tax,
        total: total,
        shippingAddress: shippingAddress,
        createdAt: createdAt,
        updatedAt: updatedAt,
        items: items.map((i) => i.toDomain()).toList(),
        discountAmount: discountAmount,
        couponId: couponId,
      );

  OrderStatus _mapStatus(String s) {
    switch (s) {
      case 'processing':
        return OrderStatus.processing;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'pending':
      default:
        return OrderStatus.pending;
    }
  }
}
