import '../../domain/entities/notification_entity.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String type;
  final String titleEn;
  final String titleAr;
  final String? bodyEn;
  final String? bodyAr;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.titleEn,
    required this.titleAr,
    this.bodyEn,
    this.bodyAr,
    this.data,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: json['type'] as String,
      titleEn: json['title_en'] as String,
      titleAr: json['title_ar'] as String,
      bodyEn: json['body_en'] as String?,
      bodyAr: json['body_ar'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'title_en': titleEn,
      'title_ar': titleAr,
      'body_en': bodyEn,
      'body_ar': bodyAr,
      'data': data,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
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
