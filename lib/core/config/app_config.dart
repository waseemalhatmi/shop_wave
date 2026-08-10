/// Application-wide configuration.
///
/// Environment values are injected at build time via:
///   flutter run --dart-define-from-file=.env
///
/// Never hardcode secrets in source code.
abstract final class AppConfig {
  // ── Environment ────────────────────────────────────────────────
  static const String env = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  static bool get isDevelopment => env == 'development';
  static bool get isProduction => env == 'production';

  // ── App Info ───────────────────────────────────────────────────
  static const String appName = 'ShopWave';
  static const String appVersion = '1.0.0';

  // ── Supported Locales ──────────────────────────────────────────
  static const String defaultLocale = 'en';
  static const List<String> supportedLocales = ['en', 'ar'];
}
