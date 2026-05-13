// lib/main.dart
// VERSION 2 - MaterialApp with GoRouter and Firebase initialization.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_watchlist/core/theme/app_theme.dart';
import 'package:movie_watchlist/app/router/app_router.dart';
import 'package:movie_watchlist/firebase_options.dart';

/// App entry point with Firebase and Riverpod.
/// TODO v3: Add splash screen, localization, deep links
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const ProviderScope(child: MyApp()));
}

/// Root app widget with GoRouter.
/// TODO v3: Add localization delegates, custom scroll behavior
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Movie Watchlist',
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
