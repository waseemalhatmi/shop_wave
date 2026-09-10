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
    String? couponId,
    double discountAmount = 0.0,
  });

  /// Streams real-time updates for a single order from Supabase Realtime.
  Stream<Either<Failure, OrderEntity>> streamOrderDetails(String orderId);

  /// Streams real-time updates for all orders of current user.
  Stream<Either<Failure, List<OrderEntity>>> streamUserOrders();

  /// Cancels an active pending/processing order.
  Future<Either<Failure, OrderEntity>> cancelOrder({
    required String orderId,
    String? reason,
  });
}
