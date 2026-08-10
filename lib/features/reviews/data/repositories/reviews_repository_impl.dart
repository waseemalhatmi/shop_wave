import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/reviews_repository.dart';
import '../datasources/reviews_remote_data_source.dart';
import '../models/review_model.dart';

class ReviewsRepositoryImpl implements ReviewsRepository {
  const ReviewsRepositoryImpl(this.remoteDataSource);

  final ReviewsRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, List<ReviewEntity>>> getProductReviews(String productId) async {
    try {
      final models = await remoteDataSource.getProductReviews(productId);
      final entities = models.map((m) => m.toDomain()).toList();
      return Right(entities);
    } on ServerAppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReviewEntity>> addReview({
    required String productId,
    required int rating,
    required String comment,
  }) async {
    try {
      final model = await remoteDataSource.addReview(
        productId: productId,
        rating: rating,
        comment: comment,
      );
      return Right(model.toDomain());
    } on ServerAppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
