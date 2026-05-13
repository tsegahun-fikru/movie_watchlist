// lib/features/watched/presentation/providers/watched_providers.dart
// VERSION 2 - Riverpod providers with Firestore integration.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_watchlist/features/watchlist/presentation/providers/watchlist_providers.dart';
import 'package:movie_watchlist/features/watchlist/data/models/watchlist_item.dart';
import 'package:movie_watchlist/features/watched/data/services/watched_service.dart';

/// Provides WatchedService scoped to current user.
final watchedServiceProvider = Provider<WatchedService?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;
  
  final firestore = ref.watch(firestoreProvider);
  return WatchedService(firestore: firestore, userId: userId);
});

/// Real-time stream of watched items from Firestore.
/// TODO v3: Add error handling and retry logic
final watchedStreamProvider = StreamProvider<List<WatchlistItem>>((ref) {
  final service = ref.watch(watchedServiceProvider);
  if (service == null) return Stream.value([]);
  
  return service.getWatchedStream();
});
