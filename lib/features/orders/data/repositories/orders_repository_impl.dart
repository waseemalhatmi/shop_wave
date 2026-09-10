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

  @override
  Stream<Either<Failure, OrderEntity>> streamOrderDetails(String orderId) {
    return remoteDataSource
        .streamOrderDetails(orderId)
        .map<Either<Failure, OrderEntity>>((model) => Right(model.toDomain()))
        .handleError((Object error) {
      if (error is ServerAppException) {
        return Left<Failure, OrderEntity>(ServerFailure(error.message));
      }
      return Left<Failure, OrderEntity>(ServerFailure(error.toString()));
    });
  }

  @override
  Stream<Either<Failure, List<OrderEntity>>> streamUserOrders() {
    return remoteDataSource
        .streamUserOrders()
        .map<Either<Failure, List<OrderEntity>>>(
            (models) => Right(models.map((m) => m.toDomain()).toList()))
        .handleError((Object error) {
      if (error is ServerAppException) {
        return Left<Failure, List<OrderEntity>>(ServerFailure(error.message));
      }
      return Left<Failure, List<OrderEntity>>(ServerFailure(error.toString()));
    });
  }

  @override
  Future<Either<Failure, OrderEntity>> cancelOrder({
    required String orderId,
    String? reason,
  }) async {
    try {
      final orderModel = await remoteDataSource.cancelOrder(
        orderId: orderId,
        reason: reason,
      );
      return Right(orderModel.toDomain());
    } on ServerAppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
