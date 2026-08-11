import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_providers.dart';

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final UserEntity user;
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  const AuthError(this.message);
  final String message;
}

class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _repository;

  @override
  AuthState build() {
    _repository = ref.read(authRepositoryProvider);
    // Start async session check — state updates from AuthInitial once resolved
    _checkExistingSession();
    return const AuthInitial();
  }

  Future<void> _checkExistingSession() async {
    try {
      final user = await _repository.getCurrentUser().timeout(
        const Duration(seconds: 5),
      );
      // Guard: provider may have been disposed
      if (state is! AuthAuthenticated && state is! AuthUnauthenticated) {
        state = user != null ? AuthAuthenticated(user) : const AuthUnauthenticated();
      }
    } catch (e, st) {
      AppLogger.e('AuthNotifier._checkExistingSession error', error: e, stackTrace: st);
      if (state is AuthInitial) {
        state = const AuthUnauthenticated();
      }
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AuthInitial();
    final result = await ref
        .read(signInWithEmailUseCaseProvider)
        .call(email: email, password: password);

    result.fold(
      (failure) => state = AuthError(failure.message),
      (user) => state = AuthAuthenticated(user),
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = const AuthInitial();
    final result = await ref.read(signUpWithEmailUseCaseProvider).call(
          email: email,
          password: password,
          fullName: fullName,
        );

    result.fold(
      (failure) => state = AuthError(failure.message),
      (user) => state = AuthAuthenticated(user),
    );
  }

  Future<String?> sendPasswordReset({required String email}) async {
    final result = await ref
        .read(sendPasswordResetEmailUseCaseProvider)
        .call(email: email);

    return result.fold(
      (failure) => failure.message,
      (_) => null,
    );
  }

  Future<void> signOut() async {
    await ref.read(signOutUseCaseProvider).call();
    state = const AuthUnauthenticated();
  }

  void updateUser(UserEntity user) {
    if (state is AuthAuthenticated) {
      state = AuthAuthenticated(user);
    }
  }
}

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

