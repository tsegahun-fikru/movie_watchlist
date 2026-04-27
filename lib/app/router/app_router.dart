import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:movie_watchlist/features/auth/presentation/providers/auth_providers.dart';
import 'package:movie_watchlist/app/navigation/main_navigation_wrapper.dart';
import 'package:movie_watchlist/features/auth/presentation/screens/login_screen.dart';
import 'package:movie_watchlist/features/auth/presentation/screens/signup_screen.dart';
import 'package:movie_watchlist/features/home/presentation/screens/home_screen.dart';
import 'package:movie_watchlist/features/watchlist/presentation/screens/watchlist_screen.dart';
import 'package:movie_watchlist/features/about/presentation/screens/about_screen.dart';
import 'package:movie_watchlist/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:movie_watchlist/features/profile/presentation/screens/profile_screen.dart';
import 'package:movie_watchlist/features/movie_details/presentation/screens/deep_link_movie_loader.dart';
import 'package:movie_watchlist/features/movie_details/presentation/screens/details_screen.dart';
import 'package:movie_watchlist/features/home/presentation/widgets/movie_search_delegate.dart';
import 'package:movie_watchlist/bootstrap/splash/splash_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final splashElapsedProvider = StateProvider<bool>((ref) => false);

final routerProvider = Provider<GoRouter>((ref) {
  final authStateAsync = ref.watch(authStateProvider);
  final isSplashElapsed = ref.watch(splashElapsedProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      if (!isSplashElapsed || authStateAsync.isLoading) {
        return state.uri.path == '/' ? null : '/';
      }
      
      final isAuth = authStateAsync.valueOrNull != null;
      final isLoggingIn = state.uri.path == '/login' || state.uri.path == '/signup';
      
      if (!isAuth) {
        return isLoggingIn ? null : '/login';
      }
      
      if (isLoggingIn || state.uri.path == '/') {
        return '/home';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
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
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/about',
                builder: (context, state) => const AboutScreen(),
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
        path: '/search',
        builder: (context, state) => const MovieSearchScreen(),
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
    ],
  );
});
