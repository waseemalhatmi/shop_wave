import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  const NotificationEntity({
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

  String localizedTitle(String langCode) => langCode == 'ar' ? titleAr : titleEn;
  String? localizedBody(String langCode) => langCode == 'ar' ? bodyAr : bodyEn;

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        titleEn,
        titleAr,
        bodyEn,
        bodyAr,
        data,
        isRead,
        createdAt,
      ];

  NotificationEntity copyWith({
    String? id,
    String? userId,
    String? type,
    String? titleEn,
    String? titleAr,
    String? bodyEn,
    String? bodyAr,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      titleEn: titleEn ?? this.titleEn,
      titleAr: titleAr ?? this.titleAr,
      bodyEn: bodyEn ?? this.bodyEn,
      bodyAr: bodyAr ?? this.bodyAr,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
