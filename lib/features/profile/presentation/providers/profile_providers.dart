import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/profile_stats_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../data/datasources/profile_remote_data_source.dart';
import '../../data/repositories/profile_repository_impl.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final remoteDataSource = ProfileRemoteDataSourceImpl(supabase);
  return ProfileRepositoryImpl(remoteDataSource);
});

// ─── Profile Update Notifier ──────────────────────────────────────────────────

class ProfileUpdateNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> updateProfile({
    required String fullName,
    required String phone,
    String? avatarUrl,
    DateTime? dateOfBirth,
    String? gender,
  }) async {
    state = const AsyncValue.loading();
    final repository = ref.read(profileRepositoryProvider);
    final result = await repository.updateProfile(
      fullName: fullName,
      phone: phone,
      avatarUrl: avatarUrl,
      dateOfBirth: dateOfBirth,
      gender: gender,
    );

    result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (_) {
        final authState = ref.read(authNotifierProvider);
        if (authState is AuthAuthenticated) {
          final updatedUser = authState.user.copyWith(
            fullName: fullName,
            phone: phone,
            avatarUrl: avatarUrl,
          );
          ref.read(authNotifierProvider.notifier).updateUser(updatedUser);
        }
        state = const AsyncValue.data(null);
      },
    );
  }
}

final profileUpdateProvider =
    AsyncNotifierProvider<ProfileUpdateNotifier, void>(() {
  return ProfileUpdateNotifier();
});

// ─── Real Dynamic Profile Statistics Provider ─────────────────────────────────

final profileStatsProvider =
    FutureProvider.autoDispose<ProfileStatsEntity>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  final result = await repository.getProfileStats();
  return result.fold(
    (failure) => const ProfileStatsEntity(),
    (stats) => stats,
  );
});

// ─── Change Password Notifier ─────────────────────────────────────────────────

class ChangePasswordNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> changePassword(String newPassword) async {
    state = const AsyncLoading();
    final authRepo = ref.read(authRepositoryProvider);
    final result = await authRepo.updatePassword(newPassword: newPassword);
    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        return true;
      },
    );
  }
}

final changePasswordProvider =
    AsyncNotifierProvider<ChangePasswordNotifier, void>(
  ChangePasswordNotifier.new,
);
