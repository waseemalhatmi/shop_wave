import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/home_dtos.dart';

/// Remote data source for all home screen data.
class HomeRemoteDataSource {
  const HomeRemoteDataSource(this._supabase);

  final SupabaseClient _supabase;

  static const _productSelect = '''
    id, name_en, name_ar, slug, base_price, final_price,
    discount_percent, avg_rating, review_count, sold_count,
    is_featured, is_new_arrival, is_on_sale, is_active, sku,
    category_id, brand_id,
    product_images (url, is_primary, sort_order)
  ''';

  // ── Banners ──────────────────────────────────────────────────────────────

  Future<List<BannerDto>> getBanners() async {
    try {
      final data = await _supabase
          .from('banners')
          .select(
            'id, title_en, title_ar, image_url, action_type, action_value, sort_order',
          )
          .eq('is_active', true)
          .order('sort_order');

      return _mapList(data, BannerDto.fromJson);
    } catch (e, st) {
      AppLogger.e('HomeDataSource.getBanners', error: e, stackTrace: st);
      throw const ServerAppException('Failed to load banners.');
    }
  }

  // ── Categories ───────────────────────────────────────────────────────────

  Future<List<CategoryDto>> getCategories({int limit = 10}) async {
    try {
      final data = await _supabase
          .from('categories')
          .select('id, name_en, name_ar, slug, image_url, parent_id, sort_order')
          .eq('is_active', true)
          .isFilter('parent_id', null)
          .order('sort_order')
          .limit(limit);

      return _mapList(data, CategoryDto.fromJson);
    } catch (e, st) {
      AppLogger.e('HomeDataSource.getCategories', error: e, stackTrace: st);
      throw const ServerAppException('Failed to load categories.');
    }
  }

  // ── Products — Featured ──────────────────────────────────────────────────

  Future<List<ProductDto>> getFeaturedProducts({int limit = 10}) async {
    try {
      final data = await _supabase
          .from('products')
          .select(_productSelect)
          .eq('is_active', true)
          .eq('is_featured', true)
          .order('created_at', ascending: false)
          .limit(limit);

      return _mapList(data, ProductDto.fromJson);
    } catch (e, st) {
      AppLogger.e('HomeDataSource.getFeaturedProducts', error: e, stackTrace: st);
      throw const ServerAppException('Failed to load featured products.');
    }
  }

  // ── Products — New Arrivals ──────────────────────────────────────────────

  Future<List<ProductDto>> getNewArrivals({int limit = 10}) async {
    try {
      final data = await _supabase
          .from('products')
          .select(_productSelect)
          .eq('is_active', true)
          .eq('is_new_arrival', true)
          .order('created_at', ascending: false)
          .limit(limit);

      return _mapList(data, ProductDto.fromJson);
    } catch (e, st) {
      AppLogger.e('HomeDataSource.getNewArrivals', error: e, stackTrace: st);
      throw const ServerAppException('Failed to load new arrivals.');
    }
  }

  // ── Products — Best Sellers ──────────────────────────────────────────────

  Future<List<ProductDto>> getBestSellers({int limit = 10}) async {
    try {
      final data = await _supabase
          .from('products')
          .select(_productSelect)
          .eq('is_active', true)
          .order('sold_count', ascending: false)
          .limit(limit);

      return _mapList(data, ProductDto.fromJson);
    } catch (e, st) {
      AppLogger.e('HomeDataSource.getBestSellers', error: e, stackTrace: st);
      throw const ServerAppException('Failed to load best sellers.');
    }
  }

  // ── Products — Flash Deals ───────────────────────────────────────────────

  Future<List<ProductDto>> getFlashDeals({int limit = 10}) async {
    try {
      final data = await _supabase
          .from('products')
          .select(_productSelect)
          .eq('is_active', true)
          .eq('is_on_sale', true)
          .order('created_at', ascending: false)
          .limit(limit);

      return _mapList(data, ProductDto.fromJson);
    } catch (e, st) {
      AppLogger.e('HomeDataSource.getFlashDeals', error: e, stackTrace: st);
      throw const ServerAppException('Failed to load flash deals.');
    }
  }

  // ── Product — Single ──────────────────────────────────────────────────────

  Future<ProductDto> getProductById(String id) async {
    try {
      final data = await _supabase
          .from('products')
          .select(_productSelect)
          .eq('id', id)
          .single();

      return ProductDto.fromJson(data as Map<String, dynamic>);
    } catch (e, st) {
      AppLogger.e('HomeDataSource.getProductById', error: e, stackTrace: st);
      throw const ServerAppException('Failed to load product details.');
    }
  }

  // ── Helper ───────────────────────────────────────────────────────────────

  List<T> _mapList<T>(
    dynamic data,
    T Function(Map<String, dynamic>) fromJson,
  ) =>
      (data as List<dynamic>)
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList();
}
