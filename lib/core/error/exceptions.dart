/// Custom exceptions thrown by the Data layer.
///
/// These are implementation-specific errors thrown in data sources.
/// They are caught in the repository and mapped to [Failure] objects,
/// so the Domain layer never sees exceptions — only `Either<Failure, T>`.
///
/// Naming convention: use `*AppException` suffix to avoid collision with
/// Supabase's built-in `AuthException` and `PostgrestException` types.
library;

/// Base class for all app-specific exceptions.
abstract class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when any server/API call fails (Supabase, HTTP, etc.)
class ServerAppException extends AppException {
  const ServerAppException([
    super.message = 'Server error occurred.',
  ]);
}

/// Thrown when device has no network connectivity.
class NetworkAppException extends AppException {
  const NetworkAppException([
    super.message = 'No internet connection.',
  ]);
}

/// Thrown when Hive local storage operations fail.
class CacheAppException extends AppException {
  const CacheAppException([
    super.message = 'Cache operation failed.',
  ]);
}

/// Thrown when Supabase Auth returns an error (wrong password, etc.)
/// Note: Named AuthAppException to avoid conflict with
/// supabase_flutter's own AuthException type.
class AuthAppException extends AppException {
  const AuthAppException([
    super.message = 'Authentication failed.',
  ]);
}

/// Thrown when a resource is not found in the data source.
class NotFoundAppException extends AppException {
  const NotFoundAppException([
    super.message = 'Resource not found.',
  ]);
}

// ─── Legacy Aliases ──────────────────────────────────────────────────────────
// Keep these for backward compatibility with any existing code.
// They will be removed in a future refactor.

/// @deprecated Use [ServerAppException] instead.
typedef ServerException = ServerAppException;

/// @deprecated Use [NetworkAppException] instead.
typedef NetworkException = NetworkAppException;

/// @deprecated Use [CacheAppException] instead.
typedef CacheException = CacheAppException;

/// @deprecated Use [NotFoundAppException] instead.
typedef NotFoundException = NotFoundAppException;
