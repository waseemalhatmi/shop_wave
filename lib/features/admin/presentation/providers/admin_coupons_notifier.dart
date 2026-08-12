import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/admin_remote_datasource.dart';
import 'admin_providers.dart';

// ── Coupon Status Filter ─────────────────────────────────────────────────────

enum CouponStatusFilter { all, active, inactive, expired }

// ── State ────────────────────────────────────────────────────────────────────

class AdminCouponsState {
  final List<Map<String, dynamic>> coupons;
  final CouponStatusFilter filter;

  const AdminCouponsState({required this.coupons, required this.filter});

  AdminCouponsState copyWith({
    List<Map<String, dynamic>>? coupons,
    CouponStatusFilter? filter,
  }) {
    return AdminCouponsState(
      coupons: coupons ?? this.coupons,
      filter: filter ?? this.filter,
    );
  }

  /// Returns filtered coupons based on active filter (client-side for small dataset)
  List<Map<String, dynamic>> get filteredCoupons {
    return switch (filter) {
      CouponStatusFilter.all => coupons,
      CouponStatusFilter.active => coupons.where((c) => c['is_active'] == true && !_isExpired(c)).toList(),
      CouponStatusFilter.inactive => coupons.where((c) => c['is_active'] == false).toList(),
      CouponStatusFilter.expired => coupons.where(_isExpired).toList(),
    };
  }

  static bool _isExpired(Map<String, dynamic> c) {
    final expiresAt = c['expires_at'];
    if (expiresAt == null) return false;
    final dt = DateTime.tryParse(expiresAt.toString());
    return dt != null && dt.isBefore(DateTime.now());
  }
}

// ── Notifier ─────────────────────────────────────────────────────────────────

class AdminCouponsNotifier extends AsyncNotifier<AdminCouponsState> {
  @override
  Future<AdminCouponsState> build() async {
    final coupons = await ref.read(adminDataSourceProvider).getAllCoupons();
    return AdminCouponsState(coupons: coupons, filter: CouponStatusFilter.all);
  }

  // ── Filter (client-side, instant) ─────────────────────────────────────────

  void setFilter(CouponStatusFilter filter) {
    final val = state.value;
    if (val == null) return;
    state = AsyncData(val.copyWith(filter: filter));
  }

  // ── Create ─────────────────────────────────────────────────────────────────

  Future<void> createCoupon(Map<String, dynamic> data) async {
    final val = state.value;
    if (val == null) return;

    // Show loading on current state
    final created = await ref.read(adminDataSourceProvider).createCoupon(data);
    if (created != null) {
      state = AsyncData(val.copyWith(coupons: [created, ...val.coupons]));
    } else {
      // Fallback: full refresh
      await _refresh();
    }
  }

  // ── Optimistic Toggle Active ───────────────────────────────────────────────

  Future<void> toggleActive(String id, bool isActive) async {
    final val = state.value;
    if (val == null) return;

    final index = val.coupons.indexWhere((c) => c['id'] == id);
    if (index == -1) return;

    final oldCoupon = val.coupons[index];
    final updated = Map<String, dynamic>.from(oldCoupon)..['is_active'] = isActive;

    state = AsyncData(val.copyWith(
      coupons: List<Map<String, dynamic>>.from(val.coupons)..[index] = updated,
    ));

    try {
      await ref.read(adminDataSourceProvider).updateCoupon(id, {'is_active': isActive});
    } catch (e) {
      // Revert
      state = AsyncData(val.copyWith(
        coupons: List<Map<String, dynamic>>.from(val.coupons)..[index] = oldCoupon,
      ));
      throw Exception('Failed to toggle coupon');
    }
  }

  // ── Update ─────────────────────────────────────────────────────────────────

  Future<void> updateCoupon(String id, Map<String, dynamic> data) async {
    final val = state.value;
    if (val == null) return;

    final index = val.coupons.indexWhere((c) => c['id'] == id);
    if (index == -1) return;

    final oldCoupon = val.coupons[index];
    final updated = Map<String, dynamic>.from(oldCoupon)..addAll(data);

    // Optimistic
    state = AsyncData(val.copyWith(
      coupons: List<Map<String, dynamic>>.from(val.coupons)..[index] = updated,
    ));

    try {
      await ref.read(adminDataSourceProvider).updateCoupon(id, data);
    } catch (e) {
      state = AsyncData(val.copyWith(
        coupons: List<Map<String, dynamic>>.from(val.coupons)..[index] = oldCoupon,
      ));
      throw Exception('Failed to update coupon');
    }
  }

  // ── Optimistic Delete ──────────────────────────────────────────────────────

  Future<void> deleteCoupon(String id) async {
    final val = state.value;
    if (val == null) return;

    final index = val.coupons.indexWhere((c) => c['id'] == id);
    if (index == -1) return;

    final oldCoupon = val.coupons[index];
    state = AsyncData(val.copyWith(
      coupons: List<Map<String, dynamic>>.from(val.coupons)..removeAt(index),
    ));

    try {
      await ref.read(adminDataSourceProvider).deleteCoupon(id);
    } catch (e) {
      state = AsyncData(val.copyWith(
        coupons: List<Map<String, dynamic>>.from(val.coupons)..insert(index, oldCoupon),
      ));
      throw Exception('Failed to delete coupon');
    }
  }

  // ── Refresh ────────────────────────────────────────────────────────────────

  Future<void> _refresh() async {
    final val = state.value;
    final coupons = await ref.read(adminDataSourceProvider).getAllCoupons();
    state = AsyncData(AdminCouponsState(
      coupons: coupons,
      filter: val?.filter ?? CouponStatusFilter.all,
    ));
  }
}

// ── Provider ─────────────────────────────────────────────────────────────────

final adminCouponsNotifierProvider =
    AsyncNotifierProvider<AdminCouponsNotifier, AdminCouponsState>(AdminCouponsNotifier.new, isAutoDispose: true,);

