/// Application-wide constants.
///
/// Use typed abstract classes to group constants by category.
/// Avoid magic numbers and strings scattered across the codebase.
abstract final class AppConstants {
  // ── Pagination ─────────────────────────────────────────────────
  static const int defaultPageSize = 20;
  static const int searchDebounceMs = 400;

  // ── Cache ──────────────────────────────────────────────────────
  static const String productsBox = 'products_cache';
  static const String categoriesBox = 'categories_cache';
  static const String userBox = 'user_cache';
  static const String cartBox = 'cart_cache';
  static const Duration cacheDuration = Duration(minutes: 30);

  // ── SharedPreferences Keys ─────────────────────────────────────
  static const String keyOnboardingSeen = 'onboarding_seen';
  // Alias used in OnboardingScreen
  static const String keyOnboardingDone = keyOnboardingSeen;
  static const String keyThemeMode = 'theme_mode';
  static const String keyLocale = 'locale';

  // ── Timeouts ───────────────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const int maxRetryAttempts = 3;

  // ── Limits ─────────────────────────────────────────────────────
  static const int maxCartItems = 50;
  static const int maxReviewImages = 5;
  static const int maxAddresses = 10;
  static const double maxProductImages = 8;

  // ── Storage Buckets ────────────────────────────────────────────
  static const String avatarsBucket = 'avatars';
  static const String productsBucket = 'products';
  static const String reviewsBucket = 'reviews';

  // ── Animation Durations ────────────────────────────────────────
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);
  static const Duration splashDuration = Duration(seconds: 2);

  // ── Border Radius ──────────────────────────────────────────────
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 999.0;

  // ── Elevation ─────────────────────────────────────────────────
  static const double elevationNone = 0.0;
  static const double elevationSm = 2.0;
  static const double elevationMd = 4.0;
  static const double elevationLg = 8.0;

  // ── Responsive Breakpoints ─────────────────────────────────────
  static const double mobileBreakpoint = 480.0;
  static const double tabletBreakpoint = 768.0;
  static const double desktopBreakpoint = 1024.0;
}
