// lib/app/navigation/main_navigation_wrapper.dart
// VERSION 2 - Bottom navigation bar with basic screens.

import 'package:flutter/material.dart';

/// Main navigation wrapper with bottom navigation bar.
/// TODO v3: Add proper screen routing, preserve state
class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _HomeScreen(),
    const _WatchlistScreen(),
    const _WatchedScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.black,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Watchlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Watched',
          ),
        ],
      ),
    );
  }
}

// Placeholder screens
class _HomeScreen extends StatelessWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text('Home Screen')),
    );
  }
}

class _WatchlistScreen extends StatelessWidget {
  const _WatchlistScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Watchlist')),
      body: const Center(child: Text('Watchlist Screen')),
    );
  }
}

class _WatchedScreen extends StatelessWidget {
  const _WatchedScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Watched')),
      body: const Center(child: Text('Watched Screen')),
    );
  }
}
