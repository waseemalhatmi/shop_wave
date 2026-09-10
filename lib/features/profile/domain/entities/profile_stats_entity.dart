import 'package:equatable/equatable.dart';

/// Domain entity representing dynamic real statistics for the user's profile.
class ProfileStatsEntity extends Equatable {
  const ProfileStatsEntity({
    this.ordersCount = 0,
    this.wishlistCount = 0,
    this.reviewsCount = 0,
  });

  final int ordersCount;
  final int wishlistCount;
  final int reviewsCount;

  ProfileStatsEntity copyWith({
    int? ordersCount,
    int? wishlistCount,
    int? reviewsCount,
  }) {
    return ProfileStatsEntity(
      ordersCount: ordersCount ?? this.ordersCount,
      wishlistCount: wishlistCount ?? this.wishlistCount,
      reviewsCount: reviewsCount ?? this.reviewsCount,
    );
  }

  @override
  List<Object?> get props => [ordersCount, wishlistCount, reviewsCount];
}
