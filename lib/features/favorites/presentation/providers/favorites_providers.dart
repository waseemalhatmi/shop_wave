import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/di/providers.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../data/datasources/favorites_remote_data_source.dart';
import '../../data/repositories/favorites_repository_impl.dart';

part 'favorites_providers.g.dart';

@riverpod
FavoritesRepository favoritesRepository(FavoritesRepositoryRef ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final remoteDataSource = FavoritesRemoteDataSourceImpl(supabase);
  return FavoritesRepositoryImpl(remoteDataSource);
}

@riverpod
class Favorites extends _$Favorites {
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

@riverpod
bool isFavorite(IsFavoriteRef ref, String productId) {
  final favoritesAsync = ref.watch(favoritesProvider);
  return favoritesAsync.value?.any((p) => p.id == productId) ?? false;
}
