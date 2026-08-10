import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_colors.dart';

/// Extension methods on [BuildContext] to reduce boilerplate.
///
/// Instead of Theme.of(context), MediaQuery.sizeOf(context), etc.,
/// we use these shorthand getters throughout the codebase.
extension BuildContextExt on BuildContext {
  // ── Theme ──────────────────────────────────────────────────────
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  // ── Localization ───────────────────────────────────────────────
  AppLocalizations get l10n => AppLocalizations.of(this);
  bool get isRtl => Directionality.of(this) == TextDirection.rtl;
  bool get isArabic => Localizations.localeOf(this).languageCode == 'ar';

  // ── Screen Size ────────────────────────────────────────────────
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  EdgeInsets get screenPadding => MediaQuery.paddingOf(this);
  bool get isTablet => MediaQuery.sizeOf(this).width >= 768;

  // ── Navigation ─────────────────────────────────────────────────
  bool get canPop => Navigator.of(this).canPop();
  void pop<T>([T? result]) => Navigator.of(this).pop(result);

  // ── Colors (semantic shortcuts) ────────────────────────────────
  Color get primaryColor => colorScheme.primary;
  Color get backgroundColor => colorScheme.surface;
  Color get onBackground => colorScheme.onSurface;
  Color get errorColor => colorScheme.error;

  // ── Skeleton colors based on theme ────────────────────────────
  Color get skeletonBase =>
      isDarkMode ? AppColors.skeletonBaseDark : AppColors.skeletonBase;
  Color get skeletonHighlight =>
      isDarkMode ? AppColors.skeletonHighlightDark : AppColors.skeletonHighlight;
}
