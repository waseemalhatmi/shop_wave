import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/products_repository.dart';
import '../datasources/products_remote_datasource.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  const ProductsRepositoryImpl(this._dataSource);

  final ProductsRemoteDataSource _dataSource;

  @override
  Future<Either<Failure, List<ProductEntity>>> getFilteredProducts(
    ProductFilterParams params,
  ) async {
    try {
      final dtos = await _dataSource.getFilteredProducts(params);
      final entities = dtos.map((dto) => dto.toEntity()).toList();
      return Right(entities);
    } on ServerAppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductById(String id) async {
    try {
      final dto = await _dataSource.getProductById(id);
      return Right(dto.toEntity());
    } on ServerAppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
