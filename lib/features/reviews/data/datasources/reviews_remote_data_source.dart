import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/review_model.dart';

abstract class ReviewsRemoteDataSource {
  Future<List<ReviewModel>> getProductReviews(String productId);
  Future<ReviewModel> addReview({
    required String productId,
    required int rating,
    required String comment,
  });
}

class ReviewsRemoteDataSourceImpl implements ReviewsRemoteDataSource {
  const ReviewsRemoteDataSourceImpl(this.supabaseClient);

  final SupabaseClient supabaseClient;

  @override
  Future<List<ReviewModel>> getProductReviews(String productId) async {
    try {
      final response = await supabaseClient
          .from('reviews')
          .select('*, profiles(full_name, avatar_url)')
          .eq('product_id', productId)
          .order('created_at', ascending: false);

      final list = response as List<dynamic>;
      return list.map((e) => ReviewModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ServerAppException(e.toString());
    }
  }

  @override
  Future<ReviewModel> addReview({
    required String productId,
    required int rating,
    required String comment,
  }) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw const ServerAppException('User not authenticated');
      }

      final response = await supabaseClient.from('reviews').insert({
        'product_id': productId,
        'user_id': userId,
        'rating': rating,
        'comment': comment,
      }).select('*, profiles(full_name, avatar_url)').single();

      return ReviewModel.fromJson(response);
    } catch (e) {
      throw ServerAppException(e.toString());
    }
  }
}
