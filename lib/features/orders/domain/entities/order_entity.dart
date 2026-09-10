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
    this.cancellationReason,
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
  final String? cancellationReason;

  /// Whether customer can cancel this order (only pending or processing).
  bool get canCancel =>
      status == OrderStatus.pending || status == OrderStatus.processing;

  bool get isCancelled => status == OrderStatus.cancelled;
  bool get isDelivered => status == OrderStatus.delivered;

  /// Total count of individual physical items in this order.
  int get totalItemCount =>
      items.fold<int>(0, (sum, item) => sum + item.quantity);

  OrderEntity copyWith({
    String? id,
    String? userId,
    String? orderNumber,
    OrderStatus? status,
    String? paymentMethod,
    double? subtotal,
    double? shippingCost,
    double? tax,
    double? total,
    Map<String, dynamic>? shippingAddress,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<OrderItemEntity>? items,
    double? discountAmount,
    String? couponId,
    String? cancellationReason,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      orderNumber: orderNumber ?? this.orderNumber,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      subtotal: subtotal ?? this.subtotal,
      shippingCost: shippingCost ?? this.shippingCost,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
      discountAmount: discountAmount ?? this.discountAmount,
      couponId: couponId ?? this.couponId,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }

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
        cancellationReason,
      ];
}
