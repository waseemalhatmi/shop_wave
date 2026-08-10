import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'core/config/app_constants.dart';
import 'core/config/supabase_config.dart';
import 'core/di/providers.dart';
import 'core/utils/app_logger.dart';

/// Application entry point.
///
/// Initialization order matters:
/// 1. Logger (first — we need logging ASAP)
/// 2. Flutter bindings (required before any async work)
/// 3. Hive (local database)
/// 4. SharedPreferences
/// 5. Supabase (validates config, connects to backend)
/// 6. runApp with ProviderScope (providers initialized)
///
/// Why async main()?
/// Supabase.initialize() and SharedPreferences.getInstance() are async.
/// We need them ready BEFORE the first widget builds.
Future<void> main() async {
  // ── 1. Initialize logger (no dependencies) ──────────────────────
  AppLogger.init();
  AppLogger.i('ShopWave starting up...');

  // ── 2. Ensure Flutter bindings are initialized ──────────────────
  WidgetsFlutterBinding.ensureInitialized();

  // ── 3. Initialize Hive local database ──────────────────────────
  await Hive.initFlutter();
  AppLogger.d('Hive initialized');

  // ── 4. Initialize SharedPreferences ────────────────────────────
  final prefs = await SharedPreferences.getInstance();
  AppLogger.d('SharedPreferences initialized');

  // ── 5. Initialize Supabase ─────────────────────────────────────
  // Validates env vars are present (asserts in debug mode)
  SupabaseConfig.validate();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
    debug: false,
  );
  AppLogger.i('Supabase initialized. Project: ${SupabaseConfig.url}');

  // Open Hive boxes needed at startup
  await _openHiveBoxes();

  // ── 6. Run app ─────────────────────────────────────────────────
  runApp(
    ProviderScope(
      overrides: [
        // Inject SharedPreferences so providers can access it synchronously.
        // This is the recommended pattern for async-initialized dependencies.
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const ShopWaveApp(),
    ),
  );

  AppLogger.i('ShopWave started successfully');
}

/// Opens all required Hive boxes at startup.
Future<void> _openHiveBoxes() async {
  await Future.wait([
    Hive.openBox<dynamic>(AppConstants.productsBox),
    Hive.openBox<dynamic>(AppConstants.categoriesBox),
    Hive.openBox<dynamic>(AppConstants.userBox),
    Hive.openBox<dynamic>(AppConstants.cartBox),
  ]);
  AppLogger.d('Hive boxes opened: products, categories, user, cart');
}
