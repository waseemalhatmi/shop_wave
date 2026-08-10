import 'package:equatable/equatable.dart';

// ignore_for_file: prefer_asserts_with_message

/// Base class for all domain-level failures.
///
/// The UI layer handles each failure type with a specific message or action.
abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Server-side error — 4xx, 5xx HTTP or Supabase PostgrestException.
class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'An unexpected server error occurred.',
  ]);
}

/// Device has no internet connection.
class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'No internet connection. Please check your network.',
  ]);
}

/// Local cache read/write failed (Hive errors).
class CacheFailure extends Failure {
  const CacheFailure([
    super.message = 'Failed to access local cache.',
  ]);
}

/// Authentication error — invalid credentials, session expired.
class AuthFailure extends Failure {
  const AuthFailure([
    super.message = 'Authentication failed. Please log in again.',
  ]);
}

/// Input validation failed — contains field-level errors.
class ValidationFailure extends Failure {
  const ValidationFailure(
    super.message, {
    this.fieldErrors = const {},
  });

  /// Maps field name to its validation error message.
  final Map<String, String> fieldErrors;

  @override
  List<Object?> get props => [message, fieldErrors];
}

/// An error that was not anticipated — logged but shown generically.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([
    super.message = 'Something went wrong. Please try again.',
  ]);
}

/// Resource not found (404 equivalent in domain logic).
class NotFoundFailure extends Failure {
  const NotFoundFailure([
    super.message = 'The requested resource was not found.',
  ]);
}

/// User does not have permission for this action.
class PermissionFailure extends Failure {
  const PermissionFailure([
    super.message = 'You do not have permission to perform this action.',
  ]);
}
