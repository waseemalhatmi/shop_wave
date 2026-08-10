/// Spacing scale based on a 4pt grid system.
///
/// All margins, paddings, and gaps should use these tokens.
/// This ensures visual rhythm and consistency across all screens.
///
/// Usage: Gap(AppSpacing.md) or SizedBox(height: AppSpacing.lg)
abstract final class AppSpacing {
  static const double xs  = 4.0;   // Extra Small  — tight spacing
  static const double sm  = 8.0;   // Small        — between related elements
  static const double md  = 16.0;  // Medium       — standard padding
  static const double lg  = 24.0;  // Large        — section spacing
  static const double xl  = 32.0;  // Extra Large  — generous spacing
  static const double xxl = 48.0;  // 2XL          — hero sections
  static const double xxxl = 64.0; // 3XL          — full-screen gaps

  // ── Screen Padding ────────────────────────────────────────────
  /// Horizontal padding applied to all full-width screens.
  static const double screenHorizontal = 20.0;

  /// Vertical padding for screen content.
  static const double screenVertical = 16.0;

  // ── Component Specific ────────────────────────────────────────
  static const double cardPadding = 12.0;
  static const double buttonHeight = 52.0;
  static const double buttonHeightSm = 40.0;
  static const double inputHeight = 52.0;
  static const double appBarHeight = 60.0;
  static const double bottomNavHeight = 64.0;
  static const double productCardWidth = 160.0;
  static const double productCardHeight = 220.0;
  static const double categoryCardSize = 80.0;
  static const double avatarSm = 32.0;
  static const double avatarMd = 48.0;
  static const double avatarLg = 80.0;
  static const double iconSm = 16.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
}
