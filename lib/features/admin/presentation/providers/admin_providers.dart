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

// Now handled by admin_products_notifier.dart


// ── Categories Provider ────────────────────────────────────────────────────

// Now handled by admin_categories_notifier.dart


// ── Orders Provider ────────────────────────────────────────────────────────

// Now handled by admin_orders_notifier.dart


// ── Users Provider ─────────────────────────────────────────────────────────

// Now handled by admin_users_notifier.dart

// ── Banners Provider ────────────────────────────────────────────────────────

final adminBannersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.read(adminDataSourceProvider).getAllBanners();
});

// ── Coupons Provider ────────────────────────────────────────────────────────

// Now handled by admin_coupons_notifier.dart

// ── Reviews Provider ───────────────────────────────────────────────────────

// Now handled by admin_reviews_notifier.dart

