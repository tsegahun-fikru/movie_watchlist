// lib/features/watched/presentation/providers/watched_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_watchlist/core/providers/core_providers.dart';
import 'package:movie_watchlist/features/auth/presentation/providers/auth_providers.dart';
import 'package:movie_watchlist/features/watchlist/data/models/watchlist_item.dart';
import 'package:movie_watchlist/features/watched/data/services/watched_service.dart';

final watchedServiceProvider = Provider<WatchedService?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;
  final firestore = ref.watch(firestoreProvider);
  return WatchedService(firestore: firestore, userId: userId);
});

final watchedStreamProvider = StreamProvider<List<WatchlistItem>>((ref) {
  final service = ref.watch(watchedServiceProvider);
  if (service == null) return Stream.value([]);
  return service.getWatchedStream();
});
