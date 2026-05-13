// lib/features/watchlist/presentation/providers/watchlist_providers.dart
// VERSION 1 - Simple state provider for in-memory watchlist.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_watchlist/features/watchlist/data/services/watchlist_service.dart';

/// Provides the watchlist service instance.
/// TODO v2: Make this user-specific with Firestore
final watchlistServiceProvider = Provider<WatchlistService>((ref) {
  return WatchlistService();
});

/// State provider that triggers UI rebuilds when watchlist changes.
/// TODO v2: Replace with StreamProvider for real-time Firestore updates
final watchlistChangeNotifierProvider = StateProvider<int>((ref) => 0);

/// Returns the current watchlist items.
final watchlistProvider = Provider<List<dynamic>>((ref) {
  // Watch the change notifier to trigger rebuilds
  ref.watch(watchlistChangeNotifierProvider);
  final service = ref.watch(watchlistServiceProvider);
  return service.getWatchlist();
});
