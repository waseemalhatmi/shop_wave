import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../data/datasources/favorites_remote_data_source.dart';
import '../../data/repositories/favorites_repository_impl.dart';
import 'dart:async';

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final remoteDataSource = FavoritesRemoteDataSourceImpl(supabase);
  return FavoritesRepositoryImpl(remoteDataSource);
});

class Favorites extends AsyncNotifier<List<ProductEntity>> {
  @override
  Future<List<ProductEntity>> build() async {
    final repository = ref.watch(favoritesRepositoryProvider);
    final result = await repository.getFavorites();
    return result.fold<List<ProductEntity>>(
      (failure) => throw Exception(failure.message),
      (products) => products,
    );
  }

  Future<void> toggleFavorite(ProductEntity product) async {
    final repository = ref.read(favoritesRepositoryProvider);
    final currentList = state.value ?? [];
    final isFav = currentList.any((p) => p.id == product.id);

    if (isFav) {
      // Optimistically remove
      state = AsyncValue.data(
        currentList.where((p) => p.id != product.id).toList(),
      );
      final result = await repository.removeFavorite(product.id);
      result.fold(
        (failure) {
          // Rollback on failure
          ref.invalidateSelf();
        },
        (_) => null,
      );
    } else {
      // Optimistically add
      state = AsyncValue.data([...currentList, product]);
      final result = await repository.addFavorite(product.id);
      result.fold(
        (failure) {
          // Rollback on failure
          ref.invalidateSelf();
        },
        (_) => null,
      );
    }
  }
}

final favoritesProvider = AsyncNotifierProvider<Favorites, List<ProductEntity>>(() {
  return Favorites();
});

final isFavoriteProvider = Provider.family<bool, String>((ref, productId) {
  final favoritesAsync = ref.watch(favoritesProvider);
  return favoritesAsync.value?.any((p) => p.id == productId) ?? false;
});
