import 'package:equatable/equatable.dart';

/// Represents an authenticated user in the domain layer.
///
/// This is the domain entity — it contains ONLY what the business logic
/// cares about. It has NO knowledge of Supabase, JSON, or HTTP.
///
/// Why Equatable? So we can compare two User objects by value (not reference),
/// which is essential for Riverpod state equality checks.
class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.phone,
    this.createdAt,
  });

  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final String? phone;
  final DateTime? createdAt;

  /// Whether the user has a complete profile.
  bool get hasProfile => fullName != null && fullName!.isNotEmpty;

  /// Returns the display name, falling back to email prefix.
  String get displayName =>
      (fullName != null && fullName!.isNotEmpty) ? fullName! : email.split('@').first;

  /// Returns initials for the avatar placeholder (e.g. "Ahmed Saad" → "AS").
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
  }) =>
      UserEntity(
        id: id ?? this.id,
        email: email ?? this.email,
        fullName: fullName ?? this.fullName,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        phone: phone ?? this.phone,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  List<Object?> get props => [id, email, fullName, avatarUrl, phone, createdAt];
}
