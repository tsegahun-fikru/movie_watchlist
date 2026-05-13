// lib/app/navigation/main_navigation_wrapper.dart
// Bottom-navigation shell that wraps the four main tab branches (Home, Search,
// Watchlist, Profile) and shows a live badge on the Watchlist tab.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_watchlist/core/theme/app_colors.dart';
import 'package:movie_watchlist/features/watchlist/presentation/providers/watchlist_providers.dart';
import 'package:go_router/go_router.dart';

/// Hosts the [StatefulNavigationShell] provided by GoRouter's
/// [StatefulShellRoute.indexedStack] and renders the persistent bottom nav bar.
class MainNavigationWrapper extends ConsumerWidget {
  const MainNavigationWrapper({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  /// Navigate to [index], restoring the branch's initial location when the
  /// user taps the already-active tab (pop-to-root behaviour).
  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the live watchlist count to update the badge in real time
    final watchlistAsync = ref.watch(watchlistStreamProvider);
    final count = watchlistAsync.valueOrNull?.length ?? 0;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _goBranch,
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          // Watchlist tab shows a count badge when the list is non-empty
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: count > 0,
              label: Text('$count'),
              child: const Icon(Icons.bookmark),
            ),
            label: 'Watchlist',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
