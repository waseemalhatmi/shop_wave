import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/app_logger.dart';

/// Remote data source for all admin panel operations.
class AdminRemoteDataSource {
  const AdminRemoteDataSource(this._supabase);
  final SupabaseClient _supabase;

  // ── Dashboard Stats ────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final results = await Future.wait([
        _supabase.from('orders').select('total, status, created_at'),
        _supabase.from('profiles').select('id, created_at'),
        _supabase.from('products').select('id').eq('is_active', true),
      ]);

      final orders = results[0] as List;
      final users = results[1] as List;
      final products = results[2] as List;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final last7 = today.subtract(const Duration(days: 7));
      final last30 = today.subtract(const Duration(days: 30));

      double totalRevenue = 0;
      double revenueToday = 0;
      double revenue7Days = 0;
      double revenue30Days = 0;
      int pendingOrders = 0;
      int ordersToday = 0;

      for (final o in orders) {
        final map = o as Map<String, dynamic>;
        final total = (map['total'] as num?)?.toDouble() ?? 0;
        final createdAt = DateTime.tryParse(map['created_at']?.toString() ?? '') ?? DateTime(2000);
        totalRevenue += total;
        if (createdAt.isAfter(today)) { revenueToday += total; ordersToday++; }
        if (createdAt.isAfter(last7)) revenue7Days += total;
        if (createdAt.isAfter(last30)) revenue30Days += total;
        if (map['status'] == 'pending') pendingOrders++;
      }

      return {
        'total_orders': orders.length,
        'total_revenue': totalRevenue,
        'revenue_today': revenueToday,
        'revenue_7_days': revenue7Days,
        'revenue_30_days': revenue30Days,
        'pending_orders': pendingOrders,
        'orders_today': ordersToday,
        'total_users': users.length,
        'total_active_products': products.length,
      };
    } catch (e, st) {
      AppLogger.e('AdminDS.getDashboardStats', error: e, stackTrace: st);
      throw const ServerAppException('Failed to load dashboard stats.');
    }
  }

  Future<List<Map<String, dynamic>>> getRecentOrders({int limit = 8}) async {
    try {
      final data = await _supabase
          .from('orders')
          .select('id, order_number, status, total, created_at, user_id')
          .order('created_at', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(data as List);
    } catch (e, st) {
      AppLogger.e('AdminDS.getRecentOrders', error: e, stackTrace: st);
      throw const ServerAppException('Failed to load recent orders.');
    }
  }

  Future<List<Map<String, dynamic>>> getTopProducts({int limit = 5}) async {
    try {
      final data = await _supabase
          .from('products')
          .select('id, name_en, name_ar, sold_count, base_price, product_images(url, is_primary)')
          .order('sold_count', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(data as List);
    } catch (e, st) {
      AppLogger.e('AdminDS.getTopProducts', error: e, stackTrace: st);
      throw const ServerAppException('Failed to load top products.');
    }
  }

  // ── Products ───────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getAllProducts({
    String? search,
    String? categoryId,
    bool? isActive,
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      var query = _supabase.from('products').select(
        'id, name_en, name_ar, base_price, final_price, discount_percent, '
        'is_active, is_featured, is_new_arrival, is_on_sale, sku, '
        'avg_rating, review_count, sold_count, category_id, created_at, '
        'product_images(url, is_primary, sort_order)',
      );

      if (isActive != null) query = query.eq('is_active', isActive);
      if (categoryId != null) query = query.eq('category_id', categoryId);
      if (search != null && search.isNotEmpty) {
        query = query.or('name_en.ilike.%$search%,name_ar.ilike.%$search%');
      }

      final data = await query
          .order('created_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);

      return List<Map<String, dynamic>>.from(data as List);
    } catch (e, st) {
      AppLogger.e('AdminDS.getAllProducts', error: e, stackTrace: st);
      throw const ServerAppException('Failed to load products.');
    }
  }

  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> data) async {
    try {
      final result = await _supabase.from('products').insert(data).select().single();
      return result as Map<String, dynamic>;
    } catch (e, st) {
      AppLogger.e('AdminDS.createProduct', error: e, stackTrace: st);
      throw ServerAppException('Failed to create product: $e');
    }
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    try {
      await _supabase.from('products').update(data).eq('id', id);
    } catch (e, st) {
      AppLogger.e('AdminDS.updateProduct', error: e, stackTrace: st);
      throw ServerAppException('Failed to update product: $e');
    }
  }

  Future<void> softDeleteProduct(String id) async {
    try {
      await _supabase.from('products').update({
        'deleted_at': DateTime.now().toIso8601String(),
        'is_active': false,
      }).eq('id', id);
    } catch (e, st) {
      AppLogger.e('AdminDS.softDeleteProduct', error: e, stackTrace: st);
      throw const ServerAppException('Failed to delete product.');
    }
  }

  Future<void> toggleProductActive(String id, bool isActive) async {
    try {
      await _supabase.from('products').update({'is_active': isActive}).eq('id', id);
    } catch (e, st) {
      AppLogger.e('AdminDS.toggleProductActive', error: e, stackTrace: st);
      throw const ServerAppException('Failed to toggle product status.');
    }
  }

  Future<void> addProductImage(Map<String, dynamic> imageData) async {
    try {
      await _supabase.from('product_images').insert(imageData);
    } catch (e, st) {
      AppLogger.e('AdminDS.addProductImage', error: e, stackTrace: st);
      throw const ServerAppException('Failed to add product image.');
    }
  }

  Future<void> deleteProductImage(String imageId) async {
    try {
      await _supabase.from('product_images').delete().eq('id', imageId);
    } catch (e, st) {
      AppLogger.e('AdminDS.deleteProductImage', error: e, stackTrace: st);
      throw const ServerAppException('Failed to delete product image.');
    }
  }

  Future<String> uploadImage(String bucket, String path, Uint8List bytes) async {
    try {
      await _supabase.storage.from(bucket).uploadBinary(
        path, bytes,
        fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
      );
      return _supabase.storage.from(bucket).getPublicUrl(path);
    } catch (e, st) {
      AppLogger.e('AdminDS.uploadImage', error: e, stackTrace: st);
      throw const ServerAppException('Failed to upload image.');
    }
  }

  // ── Categories ─────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getAllCategories() async {
    try {
      final data = await _supabase
          .from('categories')
          .select('id, name_en, name_ar, slug, image_url, is_active, sort_order, parent_id')
          .order('sort_order');
      return List<Map<String, dynamic>>.from(data as List);
    } catch (e, st) {
      AppLogger.e('AdminDS.getAllCategories', error: e, stackTrace: st);
      throw const ServerAppException('Failed to load categories.');
    }
  }

  Future<void> createCategory(Map<String, dynamic> data) async {
    try {
      await _supabase.from('categories').insert(data);
    } catch (e, st) {
      AppLogger.e('AdminDS.createCategory', error: e, stackTrace: st);
      throw ServerAppException('Failed to create category: $e');
    }
  }

  Future<void> updateCategory(String id, Map<String, dynamic> data) async {
    try {
      await _supabase.from('categories').update(data).eq('id', id);
    } catch (e, st) {
      AppLogger.e('AdminDS.updateCategory', error: e, stackTrace: st);
      throw const ServerAppException('Failed to update category.');
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _supabase.from('categories').delete().eq('id', id);
    } catch (e, st) {
      AppLogger.e('AdminDS.deleteCategory', error: e, stackTrace: st);
      throw const ServerAppException('Failed to delete category.');
    }
  }

  // ── Orders ─────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getAllOrders({
    String? status,
    String? search,
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      var query = _supabase.from('orders').select(
        'id, order_number, status, total, subtotal, shipping_cost, tax, '
        'payment_method, created_at, updated_at, user_id, shipping_address, '
        'order_items(id, product_name_en, product_name_ar, quantity, price_at_purchase, product_image)',
      );

      if (status != null && status != 'all') query = query.eq('status', status);
      if (search != null && search.isNotEmpty) {
        query = query.ilike('order_number', '%$search%');
      }

      final data = await query
          .order('created_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);

      return List<Map<String, dynamic>>.from(data as List);
    } catch (e, st) {
      AppLogger.e('AdminDS.getAllOrders', error: e, stackTrace: st);
      throw const ServerAppException('Failed to load orders.');
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _supabase.from('orders').update({'status': newStatus}).eq('id', orderId);
    } catch (e, st) {
      AppLogger.e('AdminDS.updateOrderStatus', error: e, stackTrace: st);
      throw const ServerAppException('Failed to update order status.');
    }
  }

  // ── Users ──────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getAllUsers({
    String? search,
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      var query = _supabase.from('profiles').select(
        'id, full_name, avatar_url, phone, role, created_at',
      );
      if (search != null && search.isNotEmpty) {
        query = query.ilike('full_name', '%$search%');
      }
      final data = await query
          .order('created_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);
      return List<Map<String, dynamic>>.from(data as List);
    } catch (e, st) {
      AppLogger.e('AdminDS.getAllUsers', error: e, stackTrace: st);
      throw const ServerAppException('Failed to load users.');
    }
  }

  Future<void> updateUserRole(String userId, String role) async {
    try {
      await _supabase.from('profiles').update({'role': role}).eq('id', userId);
    } catch (e, st) {
      AppLogger.e('AdminDS.updateUserRole', error: e, stackTrace: st);
      throw const ServerAppException('Failed to update user role.');
    }
  }

  // ── Banners ────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getAllBanners() async {
    try {
      final data = await _supabase
          .from('banners')
          .select('id, title_en, title_ar, image_url, action_type, action_value, sort_order, is_active, starts_at, ends_at')
          .order('sort_order');
      return List<Map<String, dynamic>>.from(data as List);
    } catch (e, st) {
      AppLogger.e('AdminDS.getAllBanners', error: e, stackTrace: st);
      throw const ServerAppException('Failed to load banners.');
    }
  }

  Future<void> createBanner(Map<String, dynamic> data) async {
    try {
      await _supabase.from('banners').insert(data);
    } catch (e, st) {
      AppLogger.e('AdminDS.createBanner', error: e, stackTrace: st);
      throw const ServerAppException('Failed to create banner.');
    }
  }

  Future<void> updateBanner(String id, Map<String, dynamic> data) async {
    try {
      await _supabase.from('banners').update(data).eq('id', id);
    } catch (e, st) {
      AppLogger.e('AdminDS.updateBanner', error: e, stackTrace: st);
      throw const ServerAppException('Failed to update banner.');
    }
  }

  Future<void> deleteBanner(String id) async {
    try {
      await _supabase.from('banners').delete().eq('id', id);
    } catch (e, st) {
      AppLogger.e('AdminDS.deleteBanner', error: e, stackTrace: st);
      throw const ServerAppException('Failed to delete banner.');
    }
  }

  // ── Coupons ────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getAllCoupons() async {
    try {
      final data = await _supabase
          .from('coupons')
          .select('id, code, type, value, min_order_amount, max_uses, used_count, is_active, starts_at, expires_at, created_at')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data as List);
    } catch (e, st) {
      AppLogger.e('AdminDS.getAllCoupons', error: e, stackTrace: st);
      throw const ServerAppException('Failed to load coupons.');
    }
  }

  Future<void> createCoupon(Map<String, dynamic> data) async {
    try {
      await _supabase.from('coupons').insert(data);
    } catch (e, st) {
      AppLogger.e('AdminDS.createCoupon', error: e, stackTrace: st);
      throw ServerAppException('Failed to create coupon: $e');
    }
  }

  Future<void> updateCoupon(String id, Map<String, dynamic> data) async {
    try {
      await _supabase.from('coupons').update(data).eq('id', id);
    } catch (e, st) {
      AppLogger.e('AdminDS.updateCoupon', error: e, stackTrace: st);
      throw const ServerAppException('Failed to update coupon.');
    }
  }

  Future<void> deleteCoupon(String id) async {
    try {
      await _supabase.from('coupons').delete().eq('id', id);
    } catch (e, st) {
      AppLogger.e('AdminDS.deleteCoupon', error: e, stackTrace: st);
      throw const ServerAppException('Failed to delete coupon.');
    }
  }

  // ── Reviews ────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getAllReviews({int page = 0, int pageSize = 20}) async {
    try {
      final data = await _supabase
          .from('reviews')
          .select('id, product_id, user_id, rating, comment, created_at')
          .order('created_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);
      return List<Map<String, dynamic>>.from(data as List);
    } catch (e, st) {
      AppLogger.e('AdminDS.getAllReviews', error: e, stackTrace: st);
      throw const ServerAppException('Failed to load reviews.');
    }
  }

  Future<void> deleteReview(String id) async {
    try {
      await _supabase.from('reviews').delete().eq('id', id);
    } catch (e, st) {
      AppLogger.e('AdminDS.deleteReview', error: e, stackTrace: st);
      throw const ServerAppException('Failed to delete review.');
    }
  }
}
