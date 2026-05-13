// lib/features/watched/presentation/providers/watched_providers.dart
// Riverpod providers that expose the watched service and its real-time stream.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_watchlist/core/providers/core_providers.dart';
import 'package:movie_watchlist/features/auth/presentation/providers/auth_providers.dart';
import 'package:movie_watchlist/features/watchlist/data/models/watchlist_item.dart';
import 'package:movie_watchlist/features/watched/data/services/watched_service.dart';

/// Provides a [WatchedService] scoped to the current user.
/// Returns `null` when no user is signed in.
final watchedServiceProvider = Provider<WatchedService?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;
  final firestore = ref.watch(firestoreProvider);
  return WatchedService(firestore: firestore, userId: userId);
});

/// Real-time stream of the current user's watched history.
/// Emits an empty list when the user is signed out.
final watchedStreamProvider = StreamProvider<List<WatchlistItem>>((ref) {
  final service = ref.watch(watchedServiceProvider);
  if (service == null) return Stream.value([]);
  return service.getWatchedStream();
});

/// Returns the user's rating (1–5) for a specific item identified by [docId],
/// or `null` if the item has not been rated.
///
/// Derived from the already-live [watchedStreamProvider] — no extra Firestore
/// reads are needed.
final userRatingProvider =
    Provider.family<int?, String>((ref, docId) {
  final items = ref.watch(watchedStreamProvider).valueOrNull ?? [];
  final match = items.where((i) => i.docId == docId).firstOrNull;
  if (match == null) return null;
  return match.data['user_rating'] as int?;
});
