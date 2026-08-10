import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/order_entity.dart';

abstract class OrdersRepository {
  /// Fetches a list of orders for the current user.
  Future<Either<Failure, List<OrderEntity>>> getUserOrders();

  /// Fetches details for a specific order.
  Future<Either<Failure, OrderEntity>> getOrderDetails(String orderId);

  /// Creates a new order.
  Future<Either<Failure, OrderEntity>> createOrder({
    required String paymentMethod,
    required double subtotal,
    required double shippingCost,
    required double tax,
    required double total,
    required Map<String, dynamic> shippingAddress,
    required List<Map<String, dynamic>> items,
  });
}
