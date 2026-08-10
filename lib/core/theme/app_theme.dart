import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Material 3 ThemeData factory for ShopWave.
///
/// Provides both light and dark themes with a cohesive design language.
/// All colors reference AppColors tokens — never hardcoded.
abstract final class AppTheme {
  // ── Light Theme ────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: _lightColorScheme,
        textTheme: GoogleFonts.outfitTextTheme(),
        scaffoldBackgroundColor: AppColors.backgroundLight,
        appBarTheme: _appBarThemeLight,
        elevatedButtonTheme: _elevatedButtonTheme,
        outlinedButtonTheme: _outlinedButtonTheme,
        textButtonTheme: _textButtonTheme,
        inputDecorationTheme: _inputDecorationThemeLight,
        cardTheme: _cardThemeLight,
        chipTheme: _chipThemeLight,
        bottomNavigationBarTheme: _bottomNavThemeLight,
        dividerTheme: _dividerThemeLight,
        iconTheme: const IconThemeData(color: AppColors.onSurfaceLight),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.primary,
        ),
        pageTransitionsTheme: _pageTransitionsTheme,
      );

  // ── Dark Theme ─────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: _darkColorScheme,
        textTheme: GoogleFonts.outfitTextTheme().apply(
          bodyColor: AppColors.onSurfaceDark,
          displayColor: AppColors.onSurfaceDark,
        ),
        scaffoldBackgroundColor: AppColors.backgroundDark,
        appBarTheme: _appBarThemeDark,
        elevatedButtonTheme: _elevatedButtonTheme,
        outlinedButtonTheme: _outlinedButtonThemeDark,
        textButtonTheme: _textButtonTheme,
        inputDecorationTheme: _inputDecorationThemeDark,
        cardTheme: _cardThemeDark,
        chipTheme: _chipThemeDark,
        bottomNavigationBarTheme: _bottomNavThemeDark,
        dividerTheme: _dividerThemeDark,
        iconTheme: const IconThemeData(color: AppColors.onSurfaceDark),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.primaryDark,
        ),
        pageTransitionsTheme: _pageTransitionsTheme,
      );

  // ── Color Schemes ──────────────────────────────────────────────
  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.white,
    primaryContainer: AppColors.primaryLight,
    onPrimaryContainer: AppColors.primary,
    secondary: AppColors.secondary,
    onSecondary: AppColors.white,
    secondaryContainer: AppColors.secondaryLight,
    onSecondaryContainer: AppColors.secondary,
    error: AppColors.error,
    onError: AppColors.onError,
    surface: AppColors.surfaceLight,
    onSurface: AppColors.onSurfaceLight,
    surfaceContainerHighest: AppColors.surfaceVariantLight,
    onSurfaceVariant: AppColors.onSurfaceVariantLight,
    outline: AppColors.borderLight,
    shadow: AppColors.shadowLight,
    inverseSurface: AppColors.onSurfaceLight,
    onInverseSurface: AppColors.surfaceLight,
  );

  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primaryDark,
    onPrimary: AppColors.black,
    primaryContainer: Color(0xFF3730A3),
    onPrimaryContainer: AppColors.primaryDark,
    secondary: AppColors.secondaryDark,
    onSecondary: AppColors.black,
    secondaryContainer: Color(0xFF9B2335),
    onSecondaryContainer: AppColors.secondaryDark,
    error: AppColors.errorDark,
    onError: AppColors.black,
    surface: AppColors.surfaceDark,
    onSurface: AppColors.onSurfaceDark,
    surfaceContainerHighest: AppColors.surfaceVariantDark,
    onSurfaceVariant: AppColors.onSurfaceVariantDark,
    outline: AppColors.borderDark,
    shadow: AppColors.shadowDark,
    inverseSurface: AppColors.onSurfaceDark,
    onInverseSurface: AppColors.surfaceDark,
  );

  // ── AppBar ─────────────────────────────────────────────────────
  static const AppBarTheme _appBarThemeLight = AppBarTheme(
    backgroundColor: AppColors.surfaceLight,
    foregroundColor: AppColors.onSurfaceLight,
    elevation: 0,
    scrolledUnderElevation: 1,
    centerTitle: false,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
    ),
    titleTextStyle: TextStyle(
      fontFamily: 'Outfit',
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.onSurfaceLight,
    ),
  );

  static const AppBarTheme _appBarThemeDark = AppBarTheme(
    backgroundColor: AppColors.surfaceDark,
    foregroundColor: AppColors.onSurfaceDark,
    elevation: 0,
    scrolledUnderElevation: 1,
    centerTitle: false,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
      statusBarColor: Colors.transparent,
    ),
    titleTextStyle: TextStyle(
      fontFamily: 'Outfit',
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.onSurfaceDark,
    ),
  );

  // ── Buttons ────────────────────────────────────────────────────
  static final ElevatedButtonThemeData _elevatedButtonTheme =
      ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      disabledBackgroundColor: AppColors.borderLight,
      disabledForegroundColor: AppColors.onSurfaceVariantLight,
      elevation: 0,
      minimumSize: const Size(double.infinity, 52),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontFamily: 'Outfit',
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  static final OutlinedButtonThemeData _outlinedButtonTheme =
      OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.primary, width: 1.5),
      minimumSize: const Size(double.infinity, 52),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontFamily: 'Outfit',
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  static final OutlinedButtonThemeData _outlinedButtonThemeDark =
      OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primaryDark,
      side: const BorderSide(color: AppColors.primaryDark, width: 1.5),
      minimumSize: const Size(double.infinity, 52),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontFamily: 'Outfit',
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  static final TextButtonThemeData _textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      textStyle: const TextStyle(
        fontFamily: 'Outfit',
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  // ── Input Decoration ───────────────────────────────────────────
  static final InputDecorationTheme _inputDecorationThemeLight =
      InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceVariantLight,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.borderLight),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.borderLight),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
    ),
    hintStyle: const TextStyle(
      fontFamily: 'Outfit',
      fontSize: 14,
      color: AppColors.onSurfaceVariantLight,
    ),
    errorStyle: const TextStyle(
      fontFamily: 'Outfit',
      fontSize: 12,
      color: AppColors.error,
    ),
  );

  static final InputDecorationTheme _inputDecorationThemeDark =
      InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceVariantDark,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.borderDark),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.borderDark),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primaryDark, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.errorDark),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.errorDark, width: 1.5),
    ),
    hintStyle: const TextStyle(
      fontFamily: 'Outfit',
      fontSize: 14,
      color: AppColors.onSurfaceVariantDark,
    ),
    errorStyle: const TextStyle(
      fontFamily: 'Outfit',
      fontSize: 12,
      color: AppColors.errorDark,
    ),
  );

  // ── Cards ──────────────────────────────────────────────────────
  static final CardThemeData _cardThemeLight = CardThemeData(
    elevation: 0,
    color: AppColors.surfaceLight,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: AppColors.borderLight, width: 0.5),
    ),
  );

  static final CardThemeData _cardThemeDark = CardThemeData(
    elevation: 0,
    color: AppColors.surfaceVariantDark,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: AppColors.borderDark, width: 0.5),
    ),
  );

  // ── Chips ──────────────────────────────────────────────────────
  static final ChipThemeData _chipThemeLight = ChipThemeData(
    backgroundColor: AppColors.surfaceVariantLight,
    selectedColor: AppColors.primaryLight,
    side: const BorderSide(color: AppColors.borderLight),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    labelStyle: const TextStyle(
      fontFamily: 'Outfit',
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
  );

  static final ChipThemeData _chipThemeDark = ChipThemeData(
    backgroundColor: AppColors.surfaceVariantDark,
    selectedColor: Color(0xFF3730A3),
    side: const BorderSide(color: AppColors.borderDark),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    labelStyle: const TextStyle(
      fontFamily: 'Outfit',
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
  );

  // ── Bottom Navigation ──────────────────────────────────────────
  static final BottomNavigationBarThemeData _bottomNavThemeLight =
      BottomNavigationBarThemeData(
    backgroundColor: AppColors.surfaceLight,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.onSurfaceVariantLight,
    elevation: 8,
    type: BottomNavigationBarType.fixed,
    selectedLabelStyle: const TextStyle(
      fontFamily: 'Outfit',
      fontSize: 10,
      fontWeight: FontWeight.w600,
    ),
    unselectedLabelStyle: const TextStyle(
      fontFamily: 'Outfit',
      fontSize: 10,
      fontWeight: FontWeight.w400,
    ),
  );

  static final BottomNavigationBarThemeData _bottomNavThemeDark =
      BottomNavigationBarThemeData(
    backgroundColor: AppColors.surfaceDark,
    selectedItemColor: AppColors.primaryDark,
    unselectedItemColor: AppColors.onSurfaceVariantDark,
    elevation: 8,
    type: BottomNavigationBarType.fixed,
    selectedLabelStyle: const TextStyle(
      fontFamily: 'Outfit',
      fontSize: 10,
      fontWeight: FontWeight.w600,
    ),
    unselectedLabelStyle: const TextStyle(
      fontFamily: 'Outfit',
      fontSize: 10,
      fontWeight: FontWeight.w400,
    ),
  );

  // ── Divider ────────────────────────────────────────────────────
  static const DividerThemeData _dividerThemeLight = DividerThemeData(
    color: AppColors.dividerLight,
    thickness: 1,
    space: 1,
  );

  static const DividerThemeData _dividerThemeDark = DividerThemeData(
    color: AppColors.dividerDark,
    thickness: 1,
    space: 1,
  );

  // ── Page Transitions ───────────────────────────────────────────
  static const PageTransitionsTheme _pageTransitionsTheme =
      PageTransitionsTheme(
    builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  );
}
