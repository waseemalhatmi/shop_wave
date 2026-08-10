import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/di/providers.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../data/datasources/profile_remote_data_source.dart';
import '../../data/repositories/profile_repository_impl.dart';

part 'profile_providers.g.dart';

@riverpod
ProfileRepository profileRepository(ProfileRepositoryRef ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final remoteDataSource = ProfileRemoteDataSourceImpl(supabase);
  return ProfileRepositoryImpl(remoteDataSource);
}

@riverpod
class ProfileUpdate extends _$ProfileUpdate {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

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

    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (_) {
        // Update user entity in AuthNotifier
        final authState = ref.read(authNotifierProvider);
        if (authState is AuthAuthenticated) {
          final updatedUser = authState.user.copyWith(
            fullName: fullName,
            phone: phone,
            avatarUrl: avatarUrl,
          );
          ref.read(authNotifierProvider.notifier).updateUser(updatedUser);
        }
        return const AsyncValue.data(null);
      },
    );
  }
}
