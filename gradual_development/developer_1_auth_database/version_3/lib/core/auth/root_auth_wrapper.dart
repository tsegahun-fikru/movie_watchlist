// lib/core/auth/root_auth_wrapper.dart
// Widget that bridges the auth state stream to GoRouter navigation.
// It shows the splash screen until both the minimum display time has elapsed
// and the Firebase auth state is known, then redirects accordingly.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:movie_watchlist/core/theme/app_colors.dart';
import 'package:movie_watchlist/features/auth/presentation/providers/auth_providers.dart';
import 'package:movie_watchlist/bootstrap/splash/splash_screen.dart';

/// Listens to [authStateProvider] and imperatively navigates to `/home` or
/// `/login` once the splash timer has elapsed.
///
/// Note: The primary auth-gating logic now lives in the GoRouter `redirect`
/// callback. This widget acts as a fallback / legacy entry point.
class RootAuthWrapper extends ConsumerStatefulWidget {
  const RootAuthWrapper({super.key});

  @override
  ConsumerState<RootAuthWrapper> createState() => _RootAuthWrapperState();
}

class _RootAuthWrapperState extends ConsumerState<RootAuthWrapper> {
  bool _splashElapsed = false;

  @override
  void initState() {
    super.initState();

    // Ensure splash shows for at least 2 seconds before redirecting
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _splashElapsed = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authStateAsync = ref.watch(authStateProvider);

    // Keep showing splash while the timer hasn't fired or auth is loading
    if (!_splashElapsed || authStateAsync.isLoading) {
      return const SplashScreen();
    }

    return authStateAsync.when(
      data: (user) {
        // Navigate after the current build frame to avoid setState-during-build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (user != null) {
            context.go('/home');
          } else {
            context.go('/login');
          }
        });

        // Show splash as a temporary placeholder while the navigation fires
        return const SplashScreen();
      },
      loading: () => const SplashScreen(),
      error: (error, stack) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error: $error',
                  style: const TextStyle(color: AppColors.error)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.refresh(authStateProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
