import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/admin_remote_datasource.dart';

// ── Datasource Provider ────────────────────────────────────────────────────

final adminDataSourceProvider = Provider<AdminRemoteDataSource>((ref) {
  return AdminRemoteDataSource(Supabase.instance.client);
});

// ── Dashboard Providers ────────────────────────────────────────────────────

final adminDashboardStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return ref.read(adminDataSourceProvider).getDashboardStats();
});

final adminRecentOrdersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.read(adminDataSourceProvider).getRecentOrders();
});

final adminTopProductsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.read(adminDataSourceProvider).getTopProducts();
});

// ── Products Providers ─────────────────────────────────────────────────────

final adminProductsProvider = FutureProvider.family<List<Map<String, dynamic>>, Map<String, dynamic>>((ref, params) async {
  return ref.read(adminDataSourceProvider).getAllProducts(
    search: params['search'] as String?,
    categoryId: params['categoryId'] as String?,
    isActive: params['isActive'] as bool?,
  );
});

// ── Categories Provider ────────────────────────────────────────────────────

final adminCategoriesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.read(adminDataSourceProvider).getAllCategories();
});

// ── Orders Provider ────────────────────────────────────────────────────────

final adminOrdersProvider = FutureProvider.family<List<Map<String, dynamic>>, Map<String, dynamic>>((ref, params) async {
  return ref.read(adminDataSourceProvider).getAllOrders(
    status: params['status'] as String?,
    search: params['search'] as String?,
    page: params['page'] as int? ?? 0,
  );
});

// ── Users Provider ─────────────────────────────────────────────────────────

final adminUsersProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, search) async {
  return ref.read(adminDataSourceProvider).getAllUsers(search: search.isEmpty ? null : search);
});

// ── Banners Provider ───────────────────────────────────────────────────────

final adminBannersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.read(adminDataSourceProvider).getAllBanners();
});

// ── Coupons Provider ───────────────────────────────────────────────────────

final adminCouponsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.read(adminDataSourceProvider).getAllCoupons();
});

// ── Reviews Provider ───────────────────────────────────────────────────────

final adminReviewsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.read(adminDataSourceProvider).getAllReviews();
});
