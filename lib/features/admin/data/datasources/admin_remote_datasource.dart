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
    double? minPrice,
    double? maxPrice,
    bool? isFeatured,
    bool? isNewArrival,
    bool? isOnSale,
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
      if (isFeatured != null) query = query.eq('is_featured', isFeatured);
      if (isNewArrival != null) query = query.eq('is_new_arrival', isNewArrival);
      if (isOnSale != null) query = query.eq('is_on_sale', isOnSale);
      if (minPrice != null) query = query.gte('base_price', minPrice);
      if (maxPrice != null) query = query.lte('base_price', maxPrice);

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

  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> data, {List<Map<String, dynamic>>? variants}) async {
    try {
      final result = await _supabase.from('products').insert(data).select().single();
      if (variants != null && variants.isNotEmpty) {
        await _syncVariants(result['id'] as String, variants);
      }
      return result as Map<String, dynamic>;
    } catch (e, st) {
      AppLogger.e('AdminDS.createProduct', error: e, stackTrace: st);
      throw ServerAppException('Failed to create product: $e');
    }
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data, {List<Map<String, dynamic>>? variants}) async {
    try {
      await _supabase.from('products').update(data).eq('id', id);
      if (variants != null) {
        await _syncVariants(id, variants);
      }
    } catch (e, st) {
      AppLogger.e('AdminDS.updateProduct', error: e, stackTrace: st);
      throw ServerAppException('Failed to update product: $e');
    }
  }

  Future<void> _syncVariants(String productId, List<Map<String, dynamic>> variants) async {
    // Clean slate for existing variants
    await _supabase.from('product_variants').delete().eq('product_id', productId);
    
    if (variants.isEmpty) return;

    for (var v in variants) {
      final variantRes = await _supabase.from('product_variants').insert({
        'product_id': productId,
        'sku': v['sku'],
        'price': v['price'],
        'stock': v['stock'],
        'is_default': v['is_default'] ?? false,
      }).select().single();
      
      final variantId = variantRes['id'];
      
      final attributes = v['attributes'] as Map<String, String>?;
      if (attributes != null && attributes.isNotEmpty) {
        for (var entry in attributes.entries) {
          final attrName = entry.key.trim();
          final attrVal = entry.value.trim();
          if (attrName.isEmpty || attrVal.isEmpty) continue;
          
          // Find or create attribute
          var attrRes = await _supabase.from('product_attributes').select('id').eq('name_en', attrName).maybeSingle();
          String attrId;
          if (attrRes == null) {
            final newAttr = await _supabase.from('product_attributes').insert({'name_en': attrName, 'name_ar': attrName}).select('id').single();
            attrId = newAttr['id'];
          } else {
            attrId = attrRes['id'];
          }
          
          // Find or create value
          var valRes = await _supabase.from('product_attribute_values').select('id').eq('attribute_id', attrId).eq('value_en', attrVal).maybeSingle();
          String valueId;
          if (valRes == null) {
            final newVal = await _supabase.from('product_attribute_values').insert({
              'attribute_id': attrId,
              'value_en': attrVal,
              'value_ar': attrVal,
            }).select('id').single();
            valueId = newVal['id'];
          } else {
            valueId = valRes['id'];
          }
          
          // Link variant to value
          await _supabase.from('variant_attribute_values').insert({
            'variant_id': variantId,
            'value_id': valueId,
          });
        }
      }
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
      throw ServerAppException('Failed to toggle product status: $e');
    }
  }

  Future<void> bulkDeleteProducts(List<String> ids) async {
    try {
      await _supabase.from('products').update({
        'deleted_at': DateTime.now().toIso8601String(),
        'is_active': false,
      }).inFilter('id', ids);
    } catch (e, st) {
      AppLogger.e('AdminDS.bulkDeleteProducts', error: e, stackTrace: st);
      throw const ServerAppException('Failed to bulk delete products.');
    }
  }

  Future<void> bulkUpdateProductsActive(List<String> ids, bool isActive) async {
    try {
      await _supabase.from('products').update({'is_active': isActive}).inFilter('id', ids);
    } catch (e, st) {
      AppLogger.e('AdminDS.bulkUpdateProductsActive', error: e, stackTrace: st);
      throw const ServerAppException('Failed to bulk update products status.');
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
          .select(
            'id, name_en, name_ar, slug, image_url, is_active, sort_order, parent_id'
          )
          .order('sort_order');
      final categories = List<Map<String, dynamic>>.from(data as List);
      
      // Fetch product counts for each category in parallel
      final counts = await Future.wait(
        categories.map((c) => _supabase
            .from('products')
            .select('id')
            .eq('category_id', c['id'] as String)
            .count()),
      );
      
      return List.generate(categories.length, (i) {
        return {...categories[i], 'product_count': counts[i].count};
      });
    } catch (e, st) {
      AppLogger.e('AdminDS.getAllCategories', error: e, stackTrace: st);
      throw const ServerAppException('Failed to load categories.');
    }
  }

  Future<void> updateCategorySortOrder(List<Map<String, dynamic>> updates) async {
    try {
      await Future.wait(
        updates.map((u) => _supabase
            .from('categories')
            .update({'sort_order': u['sort_order']})
            .eq('id', u['id'] as String)),
      );
    } catch (e, st) {
      AppLogger.e('AdminDS.updateCategorySortOrder', error: e, stackTrace: st);
      throw const ServerAppException('Failed to update sort order.');
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
    DateTime? dateFrom,
    DateTime? dateTo,
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
      if (dateFrom != null) query = query.gte('created_at', dateFrom.toIso8601String());
      if (dateTo != null) query = query.lte('created_at', dateTo.toIso8601String());

      final data = await query
          .order('created_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);

      final orders = List<Map<String, dynamic>>.from(data as List);
      
      // Fetch profiles manually to avoid foreign key cache issues
      final userIds = orders.map((o) => o['user_id']?.toString()).whereType<String>().toSet().toList();
      if (userIds.isNotEmpty) {
        final profilesData = await _supabase.from('profiles').select('id, full_name, avatar_url').inFilter('id', userIds);
        final profilesList = List<Map<String, dynamic>>.from(profilesData as List);
        final profilesMap = {for (var p in profilesList) p['id'].toString(): p};
        
        for (var i = 0; i < orders.length; i++) {
          final uid = orders[i]['user_id']?.toString();
          if (uid != null && profilesMap.containsKey(uid)) {
            orders[i]['profiles'] = profilesMap[uid];
          }
        }
      }

      return orders;
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
    String? role,
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
      if (role != null) {
        query = query.eq('role', role);
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

  Future<Map<String, dynamic>?> createCoupon(Map<String, dynamic> data) async {
    try {
      final result = await _supabase.from('coupons').insert(data).select().single();
      return result as Map<String, dynamic>;
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

  Future<List<Map<String, dynamic>>> getAllReviews({
    int page = 0,
    int pageSize = 20,
    int? minRating,
    int? maxRating,
  }) async {
    try {
      var query = _supabase.from('reviews').select(
        'id, rating, comment, created_at, user_id, '
        'products(id, name_en, name_ar)',
      );
      if (minRating != null) query = query.gte('rating', minRating);
      if (maxRating != null) query = query.lte('rating', maxRating);
      
      final data = await query
          .order('created_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);
          
      final reviews = List<Map<String, dynamic>>.from(data as List);
      
      // Fetch profiles manually
      final userIds = reviews.map((r) => r['user_id']?.toString()).whereType<String>().toSet().toList();
      if (userIds.isNotEmpty) {
        final profilesData = await _supabase.from('profiles').select('id, full_name, avatar_url').inFilter('id', userIds);
        final profilesList = List<Map<String, dynamic>>.from(profilesData as List);
        final profilesMap = {for (var p in profilesList) p['id'].toString(): p};
        
        for (var i = 0; i < reviews.length; i++) {
          final uid = reviews[i]['user_id']?.toString();
          if (uid != null && profilesMap.containsKey(uid)) {
            reviews[i]['profiles'] = profilesMap[uid];
          }
        }
      }
      
      return reviews;
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
