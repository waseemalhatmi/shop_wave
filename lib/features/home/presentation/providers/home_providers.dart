import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/di/providers.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../data/datasources/home_remote_datasource.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/entities/banner_entity.dart';
import '../../domain/repositories/home_repository.dart';

part 'home_providers.g.dart';

// ── Infrastructure ─────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
HomeRemoteDataSource homeRemoteDataSource(Ref ref) =>
    HomeRemoteDataSource(ref.watch(supabaseClientProvider));

@Riverpod(keepAlive: true)
HomeRepository homeRepository(Ref ref) =>
    HomeRepositoryImpl(ref.watch(homeRemoteDataSourceProvider));

// ── Data Providers (AsyncNotifier pattern) ─────────────────────────────────
// Each provider is auto-disposable so data is re-fetched when re-entered.

@riverpod
Future<List<BannerEntity>> homeBanners(Ref ref) async {
  final result = await ref.watch(homeRepositoryProvider).getBanners();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (banners) => banners,
  );
}

@riverpod
Future<List<CategoryEntity>> homeCategories(Ref ref) async {
  final result = await ref.watch(homeRepositoryProvider).getCategories();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (categories) => categories,
  );
}

@riverpod
Future<List<ProductEntity>> featuredProducts(Ref ref) async {
  final result = await ref.watch(homeRepositoryProvider).getFeaturedProducts();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (products) => products,
  );
}

@riverpod
Future<List<ProductEntity>> newArrivalProducts(Ref ref) async {
  final result = await ref.watch(homeRepositoryProvider).getNewArrivals();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (products) => products,
  );
}

@riverpod
Future<List<ProductEntity>> bestSellerProducts(Ref ref) async {
  final result = await ref.watch(homeRepositoryProvider).getBestSellers();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (products) => products,
  );
}

@riverpod
Future<List<ProductEntity>> flashDealProducts(Ref ref) async {
  final result = await ref.watch(homeRepositoryProvider).getFlashDeals();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (products) => products,
  );
}

@riverpod
Future<ProductEntity> productDetail(Ref ref, String id) async {
  final result = await ref.watch(homeRepositoryProvider).getProductById(id);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (product) => product,
  );
}
