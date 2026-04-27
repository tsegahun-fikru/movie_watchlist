import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:movie_watchlist/core/theme/app_colors.dart';
import 'package:movie_watchlist/features/auth/presentation/providers/auth_providers.dart';
import 'package:movie_watchlist/bootstrap/splash/splash_screen.dart';

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

    // Ensure splash shows at least 2 seconds
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _splashElapsed = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authStateAsync = ref.watch(authStateProvider);

    if (!_splashElapsed || authStateAsync.isLoading) {
      return const SplashScreen();
    }

    return authStateAsync.when(
      data: (user) {
        // Navigate AFTER build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (user != null) {
            context.go('/home');
          } else {
            context.go('/login');
          }
        });

        return const SplashScreen(); // temporary UI
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