import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/reviews_repository.dart';
import '../../data/datasources/reviews_remote_data_source.dart';
import '../../data/repositories/reviews_repository_impl.dart';

final reviewsRepositoryProvider = Provider<ReviewsRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final remoteDataSource = ReviewsRemoteDataSourceImpl(supabase);
  return ReviewsRepositoryImpl(remoteDataSource);
});

final productReviewsProvider = FutureProvider.family<List<ReviewEntity>, String>((ref, productId) async {
  final repository = ref.watch(reviewsRepositoryProvider);
  final result = await repository.getProductReviews(productId);
  return result.fold<List<ReviewEntity>>(
    (failure) => throw Exception(failure.message),
    (reviews) => reviews,
  );
});

class AddReviewNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

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

    result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (_) {
        ref.invalidate(productReviewsProvider(productId));
        state = const AsyncValue.data(null);
      },
    );
  }
}

final addReviewProvider = AsyncNotifierProvider<AddReviewNotifier, void>(() {
  return AddReviewNotifier();
});
