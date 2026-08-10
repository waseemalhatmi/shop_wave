import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/config/app_config.dart';
import 'core/di/providers.dart';
import 'core/l10n/generated/app_localizations.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// Root application widget.
///
/// Why [ConsumerStatefulWidget]?
/// We need a stable [GoRouter] instance (created once in [initState]) that
/// holds a [refreshListenable] tied to auth state. Using a StatefulWidget
/// prevents the router from being recreated on every build.
class ShopWaveApp extends ConsumerStatefulWidget {
  const ShopWaveApp({super.key});

  @override
  ConsumerState<ShopWaveApp> createState() => _ShopWaveAppState();
}

class _ShopWaveAppState extends ConsumerState<ShopWaveApp> {
  GoRouter? _router;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Create the router only once, using the ProviderContainer from the
    // nearest ProviderScope. didChangeDependencies has access to context.
    _router ??= AppRouter.createRouter(
      ProviderScope.containerOf(context, listen: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch theme and locale — rebuilds MaterialApp.router when they change
    final themeMode = ref.watch(themeModeNotifierProvider);
    final locale = ref.watch(localeNotifierProvider);

    if (_router == null) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp.router(
      // ── App Identity ───────────────────────────────────────────
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,

      // ── Routing ────────────────────────────────────────────────
      routerConfig: _router!,

      // ── Theme ──────────────────────────────────────────────────
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,

      // ── Localization ───────────────────────────────────────────
      locale: locale,
      supportedLocales: const [
        Locale('en'), // English
        Locale('ar'), // Arabic (RTL)
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ── Builder: applies text scale factor cap ─────────────────
      builder: (context, child) {
        // Cap text scaling to prevent layout overflow on accessibility settings
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(
              mediaQuery.textScaler.scale(1.0).clamp(0.8, 1.3),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
