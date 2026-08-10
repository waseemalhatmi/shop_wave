// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/notification_entity.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

@freezed
class NotificationModel with _$NotificationModel {
  const factory NotificationModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String type,
    @JsonKey(name: 'title_en') required String titleEn,
    @JsonKey(name: 'title_ar') required String titleAr,
    @JsonKey(name: 'body_en') required String? bodyEn,
    @JsonKey(name: 'body_ar') required String? bodyAr,
    required Map<String, dynamic>? data,
    @JsonKey(name: 'is_read') required bool isRead,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);
}

extension NotificationModelX on NotificationModel {
  NotificationEntity toDomain() => NotificationEntity(
        id: id,
        userId: userId,
        type: type,
        titleEn: titleEn,
        titleAr: titleAr,
        bodyEn: bodyEn,
        bodyAr: bodyAr,
        data: data,
        isRead: isRead,
        createdAt: createdAt,
      );
}
