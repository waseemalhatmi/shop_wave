import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/admin_remote_datasource.dart';
import 'admin_providers.dart';

// ── Role Filter Enum ─────────────────────────────────────────────────────────

enum UserRoleFilter { all, customer, admin }

// ── State ────────────────────────────────────────────────────────────────────

class AdminUsersState {
  final List<Map<String, dynamic>> users;
  final bool hasMore;
  final int page;
  final String search;
  final UserRoleFilter roleFilter;
  final bool isLoadingMore;

  const AdminUsersState({
    required this.users,
    required this.hasMore,
    required this.page,
    required this.search,
    required this.roleFilter,
    required this.isLoadingMore,
  });

  AdminUsersState copyWith({
    List<Map<String, dynamic>>? users,
    bool? hasMore,
    int? page,
    String? search,
    UserRoleFilter? roleFilter,
    bool? isLoadingMore,
  }) {
    return AdminUsersState(
      users: users ?? this.users,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      search: search ?? this.search,
      roleFilter: roleFilter ?? this.roleFilter,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

// ── Notifier ─────────────────────────────────────────────────────────────────

class AdminUsersNotifier extends AsyncNotifier<AdminUsersState> {
  static const int _pageSize = 20;
  Timer? _debounce;

  @override
  Future<AdminUsersState> build() async {
    ref.onDispose(() => _debounce?.cancel());
    final initial = await _fetchPage(0, '', UserRoleFilter.all);
    return AdminUsersState(
      users: initial,
      hasMore: initial.length == _pageSize,
      page: 0,
      search: '',
      roleFilter: UserRoleFilter.all,
      isLoadingMore: false,
    );
  }

  Future<List<Map<String, dynamic>>> _fetchPage(
    int page, String search, UserRoleFilter roleFilter,
  ) async {
    final ds = ref.read(adminDataSourceProvider);
    final role = switch (roleFilter) {
      UserRoleFilter.all => null,
      UserRoleFilter.customer => 'customer',
      UserRoleFilter.admin => 'admin',
    };
    return ds.getAllUsers(
      search: search.isNotEmpty ? search : null,
      role: role,
      page: page,
      pageSize: _pageSize,
    );
  }

  // ── Search (500ms Debounce) ──────────────────────────────────────────────

  void setSearch(String search) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final current = state.value;
      if (current?.search == search) return;
      state = const AsyncLoading();
      try {
        final st = current ?? AdminUsersState(users: [], hasMore: false, page: 0, search: search, roleFilter: UserRoleFilter.all, isLoadingMore: false);
        final result = await _fetchPage(0, search, st.roleFilter);
        state = AsyncData(st.copyWith(users: result, hasMore: result.length == _pageSize, page: 0, search: search));
      } catch (e, stack) {
        state = AsyncError(e, stack);
      }
    });
  }

  // ── Role Filter ──────────────────────────────────────────────────────────

  Future<void> setRoleFilter(UserRoleFilter roleFilter) async {
    final current = state.value;
    if (current?.roleFilter == roleFilter) return;
    state = const AsyncLoading();
    try {
      final st = current ?? AdminUsersState(users: [], hasMore: false, page: 0, search: '', roleFilter: roleFilter, isLoadingMore: false);
      final result = await _fetchPage(0, st.search, roleFilter);
      state = AsyncData(st.copyWith(users: result, hasMore: result.length == _pageSize, page: 0, roleFilter: roleFilter));
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  // ── Infinite Scroll ──────────────────────────────────────────────────────

  Future<void> loadMore() async {
    final val = state.value;
    if (val == null || !val.hasMore || val.isLoadingMore || state.isLoading) return;
    state = AsyncData(val.copyWith(isLoadingMore: true));
    try {
      final nextPage = val.page + 1;
      final more = await _fetchPage(nextPage, val.search, val.roleFilter);
      state = AsyncData(val.copyWith(
        users: [...val.users, ...more],
        hasMore: more.length == _pageSize,
        page: nextPage,
        isLoadingMore: false,
      ));
    } catch (_) {
      state = AsyncData(val.copyWith(isLoadingMore: false));
    }
  }

  // ── Optimistic Role Update ───────────────────────────────────────────────

  Future<void> updateUserRole(String userId, String newRole) async {
    final val = state.value;
    if (val == null) return;

    final index = val.users.indexWhere((u) => u['id'] == userId);
    if (index == -1) return;

    final oldUser = val.users[index];
    final updatedUser = Map<String, dynamic>.from(oldUser)..['role'] = newRole;

    // Optimistic update
    state = AsyncData(val.copyWith(
      users: List<Map<String, dynamic>>.from(val.users)..[index] = updatedUser,
    ));

    try {
      await ref.read(adminDataSourceProvider).updateUserRole(userId, newRole);
    } catch (e) {
      // Revert on failure
      state = AsyncData(val.copyWith(
        users: List<Map<String, dynamic>>.from(val.users)..[index] = oldUser,
      ));
      throw Exception('Failed to update user role');
    }
  }
}

// ── Provider ─────────────────────────────────────────────────────────────────

final adminUsersNotifierProvider =
    AsyncNotifierProvider<AdminUsersNotifier, AdminUsersState>(AdminUsersNotifier.new, isAutoDispose: true,);

