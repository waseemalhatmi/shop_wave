import 'package:flutter/material.dart';

/// The complete color palette for ShopWave.
///
/// Design System: Vibrant Indigo primary, Coral Pink secondary.
/// Both light and dark palettes are defined here.
/// Never use raw Color(...) outside this file.
abstract final class AppColors {
  // ── Brand ──────────────────────────────────────────────────────
  /// Primary brand color — Vibrant Indigo
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF8B85FF);
  static const Color primaryLight = Color(0xFFEDECFF);

  /// Secondary accent — Coral Pink
  static const Color secondary = Color(0xFFFF6584);
  static const Color secondaryDark = Color(0xFFFF8FA3);
  static const Color secondaryLight = Color(0xFFFFECF0);

  // ── Neutrals (Light Mode) ─────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF5F5FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF0F0F8);
  static const Color onSurfaceLight = Color(0xFF1A1A2E);
  static const Color onSurfaceVariantLight = Color(0xFF6B6B7B);

  // ── Neutrals (Dark Mode) ──────────────────────────────────────
  static const Color backgroundDark = Color(0xFF0F0F1A);
  static const Color surfaceDark = Color(0xFF1A1A2E);
  static const Color surfaceVariantDark = Color(0xFF242438);
  static const Color onSurfaceDark = Color(0xFFF5F5FA);
  static const Color onSurfaceVariantDark = Color(0xFF9999AA);

  // ── Semantic ───────────────────────────────────────────────────
  static const Color error = Color(0xFFD32F2F);
  static const Color errorDark = Color(0xFFEF5350);
  static const Color onError = Color(0xFFFFFFFF);

  static const Color success = Color(0xFF388E3C);
  static const Color successDark = Color(0xFF66BB6A);
  static const Color successLight = Color(0xFFE8F5E9);

  static const Color warning = Color(0xFFF57C00);
  static const Color warningLight = Color(0xFFFFF3E0);

  static const Color info = Color(0xFF0288D1);
  static const Color infoLight = Color(0xFFE1F5FE);

  // ── Price / Commerce ───────────────────────────────────────────
  static const Color price = Color(0xFF1B5E20);
  static const Color originalPrice = Color(0xFF9E9E9E);
  static const Color badge = Color(0xFFFF6584);
  static const Color star = Color(0xFFFFB300);

  // ── Borders & Dividers ─────────────────────────────────────────
  static const Color borderLight = Color(0xFFE0E0EC);
  static const Color borderDark = Color(0xFF2E2E45);
  static const Color dividerLight = Color(0xFFF0F0F5);
  static const Color dividerDark = Color(0xFF252535);

  // ── Skeleton Loading ───────────────────────────────────────────
  static const Color skeletonBase = Color(0xFFE8E8F0);
  static const Color skeletonHighlight = Color(0xFFF5F5FA);
  static const Color skeletonBaseDark = Color(0xFF252535);
  static const Color skeletonHighlightDark = Color(0xFF2E2E45);

  // ── Shadows ────────────────────────────────────────────────────
  static const Color shadowLight = Color(0x1A6C63FF);
  static const Color shadowDark = Color(0x33000000);

  // ── Transparent ────────────────────────────────────────────────
  static const Color transparent = Colors.transparent;
  static const Color white = Colors.white;
  static const Color black = Colors.black;
}
