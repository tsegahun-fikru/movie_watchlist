// lib/features/watched/presentation/providers/watched_providers.dart
// VERSION 1 - Simple state provider for in-memory watched history.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_watchlist/features/watched/data/services/watched_service.dart';

/// Provides the watched service instance.
/// TODO v2: Make this user-specific with Firestore
final watchedServiceProvider = Provider<WatchedService>((ref) {
  return WatchedService();
});

/// State provider that triggers UI rebuilds when watched history changes.
/// TODO v2: Replace with StreamProvider for real-time Firestore updates
final watchedChangeNotifierProvider = StateProvider<int>((ref) => 0);

/// Returns the current watched items.
final watchedProvider = Provider<List<dynamic>>((ref) {
  // Watch the change notifier to trigger rebuilds
  ref.watch(watchedChangeNotifierProvider);
  final service = ref.watch(watchedServiceProvider);
  return service.getWatched();
});
