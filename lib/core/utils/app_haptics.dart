import 'package:flutter/services.dart';

/// Centralized haptic feedback utility for ShopWave.
///
/// Wraps [HapticFeedback] with semantic, named methods to provide
/// consistent tactile responses across the entire application.
abstract final class AppHaptics {
  /// Light tap — use for navigation, chip selections, toggles.
  static Future<void> light() => HapticFeedback.lightImpact();

  /// Medium click — use for button presses, add-to-cart.
  static Future<void> medium() => HapticFeedback.mediumImpact();

  /// Heavy thud — use for destructive actions (delete, cancel order).
  static Future<void> heavy() => HapticFeedback.heavyImpact();

  /// Success pattern — use after order confirmed, payment success.
  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.lightImpact();
  }

  /// Warning pattern — use for validation errors, low stock alerts.
  static Future<void> warning() async {
    await HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 60));
    await HapticFeedback.mediumImpact();
  }

  /// Error pattern — use for payment failure, network error.
  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.mediumImpact();
  }

  /// Selection click — use for ChoiceChip / tab switches.
  static Future<void> selection() => HapticFeedback.selectionClick();
}
