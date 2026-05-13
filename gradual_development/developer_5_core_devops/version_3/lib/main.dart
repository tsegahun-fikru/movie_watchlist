// lib/main.dart
// App entry point: initialises Firebase, wraps the widget tree in ProviderScope,
// and mounts MyApp which wires up routing, theming, and localisation.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:movie_watchlist/core/theme/app_theme.dart';

// Deep link service and startup
import 'package:movie_watchlist/bootstrap/app_startup.dart';

// Router
import 'package:movie_watchlist/app/router/app_router.dart';

// Localization
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:movie_watchlist/l10n/app_localizations.dart';
import 'package:movie_watchlist/core/localization/locale_provider.dart';

// No global navigator key here anymore, it's in app_router.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: MyApp()));
}

/// Custom scroll behaviour that uses [ClampingScrollPhysics] and removes
/// the default overscroll glow/stretch effect on all platforms.
class MyScrollBehavior extends MaterialScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child; // removes glow & stretch
  }
}

/// Root widget of the application.
///
/// Responsible for:
/// - Initialising [AppStartupController] (notifications, deep links)
/// - Starting the 3-second splash timer via [splashElapsedProvider]
/// - Building [MaterialApp.router] with the GoRouter, dark theme, and
///   localisation delegates.
class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});
  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late final AppStartupController _startupController;

  @override
  void initState() {
    super.initState();
    _startupController = AppStartupController();
    _startupController.initialize();

    // Flip splashElapsedProvider after 3 s so the router can redirect away
    // from the splash screen once both the timer and auth state are ready.
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        ref.read(splashElapsedProvider.notifier).state = true;
      }
    });
  }

  @override
  void dispose() {
    _startupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      scrollBehavior: MyScrollBehavior(),
      debugShowCheckedModeBanner: false,
      title: 'Movie Watchlist',
      theme: AppTheme.darkTheme,
      routerConfig: router,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
