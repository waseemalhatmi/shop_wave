import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/product_entity.dart';

enum ProductSortOption {
  newest,
  priceLow,
  priceHigh,
  rating,
}

class ProductFilterParams extends Equatable {
  const ProductFilterParams({
    this.categoryId,
    this.filterType,
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.sortBy = ProductSortOption.newest,
    this.searchQuery,
    this.limit = 40,
    this.offset = 0,
  });

  final String? categoryId;
  final String? filterType;
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final ProductSortOption sortBy;
  final String? searchQuery;
  final int limit;
  final int offset;

  bool get hasActiveFilters =>
      (minPrice != null && minPrice! > 0) ||
      (maxPrice != null && maxPrice! < 1000) ||
      (minRating != null && minRating! > 0);

  ProductFilterParams copyWith({
    String? categoryId,
    String? filterType,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    ProductSortOption? sortBy,
    String? searchQuery,
    int? limit,
    int? offset,
  }) {
    return ProductFilterParams(
      categoryId: categoryId ?? this.categoryId,
      filterType: filterType ?? this.filterType,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minRating: minRating ?? this.minRating,
      sortBy: sortBy ?? this.sortBy,
      searchQuery: searchQuery ?? this.searchQuery,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }

  @override
  List<Object?> get props => [
        categoryId,
        filterType,
        minPrice,
        maxPrice,
        minRating,
        sortBy,
        searchQuery,
        limit,
        offset,
      ];
}

abstract class ProductsRepository {
  Future<Either<Failure, List<ProductEntity>>> getFilteredProducts(
    ProductFilterParams params,
  );

  Future<Either<Failure, ProductEntity>> getProductById(String id);
}
