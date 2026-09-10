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

  /// Cancels an active order and refreshes state
  Future<bool> cancelOrder(String orderId, {String? reason}) async {
    final repository = ref.read(ordersRepositoryProvider);
    final result = await repository.cancelOrder(orderId: orderId, reason: reason);
    return result.fold(
      (failure) => false,
      (cancelledOrder) {
        state = state.whenData((orders) {
          return orders.map((o) => o.id == orderId ? cancelledOrder : o).toList();
        });
        ref.invalidate(orderDetailsProvider(orderId));
        ref.invalidate(orderDetailsStreamProvider(orderId));
        return true;
      },
    );
  }
}

final userOrdersProvider = AsyncNotifierProvider<UserOrders, List<OrderEntity>>(() {
  return UserOrders();
});

/// Direct FutureProvider for initial / fallback loading
final orderDetailsProvider = FutureProvider.family<OrderEntity, String>((ref, orderId) async {
  final repository = ref.watch(ordersRepositoryProvider);
  final result = await repository.getOrderDetails(orderId);
  return result.fold<OrderEntity>(
    (failure) => throw Exception(failure.message),
    (order) => order,
  );
});

/// Live Supabase Realtime Stream for real-time order status tracking
final orderDetailsStreamProvider =
    StreamProvider.autoDispose.family<OrderEntity, String>((ref, orderId) {
  final repository = ref.watch(ordersRepositoryProvider);
  return repository.streamOrderDetails(orderId).map((result) {
    return result.fold(
      (failure) => throw Exception(failure.message),
      (order) => order,
    );
  });
});

// ─── Status Filter Tab State ──────────────────────────────────────────────────

enum OrderStatusFilter {
  all,
  active,
  completed,
  cancelled;

  String label(bool isAr) {
    switch (this) {
      case OrderStatusFilter.all:
        return isAr ? 'الكل' : 'All';
      case OrderStatusFilter.active:
        return isAr ? 'النشطة' : 'Active';
      case OrderStatusFilter.completed:
        return isAr ? 'المكتملة' : 'Completed';
      case OrderStatusFilter.cancelled:
        return isAr ? 'الملغاة' : 'Cancelled';
    }
  }
}

class OrderFilterNotifier extends Notifier<OrderStatusFilter> {
  @override
  OrderStatusFilter build() => OrderStatusFilter.all;

  void setFilter(OrderStatusFilter filter) => state = filter;
}

final orderStatusFilterProvider =
    NotifierProvider<OrderFilterNotifier, OrderStatusFilter>(
  OrderFilterNotifier.new,
);

final filteredUserOrdersProvider = Provider<AsyncValue<List<OrderEntity>>>((ref) {
  final ordersAsync = ref.watch(userOrdersProvider);
  final filter = ref.watch(orderStatusFilterProvider);

  return ordersAsync.whenData((orders) {
    switch (filter) {
      case OrderStatusFilter.all:
        return orders;
      case OrderStatusFilter.active:
        return orders
            .where((o) =>
                o.status == OrderStatus.pending ||
                o.status == OrderStatus.processing ||
                o.status == OrderStatus.shipped)
            .toList();
      case OrderStatusFilter.completed:
        return orders.where((o) => o.status == OrderStatus.delivered).toList();
      case OrderStatusFilter.cancelled:
        return orders.where((o) => o.status == OrderStatus.cancelled).toList();
    }
  });
});
