import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_constants.dart';

part 'providers.g.dart';

// ── Supabase ──────────────────────────────────────────────────────────────

/// Provides the Supabase client — used by all data sources.
///
/// Why a provider instead of Supabase.instance.client directly?
/// - Testable: we can override this in tests with a mock client
/// - Consistent: no global state access scattered across the codebase
/// - Explicit: dependencies are visible and traceable
@Riverpod(keepAlive: true)
SupabaseClient supabaseClient(Ref ref) => Supabase.instance.client;

// ── SharedPreferences ─────────────────────────────────────────────────────

/// Provides SharedPreferences — initialized before app starts.
///
/// Must be initialized in main.dart before runApp().
/// Override with [sharedPreferencesProvider.overrideWithValue(prefs)]
/// in ProviderScope.
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(Ref ref) =>
    throw UnimplementedError('Override in ProviderScope');

// ── Theme ─────────────────────────────────────────────────────────────────

/// Controls the app's theme mode (light/dark/system).
///
/// Persists to SharedPreferences on change.
@Riverpod(keepAlive: true)
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final saved = prefs.getString(AppConstants.keyThemeMode);
    return switch (saved) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(
      AppConstants.keyThemeMode,
      mode.name, // 'light', 'dark', or 'system'
    );
    state = mode;
  }

  void toggle() => setThemeMode(
        state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light,
      );
}

// ── Locale ────────────────────────────────────────────────────────────────

/// Controls the app's locale (en/ar).
///
/// Persists to SharedPreferences on change.
/// Changing locale triggers RTL/LTR switch automatically.
@Riverpod(keepAlive: true)
class LocaleNotifier extends _$LocaleNotifier {
  @override
  Locale build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final saved = prefs.getString(AppConstants.keyLocale);
    return Locale(saved ?? 'en');
  }

  Future<void> setLocale(String languageCode) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(AppConstants.keyLocale, languageCode);
    state = Locale(languageCode);
  }
}
