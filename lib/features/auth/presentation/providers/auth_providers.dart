import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/di/providers.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../domain/usecases/sign_in_with_email_usecase.dart';
import '../../domain/usecases/sign_up_with_email_usecase.dart';

part 'auth_providers.g.dart';

// ── Data Source ────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return AuthRemoteDataSource(supabase);
}

// ── Repository ─────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  final dataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(dataSource);
}

// ── Use Cases ──────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
SignInWithEmailUseCase signInWithEmailUseCase(Ref ref) {
  return SignInWithEmailUseCase(ref.watch(authRepositoryProvider));
}

@Riverpod(keepAlive: true)
SignUpWithEmailUseCase signUpWithEmailUseCase(Ref ref) {
  return SignUpWithEmailUseCase(ref.watch(authRepositoryProvider));
}

@Riverpod(keepAlive: true)
SendPasswordResetEmailUseCase sendPasswordResetEmailUseCase(Ref ref) {
  return SendPasswordResetEmailUseCase(ref.watch(authRepositoryProvider));
}

@Riverpod(keepAlive: true)
SignOutUseCase signOutUseCase(Ref ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
}

// ── Auth State Stream ──────────────────────────────────────────────────────

/// Listens to Supabase auth state changes globally.
/// Used by [AuthNotifier] to sync state when session expires or changes.
@Riverpod(keepAlive: true)
Stream<User?> authStateStream(Ref ref) =>
    Supabase.instance.client.auth.onAuthStateChange
        .map((event) => event.session?.user);
