import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/admin_remote_datasource.dart';
import 'admin_providers.dart';

// ── Order Status Constants ──────────────────────────────────────────────────

enum OrderDateFilter { all, today, yesterday, last7Days, last30Days }

// ── State ───────────────────────────────────────────────────────────────────

class AdminOrdersState {
  final List<Map<String, dynamic>> orders;
  final bool hasMore;
  final int page;
  final String search;
  final String status; // 'all' | 'pending' | 'processing' | 'shipped' | 'delivered' | 'cancelled'
  final OrderDateFilter dateFilter;
  final bool isLoadingMore;

  const AdminOrdersState({
    required this.orders,
    required this.hasMore,
    required this.page,
    required this.search,
    required this.status,
    required this.dateFilter,
    required this.isLoadingMore,
  });

  AdminOrdersState copyWith({
    List<Map<String, dynamic>>? orders,
    bool? hasMore,
    int? page,
    String? search,
    String? status,
    OrderDateFilter? dateFilter,
    bool? isLoadingMore,
  }) {
    return AdminOrdersState(
      orders: orders ?? this.orders,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      search: search ?? this.search,
      status: status ?? this.status,
      dateFilter: dateFilter ?? this.dateFilter,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

// ── Helper: Date Range from Filter ─────────────────────────────────────────

({DateTime? from, DateTime? to}) _dateRange(OrderDateFilter filter) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return switch (filter) {
    OrderDateFilter.all => (from: null, to: null),
    OrderDateFilter.today => (from: today, to: null),
    OrderDateFilter.yesterday => (from: today.subtract(const Duration(days: 1)), to: today),
    OrderDateFilter.last7Days => (from: today.subtract(const Duration(days: 7)), to: null),
    OrderDateFilter.last30Days => (from: today.subtract(const Duration(days: 30)), to: null),
  };
}

// ── Notifier ────────────────────────────────────────────────────────────────

class AdminOrdersNotifier extends AsyncNotifier<AdminOrdersState> {
  static const int _pageSize = 20;
  Timer? _debounce;

  @override
  Future<AdminOrdersState> build() async {
    ref.onDispose(() => _debounce?.cancel());
    final initial = await _fetchPage(0, '', 'all', OrderDateFilter.all);
    return AdminOrdersState(
      orders: initial,
      hasMore: initial.length == _pageSize,
      page: 0,
      search: '',
      status: 'all',
      dateFilter: OrderDateFilter.all,
      isLoadingMore: false,
    );
  }

  Future<List<Map<String, dynamic>>> _fetchPage(
    int page, String search, String status, OrderDateFilter dateFilter,
  ) async {
    final ds = ref.read(adminDataSourceProvider);
    final range = _dateRange(dateFilter);
    return ds.getAllOrders(
      status: status,
      search: search.isNotEmpty ? search : null,
      dateFrom: range.from,
      dateTo: range.to,
      page: page,
      pageSize: _pageSize,
    );
  }

  // ── Search with 500ms Debounce ─────────────────────────────────────────

  void setSearch(String search) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final current = state.value;
      if (current?.search == search) return;
      state = const AsyncLoading();
      try {
        final st = current ?? AdminOrdersState(orders: [], hasMore: false, page: 0, search: search, status: 'all', dateFilter: OrderDateFilter.all, isLoadingMore: false);
        final result = await _fetchPage(0, search, st.status, st.dateFilter);
        state = AsyncData(st.copyWith(orders: result, hasMore: result.length == _pageSize, page: 0, search: search));
      } catch (e, stack) {
        state = AsyncError(e, stack);
      }
    });
  }

  // ── Status Filter ──────────────────────────────────────────────────────

  Future<void> setStatus(String status) async {
    final current = state.value;
    if (current?.status == status) return;
    state = const AsyncLoading();
    try {
      final st = current ?? AdminOrdersState(orders: [], hasMore: false, page: 0, search: '', status: status, dateFilter: OrderDateFilter.all, isLoadingMore: false);
      final result = await _fetchPage(0, st.search, status, st.dateFilter);
      state = AsyncData(st.copyWith(orders: result, hasMore: result.length == _pageSize, page: 0, status: status));
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  // ── Date Filter ────────────────────────────────────────────────────────

  Future<void> setDateFilter(OrderDateFilter dateFilter) async {
    final current = state.value;
    if (current?.dateFilter == dateFilter) return;
    state = const AsyncLoading();
    try {
      final st = current ?? AdminOrdersState(orders: [], hasMore: false, page: 0, search: '', status: 'all', dateFilter: dateFilter, isLoadingMore: false);
      final result = await _fetchPage(0, st.search, st.status, dateFilter);
      state = AsyncData(st.copyWith(orders: result, hasMore: result.length == _pageSize, page: 0, dateFilter: dateFilter));
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  // ── Infinite Scroll ────────────────────────────────────────────────────

  Future<void> loadMore() async {
    final val = state.value;
    if (val == null || !val.hasMore || val.isLoadingMore || state.isLoading) return;

    state = AsyncData(val.copyWith(isLoadingMore: true));
    try {
      final nextPage = val.page + 1;
      final more = await _fetchPage(nextPage, val.search, val.status, val.dateFilter);
      state = AsyncData(val.copyWith(
        orders: [...val.orders, ...more],
        hasMore: more.length == _pageSize,
        page: nextPage,
        isLoadingMore: false,
      ));
    } catch (_) {
      state = AsyncData(val.copyWith(isLoadingMore: false));
    }
  }

  // ── Optimistic Update Order Status ────────────────────────────────────

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    final val = state.value;
    if (val == null) return;

    final index = val.orders.indexWhere((o) => o['id'] == orderId);
    if (index == -1) return;

    final oldOrder = val.orders[index];
    final updatedOrder = Map<String, dynamic>.from(oldOrder)..['status'] = newStatus;

    // Optimistic update
    state = AsyncData(val.copyWith(
      orders: List<Map<String, dynamic>>.from(val.orders)..[index] = updatedOrder,
    ));

    try {
      await ref.read(adminDataSourceProvider).updateOrderStatus(orderId, newStatus);
    } catch (e) {
      // Revert on failure
      state = AsyncData(val.copyWith(
        orders: List<Map<String, dynamic>>.from(val.orders)..[index] = oldOrder,
      ));
      throw Exception('Failed to update order status');
    }
  }
}

// ── Provider ────────────────────────────────────────────────────────────────

final adminOrdersNotifierProvider =
    AsyncNotifierProvider<AdminOrdersNotifier, AdminOrdersState>(AdminOrdersNotifier.new, isAutoDispose: true,);

