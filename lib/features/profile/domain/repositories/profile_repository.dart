import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/profile_stats_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, void>> updateProfile({
    required String fullName,
    required String phone,
    String? avatarUrl,
    DateTime? dateOfBirth,
    String? gender,
  });

  /// Fetches actual real-time count of orders, wishlist, and reviews.
  Future<Either<Failure, ProfileStatsEntity>> getProfileStats();
}
