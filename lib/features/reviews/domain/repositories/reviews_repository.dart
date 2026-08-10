import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/review_entity.dart';

abstract class ReviewsRepository {
  Future<Either<Failure, List<ReviewEntity>>> getProductReviews(String productId);
  Future<Either<Failure, ReviewEntity>> addReview({
    required String productId,
    required int rating,
    required String comment,
  });
}
