// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/review_entity.dart';

part 'review_model.freezed.dart';
part 'review_model.g.dart';

@freezed
class ReviewModel with _$ReviewModel {
  const factory ReviewModel({
    required String id,
    @JsonKey(name: 'product_id') required String productId,
    @JsonKey(name: 'user_id') required String userId,
    required int rating,
    required String? comment,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    // Joined profile
    Map<String, dynamic>? profiles,
  }) = _ReviewModel;

  factory ReviewModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewModelFromJson(json);
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
