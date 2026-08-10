import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_providers.dart';

part 'auth_notifier.g.dart';

/// Represents the authentication state of the application.
///
/// Using a sealed class for exhaustive pattern matching:
/// - AuthInitial: app is loading, checking session
/// - AuthAuthenticated: user is logged in
/// - AuthUnauthenticated: user is not logged in
/// - AuthError: an error occurred during auth
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

/// Manages the global authentication state.
///
/// This notifier is the single source of truth for "is the user logged in?".
/// The router [AppRouter._authGuard] reads from this notifier to decide
/// whether to redirect to login or allow navigation.
///
/// Lifecycle:
/// 1. build() → checks for existing session
/// 2. Supabase auth stream keeps state in sync automatically
/// 3. All UI auth actions call signIn/signUp/signOut here
@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  late final AuthRepository _repository;

  @override
  AuthState build() {
    _repository = ref.watch(authRepositoryProvider);

    // Listen to Supabase session changes (e.g., token expiry)
    ref.listen(authStateStreamProvider, (_, next) {
      next.whenData((user) {
        if (user == null) {
          state = const AuthUnauthenticated();
        }
        // Authenticated state is set explicitly after signIn/signUp
      });
    });

    // Check for existing session at startup
    _checkExistingSession();

    return const AuthInitial();
  }

  // ── Initialization ─────────────────────────────────────────────────────

  /// Checks for an existing Supabase session on app start.
  Future<void> _checkExistingSession() async {
    try {
      final user = await _repository.getCurrentUser().timeout(
        const Duration(seconds: 4),
      );
      if (user != null) {
        state = AuthAuthenticated(user);
      } else {
        state = const AuthUnauthenticated();
      }
    } catch (e, st) {
      AppLogger.e('AuthNotifier._checkExistingSession timeout/error fallback', error: e, stackTrace: st);
      state = const AuthUnauthenticated();
    }
  }

  // ── Public Actions ─────────────────────────────────────────────────────

  /// Signs in with email and password.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AuthInitial(); // shows loading

    final result = await ref
        .read(signInWithEmailUseCaseProvider)
        .call(email: email, password: password);

    result.fold(
      (failure) => state = AuthError(failure.message),
      (user) => state = AuthAuthenticated(user),
    );
  }

  /// Registers a new account.
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

  /// Sends password reset email.
  Future<String?> sendPasswordReset({required String email}) async {
    final result = await ref
        .read(sendPasswordResetEmailUseCaseProvider)
        .call(email: email);

    return result.fold(
      (failure) => failure.message,
      (_) => null, // null means success
    );
  }

  /// Signs out and clears state.
  Future<void> signOut() async {
    await ref.read(signOutUseCaseProvider).call();
    state = const AuthUnauthenticated();
  }

  /// Updates the user entity in state (used after profile edit).
  void updateUser(UserEntity user) {
    if (state is AuthAuthenticated) {
      state = AuthAuthenticated(user);
    }
  }
}
