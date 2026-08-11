import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_constants.dart';

// ── Supabase ──────────────────────────────────────────────────────────────

/// Provides the Supabase client — used by all data sources.
final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

// ── SharedPreferences ─────────────────────────────────────────────────────

/// Provides SharedPreferences — initialized before app starts.
/// Override with [sharedPreferencesProvider.overrideWithValue(prefs)]
/// in ProviderScope.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Override in ProviderScope'),
);

// ── Theme ─────────────────────────────────────────────────────────────────

/// Controls the app's theme mode (light/dark/system). Persists to SharedPreferences.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final saved = prefs.getString(AppConstants.keyThemeMode);
    return switch (saved) {
      'light' => ThemeMode.light,
      'dark'  => ThemeMode.dark,
      _       => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(AppConstants.keyThemeMode, mode.name);
    state = mode;
  }

  void toggle() => setThemeMode(
    state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light,
  );
}

final themeModeNotifierProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

// ── Locale ────────────────────────────────────────────────────────────────

/// Controls the app's locale (en/ar). Persists to SharedPreferences.
class LocaleNotifier extends Notifier<Locale> {
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

final localeNotifierProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);
