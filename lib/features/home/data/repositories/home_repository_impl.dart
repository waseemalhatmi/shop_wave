import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../domain/entities/banner_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_datasource.dart';

/// Concrete implementation of [HomeRepository].
class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl(this._dataSource);

  final HomeRemoteDataSource _dataSource;

  @override
  Future<Either<Failure, List<BannerEntity>>> getBanners() =>
      _execute(() async {
        final dtos = await _dataSource.getBanners();
        return dtos.map((e) => e.toEntity()).toList();
      }, tag: 'getBanners');

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories({
    int limit = 10,
  }) =>
      _execute(() async {
        final dtos = await _dataSource.getCategories(limit: limit);
        return dtos.map((e) => e.toEntity()).toList();
      }, tag: 'getCategories');

  @override
  Future<Either<Failure, List<ProductEntity>>> getFeaturedProducts({
    int limit = 10,
  }) =>
      _execute(() async {
        final dtos = await _dataSource.getFeaturedProducts(limit: limit);
        return dtos.map((e) => e.toEntity()).toList();
      }, tag: 'getFeaturedProducts');

  @override
  Future<Either<Failure, List<ProductEntity>>> getNewArrivals({
    int limit = 10,
  }) =>
      _execute(() async {
        final dtos = await _dataSource.getNewArrivals(limit: limit);
        return dtos.map((e) => e.toEntity()).toList();
      }, tag: 'getNewArrivals');

  @override
  Future<Either<Failure, List<ProductEntity>>> getBestSellers({
    int limit = 10,
  }) =>
      _execute(() async {
        final dtos = await _dataSource.getBestSellers(limit: limit);
        return dtos.map((e) => e.toEntity()).toList();
      }, tag: 'getBestSellers');

  @override
  Future<Either<Failure, List<ProductEntity>>> getFlashDeals({
    int limit = 10,
  }) =>
      _execute(() async {
        final dtos = await _dataSource.getFlashDeals(limit: limit);
        return dtos.map((e) => e.toEntity()).toList();
      }, tag: 'getFlashDeals');

  @override
  Future<Either<Failure, ProductEntity>> getProductById(String id) =>
      _execute(() async {
        final dto = await _dataSource.getProductById(id);
        return dto.toEntity();
      }, tag: 'getProductById');

  // ── Generic executor ─────────────────────────────────────────────────────

  Future<Either<Failure, T>> _execute<T>(
    Future<T> Function() action, {
    required String tag,
  }) async {
    try {
      final result = await action();
      return Right(result);
    } on NetworkAppException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerAppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e, st) {
      AppLogger.e('HomeRepository.$tag', error: e, stackTrace: st);
      return const Left(UnexpectedFailure());
    }
  }
}
