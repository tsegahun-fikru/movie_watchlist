// lib/core/auth/root_auth_wrapper.dart
// VERSION 1 - Simple wrapper. No Firebase. No GoRouter. No splash timer.
// Just checks a local bool to decide which screen to show.

import 'package:flutter/material.dart';
import 'package:movie_watchlist/features/auth/presentation/screens/login_screen.dart';

/// Simple auth wrapper - shows login screen if not logged in.
/// TODO v2: Replace with Firebase auth state stream + GoRouter redirect
class RootAuthWrapper extends StatelessWidget {
  final bool isLoggedIn;

  const RootAuthWrapper({super.key, this.isLoggedIn = false});

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn) {
      // TODO v2: Replace with actual home screen
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'Home Screen (Coming Soon)',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );
    }

    return const LoginScreen();
  }
}
