import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../data/datasources/home_remote_datasource.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/entities/banner_entity.dart';
import '../../domain/repositories/home_repository.dart';

// ── Infrastructure ─────────────────────────────────────────────────────────

final homeRemoteDataSourceProvider = Provider<HomeRemoteDataSource>((ref) {
  return HomeRemoteDataSource(ref.watch(supabaseClientProvider));
});

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepositoryImpl(ref.watch(homeRemoteDataSourceProvider));
});

// ── Data Providers (AsyncNotifier pattern) ─────────────────────────────────
// Each provider is auto-disposable so data is re-fetched when re-entered.

final homeBannersProvider = FutureProvider.autoDispose<List<BannerEntity>>((ref) async {
  final result = await ref.watch(homeRepositoryProvider).getBanners();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (banners) => banners,
  );
});

final homeCategoriesProvider = FutureProvider.autoDispose<List<CategoryEntity>>((ref) async {
  final result = await ref.watch(homeRepositoryProvider).getCategories();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (categories) => categories,
  );
});

final featuredProductsProvider = FutureProvider.autoDispose<List<ProductEntity>>((ref) async {
  final result = await ref.watch(homeRepositoryProvider).getFeaturedProducts();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (products) => products,
  );
});

final newArrivalProductsProvider = FutureProvider.autoDispose<List<ProductEntity>>((ref) async {
  final result = await ref.watch(homeRepositoryProvider).getNewArrivals();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (products) => products,
  );
});

final bestSellerProductsProvider = FutureProvider.autoDispose<List<ProductEntity>>((ref) async {
  final result = await ref.watch(homeRepositoryProvider).getBestSellers();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (products) => products,
  );
});

final flashDealProductsProvider = FutureProvider.autoDispose<List<ProductEntity>>((ref) async {
  final result = await ref.watch(homeRepositoryProvider).getFlashDeals();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (products) => products,
  );
});

final productDetailProvider = FutureProvider.family.autoDispose<ProductEntity, String>((ref, id) async {
  final result = await ref.watch(homeRepositoryProvider).getProductById(id);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (product) => product,
  );
});
