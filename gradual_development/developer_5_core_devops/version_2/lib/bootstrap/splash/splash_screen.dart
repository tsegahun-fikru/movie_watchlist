// lib/bootstrap/splash/splash_screen.dart
// VERSION 2 - Simple splash screen.

import 'package:flutter/material.dart';

/// Simple splash screen.
/// TODO v3: Add animated logo, loading indicator
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.movie, size: 80, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Movie Watchlist',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
