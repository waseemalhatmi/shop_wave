import 'package:logger/logger.dart';
import '../config/app_config.dart';

/// Application-wide logger.
///
/// Uses [logger] package with a PrettyPrinter in debug mode
/// and a production-safe printer in release mode.
///
/// Why this over print()?
/// - Structured output with log levels (verbose/debug/info/warning/error)
/// - Stack traces for errors
/// - Silenced in production (no PII leaks in release builds)
/// - Timestamps and method names in output
///
/// Usage:
///   AppLogger.d('User tapped checkout');
///   AppLogger.e('Failed to load products', error: e, stackTrace: st);
final class AppLogger {
  AppLogger._();

  static late final Logger _logger;

  static void init() {
    _logger = Logger(
      printer: AppConfig.isDevelopment
          ? PrettyPrinter(
              methodCount: 2,
              errorMethodCount: 8,
              lineLength: 120,
              colors: true,
              printEmojis: true,
            )
          : SimplePrinter(colors: false, printTime: true),
      level: AppConfig.isDevelopment ? Level.trace : Level.warning,
      filter: AppConfig.isDevelopment
          ? DevelopmentFilter()
          : ProductionFilter(),
    );
  }

  /// Verbose — only in development. Detailed diagnostic info.
  static void v(String message) => _logger.t(message);

  /// Debug — development info.
  static void d(String message) => _logger.d(message);

  /// Info — important events.
  static void i(String message) => _logger.i(message);

  /// Warning — something unexpected but non-fatal.
  static void w(String message) => _logger.w(message);

  /// Error — something failed. Always include error + stackTrace.
  static void e(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) =>
      _logger.e(message, error: error, stackTrace: stackTrace);

  /// Fatal — critical failure, app may not recover.
  static void f(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) =>
      _logger.f(message, error: error, stackTrace: stackTrace);
}
