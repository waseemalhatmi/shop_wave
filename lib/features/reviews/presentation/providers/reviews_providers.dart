import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/di/providers.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/reviews_repository.dart';
import '../../data/datasources/reviews_remote_data_source.dart';
import '../../data/repositories/reviews_repository_impl.dart';

part 'reviews_providers.g.dart';

@riverpod
ReviewsRepository reviewsRepository(ReviewsRepositoryRef ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final remoteDataSource = ReviewsRemoteDataSourceImpl(supabase);
  return ReviewsRepositoryImpl(remoteDataSource);
}

@riverpod
Future<List<ReviewEntity>> productReviews(ProductReviewsRef ref, String productId) async {
  final repository = ref.watch(reviewsRepositoryProvider);
  final result = await repository.getProductReviews(productId);
  return result.fold<List<ReviewEntity>>(
    (failure) => throw Exception(failure.message),
    (reviews) => reviews,
  );
}

@riverpod
class AddReview extends _$AddReview {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> submitReview({
    required String productId,
    required int rating,
    required String comment,
  }) async {
    state = const AsyncValue.loading();
    final repository = ref.read(reviewsRepositoryProvider);
    final result = await repository.addReview(
      productId: productId,
      rating: rating,
      comment: comment,
    );

    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (_) {
        // Refresh product reviews list
        ref.invalidate(productReviewsProvider(productId));
        return const AsyncValue.data(null);
      },
    );
  }
}
