import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_watchlist/core/providers/core_providers.dart';
import 'package:movie_watchlist/features/auth/presentation/providers/auth_providers.dart';
import 'package:movie_watchlist/features/watchlist/data/models/watchlist_item.dart';
import 'package:movie_watchlist/features/watchlist/data/services/watchlist_service.dart';

final watchlistServiceProvider = Provider<WatchlistService?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;
  final firestore = ref.watch(firestoreProvider);
  return WatchlistService(firestore: firestore, userId: userId);
});

final watchlistStreamProvider = StreamProvider<List<WatchlistItem>>((ref) {
  final service = ref.watch(watchlistServiceProvider);
  if (service == null) return Stream.value([]);
  return service.getWatchlistStream();
});
