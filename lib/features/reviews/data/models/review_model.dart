import '../../domain/entities/review_entity.dart';

class ReviewModel {
  const ReviewModel({
    required this.id,
    required this.productId,
    required this.userId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.profiles,
  });

  final String id;
  final String productId;
  final String userId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final Map<String, dynamic>? profiles;

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      userId: json['user_id'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
      profiles: json['profiles'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'product_id': productId,
    'user_id': userId,
    'rating': rating,
    'comment': comment,
    'created_at': createdAt.toIso8601String(),
    'profiles': profiles,
  };
}

extension ReviewModelX on ReviewModel {
  ReviewEntity toDomain() {
    final profile = profiles ?? {};
    return ReviewEntity(
      id: id,
      productId: productId,
      userId: userId,
      userName: (profile['full_name'] as String?) ?? 'Anonymous',
      userAvatar: profile['avatar_url'] as String?,
      rating: rating,
      comment: comment,
      createdAt: createdAt,
    );
  }
}
