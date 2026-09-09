import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../home/data/models/home_dtos.dart';
import '../../domain/repositories/products_repository.dart';

class ProductsRemoteDataSource {
  const ProductsRemoteDataSource(this._supabase);

  final SupabaseClient _supabase;

  static const _productSelect = '''
    id, name_en, name_ar, slug, base_price, final_price,
    discount_percent, avg_rating, review_count, sold_count,
    is_featured, is_new_arrival, is_on_sale, is_active, sku,
    category_id, brand_id,
    product_images (url, is_primary, sort_order)
  ''';

  Future<List<ProductDto>> getFilteredProducts(ProductFilterParams params) async {
    try {
      dynamic query = _supabase
          .from('products')
          .select(_productSelect)
          .eq('is_active', true);

      if (params.categoryId != null && params.categoryId!.isNotEmpty) {
        query = query.eq('category_id', params.categoryId!);
      }

      if (params.filterType == 'flash_deals') {
        query = query.eq('is_on_sale', true);
      } else if (params.filterType == 'featured') {
        query = query.eq('is_featured', true);
      } else if (params.filterType == 'new_arrivals') {
        query = query.eq('is_new_arrival', true);
      }

      if (params.searchQuery != null && params.searchQuery!.trim().isNotEmpty) {
        final q = params.searchQuery!.trim();
        query = query.or(
          'name_en.ilike.%$q%,name_ar.ilike.%$q%,description_en.ilike.%$q%,description_ar.ilike.%$q%,sku.ilike.%$q%',
        );
      }

      if (params.minPrice != null && params.minPrice! > 0) {
        query = query.gte('base_price', params.minPrice!);
      }
      if (params.maxPrice != null && params.maxPrice! < 1000) {
        query = query.lte('base_price', params.maxPrice!);
      }
      if (params.minRating != null && params.minRating! > 0) {
        query = query.gte('avg_rating', params.minRating!);
      }

      switch (params.sortBy) {
        case ProductSortOption.priceLow:
          query = query.order('base_price', ascending: true);
          break;
        case ProductSortOption.priceHigh:
          query = query.order('base_price', ascending: false);
          break;
        case ProductSortOption.rating:
          query = query.order('avg_rating', ascending: false);
          break;
        case ProductSortOption.newest:
          if (params.filterType == 'best_sellers') {
            query = query.order('sold_count', ascending: false);
          } else {
            query = query.order('created_at', ascending: false);
          }
          break;
      }

      query = query.range(params.offset, params.offset + params.limit - 1);

      final data = await query;
      final list = (data as List<dynamic>)
          .map((e) => ProductDto.fromJson(e as Map<String, dynamic>))
          .toList();

      return list;
    } catch (e, st) {
      AppLogger.e('ProductsRemoteDataSource.getFilteredProducts', error: e, stackTrace: st);
      throw const ServerAppException('Failed to load products.');
    }
  }

  Future<ProductDto> getProductById(String id) async {
    try {
      final data = await _supabase
          .from('products')
          .select(_productSelect)
          .eq('id', id)
          .single();

      return ProductDto.fromJson(data as Map<String, dynamic>);
    } catch (e, st) {
      AppLogger.e('ProductsRemoteDataSource.getProductById', error: e, stackTrace: st);
      throw const ServerAppException('Failed to load product details.');
    }
  }
}
