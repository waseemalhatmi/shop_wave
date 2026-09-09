import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_remote_data_source.dart';
import '../models/order_model.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  const OrdersRepositoryImpl(this.remoteDataSource);

  final OrdersRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, List<OrderEntity>>> getUserOrders() async {
    try {
      final orderModels = await remoteDataSource.getUserOrders();
      return Right(orderModels.map((m) => m.toDomain()).toList());
    } on ServerAppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrderDetails(String orderId) async {
    try {
      final orderModel = await remoteDataSource.getOrderDetails(orderId);
      return Right(orderModel.toDomain());
    } on ServerAppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
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
  }) async {
    try {
      final orderModel = await remoteDataSource.createOrder(
        paymentMethod: paymentMethod,
        subtotal: subtotal,
        shippingCost: shippingCost,
        tax: tax,
        total: total,
        shippingAddress: shippingAddress,
        items: items,
        couponId: couponId,
        discountAmount: discountAmount,
      );
      return Right(orderModel.toDomain());
    } on ServerAppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
