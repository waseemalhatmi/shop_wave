import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

/// Contract for all authentication operations.
///
/// Why an abstract class / interface?
/// The Dependency Inversion Principle requires that the Domain layer
/// NEVER knows about Supabase, HTTP, or any concrete implementation.
/// This interface is defined in the domain layer; the concrete
/// SupabaseAuthRepository lives in the data layer.
///
/// Benefits:
/// - Easy to swap Supabase for Firebase in the future
/// - Testable: can mock in unit tests
/// - Dependency rule is enforced at compile time
abstract class AuthRepository {
  /// Returns the currently authenticated user, or null if not signed in.
  Future<UserEntity?> getCurrentUser();

  /// Signs in with email and password.
  /// Returns [Right(UserEntity)] on success or [Left(Failure)] on error.
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Creates a new account with email, password, and full name.
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  });

  /// Sends a password reset email.
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  });

  /// Signs out the current user and clears all session data.
  Future<Either<Failure, void>> signOut();

  /// Stream of auth state changes (logged in / logged out).
  Stream<UserEntity?> get authStateChanges;
}
