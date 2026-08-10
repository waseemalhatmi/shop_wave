import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../../../home/data/models/home_dtos.dart';

abstract class FavoritesRemoteDataSource {
  Future<List<ProductDto>> getFavorites();
  Future<void> addFavorite(String productId);
  Future<void> removeFavorite(String productId);
}

class FavoritesRemoteDataSourceImpl implements FavoritesRemoteDataSource {
  const FavoritesRemoteDataSourceImpl(this.supabaseClient);

  final SupabaseClient supabaseClient;

  @override
  Future<List<ProductDto>> getFavorites() async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw const ServerAppException('User not authenticated');
      }

      // Query joining favorites and products with their images
      final response = await supabaseClient
          .from('favorites')
          .select('products(*, product_images(*))')
          .eq('user_id', userId);

      final list = response as List<dynamic>;
      return list
          .where((item) => item['products'] != null)
          .map((item) => ProductDto.fromJson(item['products'] as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerAppException(e.toString());
    }
  }

  @override
  Future<void> addFavorite(String productId) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw const ServerAppException('User not authenticated');
      }

      await supabaseClient.from('favorites').insert({
        'user_id': userId,
        'product_id': productId,
      });
    } catch (e) {
      throw ServerAppException(e.toString());
    }
  }

  @override
  Future<void> removeFavorite(String productId) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw const ServerAppException('User not authenticated');
      }

      await supabaseClient
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('product_id', productId);
    } catch (e) {
      throw ServerAppException(e.toString());
    }
  }
}
