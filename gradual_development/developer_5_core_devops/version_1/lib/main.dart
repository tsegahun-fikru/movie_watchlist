// lib/main.dart
// VERSION 1 - Simple MaterialApp with basic home screen. No routing, no Firebase.

import 'package:flutter/material.dart';

/// Simple app entry point.
/// TODO v2: Add ProviderScope, Firebase initialization, GoRouter
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Watchlist',
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}

/// Simple home screen placeholder.
/// TODO v2: Replace with proper navigation structure
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie Watchlist'),
      ),
      body: const Center(
        child: Text(
          'Welcome to Movie Watchlist!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
