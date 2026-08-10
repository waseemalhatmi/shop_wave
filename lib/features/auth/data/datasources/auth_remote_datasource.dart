import 'package:supabase_flutter/supabase_flutter.dart'
    hide AuthException; // hide to avoid collision with AppException hierarchy
import 'package:supabase_flutter/supabase_flutter.dart' as supa
    show AuthException;
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/user_dto.dart';

/// Remote data source for authentication via Supabase.
///
/// This class is the ONLY place in the app that talks to Supabase Auth.
/// It throws [AppException] subclasses (never Failures — that's the repo's job).
///
/// Architecture note:
/// DataSource → throws AppException
/// Repository → catches AppException → returns Either<Failure, T>
class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._supabase);

  final SupabaseClient _supabase;

  /// Returns the currently signed-in user's DTO, or null.
  Future<UserDto?> getCurrentUser() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) return null;

      final authUser = _supabase.auth.currentUser;
      if (authUser == null) return null;

      final profile = await _supabase
          .from('profiles')
          .select()
          .eq('id', authUser.id)
          .maybeSingle();

      return UserDto.fromSupabase(
        authUser: authUser.toJson(),
        profile: profile,
      );
    } on supa.AuthException catch (e, st) {
      AppLogger.e('getCurrentUser: AuthException', error: e, stackTrace: st);
      throw AuthAppException(e.message);
    } catch (e, st) {
      AppLogger.e('getCurrentUser: unexpected', error: e, stackTrace: st);
      throw const ServerAppException('Failed to get current user.');
    }
  }

  /// Signs in with email and password.
  Future<UserDto> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const AuthAppException('Sign in failed. Please try again.');
      }

      final profile = await _supabase
          .from('profiles')
          .select()
          .eq('id', response.user!.id)
          .maybeSingle();

      AppLogger.i('User signed in: ${response.user!.id}');

      return UserDto.fromSupabase(
        authUser: response.user!.toJson(),
        profile: profile,
      );
    } on supa.AuthException catch (e) {
      AppLogger.w('signInWithEmail: ${e.message}');
      throw AuthAppException(_mapAuthError(e.message));
    } on AppException {
      rethrow;
    } catch (e, st) {
      AppLogger.e('signInWithEmail: unexpected', error: e, stackTrace: st);
      throw const ServerAppException('Sign in failed. Please try again.');
    }
  }

  /// Creates a new account.
  Future<UserDto> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      if (response.user == null) {
        throw const AuthAppException('Registration failed. Please try again.');
      }

      AppLogger.i('User registered: ${response.user!.id}');

      return UserDto.fromSupabase(
        authUser: response.user!.toJson(),
      );
    } on supa.AuthException catch (e) {
      AppLogger.w('signUpWithEmail: ${e.message}');
      throw AuthAppException(_mapAuthError(e.message));
    } on AppException {
      rethrow;
    } catch (e, st) {
      AppLogger.e('signUpWithEmail: unexpected', error: e, stackTrace: st);
      throw const ServerAppException('Registration failed. Please try again.');
    }
  }

  /// Sends a password reset email.
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      AppLogger.i('Password reset email sent to $email');
    } on supa.AuthException catch (e) {
      throw AuthAppException(_mapAuthError(e.message));
    } catch (e, st) {
      AppLogger.e(
        'sendPasswordResetEmail: unexpected',
        error: e,
        stackTrace: st,
      );
      throw const ServerAppException('Failed to send reset email.');
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      AppLogger.i('User signed out');
    } on supa.AuthException catch (e) {
      throw AuthAppException(e.message);
    } catch (e, st) {
      AppLogger.e('signOut: unexpected', error: e, stackTrace: st);
      throw const ServerAppException('Sign out failed.');
    }
  }

  /// Stream of auth state changes.
  Stream<UserDto?> get authStateChanges =>
      _supabase.auth.onAuthStateChange.map((event) {
        final user = event.session?.user;
        if (user == null) return null;
        return UserDto.fromSupabase(authUser: user.toJson());
      });

  /// Maps Supabase error messages to user-friendly strings.
  String _mapAuthError(String supabaseMessage) => switch (supabaseMessage) {
        'Invalid login credentials' =>
          'Incorrect email or password. Please try again.',
        'Email not confirmed' =>
          'Please verify your email address before signing in.',
        'User already registered' =>
          'An account with this email already exists.',
        'Password should be at least 6 characters' =>
          'Password must be at least 8 characters long.',
        _ => supabaseMessage,
      };
}
