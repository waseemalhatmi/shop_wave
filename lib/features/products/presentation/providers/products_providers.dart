import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../data/datasources/products_remote_datasource.dart';
import '../../data/repositories/products_repository_impl.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/products_repository.dart';

final productsRemoteDataSourceProvider = Provider<ProductsRemoteDataSource>((ref) {
  return ProductsRemoteDataSource(ref.watch(supabaseClientProvider));
});

final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  return ProductsRepositoryImpl(ref.watch(productsRemoteDataSourceProvider));
});

final filteredProductsProvider =
    FutureProvider.family.autoDispose<List<ProductEntity>, ProductFilterParams>((ref, params) async {
  final repository = ref.watch(productsRepositoryProvider);
  final result = await repository.getFilteredProducts(params);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (products) => products,
  );
});

final singleProductProvider =
    FutureProvider.family.autoDispose<ProductEntity, String>((ref, id) async {
  final repository = ref.watch(productsRepositoryProvider);
  final result = await repository.getProductById(id);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (product) => product,
  );
});
