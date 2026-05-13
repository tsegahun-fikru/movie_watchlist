// lib/app/router/app_router.dart
// VERSION 2 - Basic GoRouter configuration with main navigation.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_watchlist/app/navigation/main_navigation_wrapper.dart';

/// GoRouter provider.
/// TODO v3: Add auth guards, deep links, error handling
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const MainNavigationWrapper(),
      ),
    ],
  );
});
