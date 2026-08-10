import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../entities/banner_entity.dart';

/// Repository contract for home screen data.
abstract class HomeRepository {
  /// Fetches active promotional banners sorted by sort_order.
  Future<Either<Failure, List<BannerEntity>>> getBanners();

  /// Fetches top-level categories (parentId == null).
  Future<Either<Failure, List<CategoryEntity>>> getCategories({
    int limit = 10,
  });

  /// Fetches featured products.
  Future<Either<Failure, List<ProductEntity>>> getFeaturedProducts({
    int limit = 10,
  });

  /// Fetches new arrival products.
  Future<Either<Failure, List<ProductEntity>>> getNewArrivals({
    int limit = 10,
  });

  /// Fetches best selling products (by sold_count desc).
  Future<Either<Failure, List<ProductEntity>>> getBestSellers({
    int limit = 10,
  });

  /// Fetches flash deal products (is_on_sale = true).
  Future<Either<Failure, List<ProductEntity>>> getFlashDeals({
    int limit = 10,
  });

  /// Fetches a single product by its ID.
  Future<Either<Failure, ProductEntity>> getProductById(String id);
}
