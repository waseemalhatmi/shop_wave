// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/order_entity.dart';
import 'order_item_model.dart';

part 'order_model.freezed.dart';
part 'order_model.g.dart';

@freezed
class OrderModel with _$OrderModel {
  const factory OrderModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'order_number') required String orderNumber,
    required String status,
    @JsonKey(name: 'payment_method') required String paymentMethod,
    required double subtotal,
    @JsonKey(name: 'shipping_cost') required double shippingCost,
    required double tax,
    required double total,
    @JsonKey(name: 'shipping_address') required Map<String, dynamic> shippingAddress,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @Default([]) List<OrderItemModel> items,
  }) = _OrderModel;

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);
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
