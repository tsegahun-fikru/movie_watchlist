import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:movie_watchlist/core/theme/app_theme.dart';

// Deep link service and startup
import 'package:movie_watchlist/bootstrap/app_startup.dart';

// Router
import 'package:movie_watchlist/app/router/app_router.dart';

// No global navigator key here anymore, it's in app_router.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: MyApp()));
}

// ... MyScrollBehavior unchanged ...
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

    return MaterialApp.router(
      scrollBehavior: MyScrollBehavior(),
      debugShowCheckedModeBanner: false,
      title: 'Movie Watchlist',
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
