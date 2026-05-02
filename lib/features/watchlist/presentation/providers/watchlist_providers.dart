// lib/features/watchlist/presentation/providers/watchlist_providers.dart
// Riverpod providers that expose the watchlist service and its real-time
// stream to the presentation layer.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_watchlist/core/providers/core_providers.dart';
import 'package:movie_watchlist/features/auth/presentation/providers/auth_providers.dart';
import 'package:movie_watchlist/features/watchlist/data/models/watchlist_item.dart';
import 'package:movie_watchlist/features/watchlist/data/services/watchlist_service.dart';

/// Provides a [WatchlistService] scoped to the current user.
/// Returns `null` when no user is signed in so callers can guard accordingly.
final watchlistServiceProvider = Provider<WatchlistService?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;
  final firestore = ref.watch(firestoreProvider);
  return WatchlistService(firestore: firestore, userId: userId);
});

/// Real-time stream of the current user's watchlist items.
/// Emits an empty list when the user is signed out.
final watchlistStreamProvider = StreamProvider<List<WatchlistItem>>((ref) {
  final service = ref.watch(watchlistServiceProvider);
  if (service == null) return Stream.value([]);
  return service.getWatchlistStream();
});
