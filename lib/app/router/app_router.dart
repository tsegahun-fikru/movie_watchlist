// lib/app/router/app_router.dart
// Defines the GoRouter configuration, all named routes, and auth-gated
// redirect logic. The router is exposed as [routerProvider].

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:movie_watchlist/features/auth/presentation/providers/auth_providers.dart';
import 'package:movie_watchlist/app/navigation/main_navigation_wrapper.dart';
import 'package:movie_watchlist/features/auth/presentation/screens/login_screen.dart';
import 'package:movie_watchlist/features/auth/presentation/screens/signup_screen.dart';
import 'package:movie_watchlist/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:movie_watchlist/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:movie_watchlist/features/auth/presentation/screens/change_password_screen.dart';
import 'package:movie_watchlist/features/home/presentation/screens/home_screen.dart';
import 'package:movie_watchlist/features/watchlist/presentation/screens/watchlist_screen.dart';
import 'package:movie_watchlist/features/about/presentation/screens/about_screen.dart';
import 'package:movie_watchlist/features/watched/presentation/screens/watched_screen.dart';
import 'package:movie_watchlist/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:movie_watchlist/features/profile/presentation/screens/profile_screen.dart';
import 'package:movie_watchlist/features/movie_details/presentation/screens/deep_link_media_loader.dart';
import 'package:movie_watchlist/features/movie_details/presentation/screens/deep_link_movie_loader.dart';
import 'package:movie_watchlist/features/movie_details/presentation/screens/details_screen.dart';
import 'package:movie_watchlist/features/home/presentation/widgets/movie_search_delegate.dart';
import 'package:movie_watchlist/features/movies/presentation/screens/genre_browse_screen.dart';
import 'package:movie_watchlist/bootstrap/splash/splash_screen.dart';

/// Root navigator key used by GoRouter and [NotificationService] for
/// imperative navigation (e.g. tapping a push notification).
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Becomes `true` after the 3-second splash timer fires in [MyApp].
/// The router's redirect waits for this before leaving the splash screen.
final splashElapsedProvider = StateProvider<bool>((ref) => false);

/// Tracks whether onboarding has been completed (loaded once at startup).
/// Defaults to `true` so returning users are never shown onboarding again.
final onboardingCompleteProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('onboarding_complete') ?? false;
});

/// The main [GoRouter] provider.
///
/// The `redirect` callback enforces the following flow:
/// 1. Show splash until both the timer and auth state are ready.
/// 2. Unauthenticated users are sent to onboarding (first launch) or login.
/// 3. Authenticated users are redirected away from auth/splash routes to home.
final routerProvider = Provider<GoRouter>((ref) {
  final authStateAsync = ref.watch(authStateProvider);
  final isSplashElapsed = ref.watch(splashElapsedProvider);
  final onboardingAsync = ref.watch(onboardingCompleteProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      // Keep showing splash while timer hasn't fired or auth is still loading
      if (!isSplashElapsed || authStateAsync.isLoading) {
        return state.uri.path == '/' ? null : '/';
      }

      final isAuth = authStateAsync.valueOrNull != null;
      final path = state.uri.path;
      final isLoggingIn = path == '/login' || path == '/signup';
      final isOnboarding = path == '/onboarding';

      if (!isAuth) {
        // First-time users see onboarding before the login screen
        final onboardingDone = onboardingAsync.valueOrNull ?? true;
        if (!onboardingDone && !isOnboarding && !isLoggingIn) {
          return '/onboarding';
        }
        return isLoggingIn || isOnboarding ? null : '/login';
      }

      // Authenticated users should not land on auth or splash routes
      if (isLoggingIn || isOnboarding || path == '/') {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      // Bottom-nav shell — keeps tab state alive via indexedStack
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavigationWrapper(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) => const MovieSearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/watchlist',
                builder: (context, state) => const WatchlistScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/watched',
        builder: (context, state) => const WatchedScreen(),
      ),
      GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
      // Detail screen — item (Movie or TvShow) is passed via `extra`
      GoRoute(
        path: '/details/:type/:id',
        builder: (context, state) {
          final type = state.pathParameters['type'];
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if ((type == 'movie' || type == 'tv') && id != null) {
            return DeepLinkMediaLoader(type: type!, id: id);
          }
          return const Scaffold(body: Center(child: Text('Invalid item ID')));
        },
      ),
      GoRoute(
        path: '/details',
        builder: (context, state) {
          final item = state.extra;
          if (item != null) {
            return DetailScreen(item: item);
          }
          return const Scaffold(body: Center(child: Text('Item missing')));
        },
      ),
      // Deep-link route: /movie/:id — fetches movie by ID then shows details
      GoRoute(
        path: '/movie/:id',
        builder: (context, state) {
          final idStr = state.pathParameters['id'];
          final id = int.tryParse(idStr ?? '');
          if (id != null) {
            return DeepLinkMovieLoader(movieId: id);
          }
          return const Scaffold(body: Center(child: Text('Invalid movie ID')));
        },
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      // Genre browse — genreId and genreName are passed via `extra` map
      GoRoute(
        path: '/genre-browse',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return GenreBrowseScreen(
            genreId: extra['genreId'] as int,
            genreName: extra['genreName'] as String,
          );
        },
      ),
    ],
  );
});
