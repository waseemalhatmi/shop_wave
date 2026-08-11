import '../../domain/entities/user_entity.dart';

/// Data Transfer Object for user data coming from Supabase.
class UserDto {
  const UserDto({
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
  final String? createdAt;
  final String role;

  /// Creates a [UserDto] by combining Supabase auth user and profile data.
  factory UserDto.fromSupabase({
    required Map<String, dynamic> authUser,
    Map<String, dynamic>? profile,
  }) =>
      UserDto(
        id: authUser['id'] as String,
        email: authUser['email'] as String,
        fullName: profile?['full_name'] as String? ??
            (authUser['user_metadata'] as Map<String, dynamic>?)?['full_name']
                as String?,
        avatarUrl: profile?['avatar_url'] as String? ??
            (authUser['user_metadata'] as Map<String, dynamic>?)?['avatar_url']
                as String?,
        phone: profile?['phone'] as String?,
        createdAt: authUser['created_at'] as String?,
        role: profile?['role'] as String? ?? 'customer',
      );

  /// Converts this DTO to the domain [UserEntity].
  UserEntity toEntity() => UserEntity(
        id: id,
        email: email,
        fullName: fullName,
        avatarUrl: avatarUrl,
        phone: phone,
        createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
        role: role,
      );
}
