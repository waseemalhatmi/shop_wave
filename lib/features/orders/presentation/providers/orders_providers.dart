import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/di/providers.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/orders_repository.dart';
import '../../data/datasources/orders_remote_data_source.dart';
import '../../data/repositories/orders_repository_impl.dart';

part 'orders_providers.g.dart';

@riverpod
OrdersRepository ordersRepository(OrdersRepositoryRef ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final remoteDataSource = OrdersRemoteDataSourceImpl(supabase);
  return OrdersRepositoryImpl(remoteDataSource);
}

@riverpod
class UserOrders extends _$UserOrders {
  @override
  Future<List<OrderEntity>> build() async {
    final repository = ref.watch(ordersRepositoryProvider);
    final result = await repository.getUserOrders();
    return result.fold<List<OrderEntity>>(
      (failure) => throw Exception(failure.message),
      (orders) => orders,
    );
  }

  /// Refresh the orders list.
  Future<void> refreshOrders() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(ordersRepositoryProvider);
      final result = await repository.getUserOrders();
      return result.fold<List<OrderEntity>>(
        (failure) => throw Exception(failure.message),
        (orders) => orders,
      );
    });
  }
}

@riverpod
Future<OrderEntity> orderDetails(OrderDetailsRef ref, String orderId) async {
  final repository = ref.watch(ordersRepositoryProvider);
  final result = await repository.getOrderDetails(orderId);
  return result.fold<OrderEntity>(
    (failure) => throw Exception(failure.message),
    (order) => order,
  );
}
