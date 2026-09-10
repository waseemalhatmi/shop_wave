import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/profile_stats_entity.dart';

abstract class ProfileRemoteDataSource {
  Future<void> updateProfile({
    required String fullName,
    required String phone,
    String? avatarUrl,
    DateTime? dateOfBirth,
    String? gender,
  });

  Future<ProfileStatsEntity> getProfileStats();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  const ProfileRemoteDataSourceImpl(this.supabaseClient);

  final SupabaseClient supabaseClient;

  @override
  Future<void> updateProfile({
    required String fullName,
    required String phone,
    String? avatarUrl,
    DateTime? dateOfBirth,
    String? gender,
  }) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw const ServerAppException('User not authenticated');
      }

      final profileData = {
        'full_name': fullName,
        'phone': phone,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        if (dateOfBirth != null)
          'date_of_birth': dateOfBirth.toIso8601String().split('T').first,
        if (gender != null) 'gender': gender.toLowerCase(),
      };

      await supabaseClient
          .from('profiles')
          .update(profileData)
          .eq('id', userId);
    } catch (e) {
      throw ServerAppException(e.toString());
    }
  }

  @override
  Future<ProfileStatsEntity> getProfileStats() async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        return const ProfileStatsEntity();
      }

      int ordersCount = 0;
      int wishlistCount = 0;
      int reviewsCount = 0;

      try {
        final ordersRes = await supabaseClient
            .from('orders')
            .select('id')
            .eq('user_id', userId)
            .count(CountOption.exact);
        ordersCount = ordersRes.count;
      } catch (_) {}

      try {
        final wishRes = await supabaseClient
            .from('favorites')
            .select('id')
            .eq('user_id', userId)
            .count(CountOption.exact);
        wishlistCount = wishRes.count;
      } catch (_) {}

      try {
        final revRes = await supabaseClient
            .from('reviews')
            .select('id')
            .eq('user_id', userId)
            .count(CountOption.exact);
        reviewsCount = revRes.count;
      } catch (_) {}

      return ProfileStatsEntity(
        ordersCount: ordersCount,
        wishlistCount: wishlistCount,
        reviewsCount: reviewsCount,
      );
    } catch (e) {
      return const ProfileStatsEntity();
    }
  }
}
