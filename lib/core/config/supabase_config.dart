/// Supabase connection configuration.
///
/// Values are injected at build time via --dart-define-from-file=.env
/// See: .env file at project root.
abstract final class SupabaseConfig {
  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Validates that required environment variables are present.
  /// Call this at app startup before initializing Supabase.
  static void validate() {
    assert(
      url.isNotEmpty,
      'SUPABASE_URL is missing. Run with --dart-define-from-file=.env',
    );
    assert(
      anonKey.isNotEmpty,
      'SUPABASE_ANON_KEY is missing. Run with --dart-define-from-file=.env',
    );
  }
}
