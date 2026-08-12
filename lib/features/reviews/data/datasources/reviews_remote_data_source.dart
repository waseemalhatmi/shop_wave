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
          .select('*')
          .eq('product_id', productId)
          .order('created_at', ascending: false);

      final list = List<Map<String, dynamic>>.from(response as List);
      
      final userIds = list.map((r) => r['user_id']?.toString()).whereType<String>().toSet().toList();
      if (userIds.isNotEmpty) {
        final profilesData = await supabaseClient.from('profiles').select('id, full_name, avatar_url').inFilter('id', userIds);
        final profilesList = List<Map<String, dynamic>>.from(profilesData as List);
        final profilesMap = {for (var p in profilesList) p['id'].toString(): p};
        
        for (var i = 0; i < list.length; i++) {
          final uid = list[i]['user_id']?.toString();
          if (uid != null && profilesMap.containsKey(uid)) {
            list[i]['profiles'] = profilesMap[uid];
          }
        }
      }

      return list.map((e) => ReviewModel.fromJson(e)).toList();
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
      }).select('*').single();
      
      final reviewData = Map<String, dynamic>.from(response);
      
      final profileResponse = await supabaseClient.from('profiles').select('id, full_name, avatar_url').eq('id', userId).maybeSingle();
      if (profileResponse != null) {
        reviewData['profiles'] = profileResponse;
      }

      return ReviewModel.fromJson(reviewData);
    } catch (e) {
      throw ServerAppException(e.toString());
    }
  }
}
