import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/orders_repository.dart';
import '../../data/datasources/orders_remote_data_source.dart';
import '../../data/repositories/orders_repository_impl.dart';
import 'dart:async';

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final remoteDataSource = OrdersRemoteDataSourceImpl(supabase);
  return OrdersRepositoryImpl(remoteDataSource);
});

class UserOrders extends AsyncNotifier<List<OrderEntity>> {
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

final userOrdersProvider = AsyncNotifierProvider<UserOrders, List<OrderEntity>>(() {
  return UserOrders();
});

final orderDetailsProvider = FutureProvider.family<OrderEntity, String>((ref, orderId) async {
  final repository = ref.watch(ordersRepositoryProvider);
  final result = await repository.getOrderDetails(orderId);
  return result.fold<OrderEntity>(
    (failure) => throw Exception(failure.message),
    (order) => order,
  );
});
