import 'package:equatable/equatable.dart';

/// Represents an authenticated user in the domain layer.
class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.phone,
    this.createdAt,
    this.role = 'customer',
  });

  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final String? phone;
  final DateTime? createdAt;
  final String role;

  bool get hasProfile => fullName != null && fullName!.isNotEmpty;
  bool get isAdmin => role == 'admin' || role == 'super_admin';
  bool get isSuperAdmin => role == 'super_admin';

  String get displayName =>
      (fullName != null && fullName!.isNotEmpty) ? fullName! : email.split('@').first;

  String get initials {
    if (fullName == null || fullName!.isEmpty) return email[0].toUpperCase();
    final parts = fullName!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return fullName![0].toUpperCase();
  }

  UserEntity copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    String? phone,
    DateTime? createdAt,
    String? role,
  }) =>
      UserEntity(
        id: id ?? this.id,
        email: email ?? this.email,
        fullName: fullName ?? this.fullName,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        phone: phone ?? this.phone,
        createdAt: createdAt ?? this.createdAt,
        role: role ?? this.role,
      );

  @override
  List<Object?> get props => [id, email, fullName, avatarUrl, phone, createdAt, role];
}
