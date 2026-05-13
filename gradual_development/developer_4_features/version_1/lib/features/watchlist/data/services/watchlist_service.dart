// lib/features/watchlist/data/services/watchlist_service.dart
// VERSION 1 - In-memory watchlist service. No Firestore, no persistence.

import 'package:movie_watchlist/shared/models/movie.dart';
import 'package:movie_watchlist/shared/models/tv_show.dart';

/// Simple in-memory watchlist service.
/// TODO v2: Replace with Firestore persistence
class WatchlistService {
  // In-memory storage
  static final List<dynamic> _watchlist = [];

  /// Returns all watchlist items.
  List<dynamic> getWatchlist() {
    return List.from(_watchlist);
  }

  /// Adds a movie or TV show to the watchlist.
  void addItem(dynamic item) {
    if (item is! Movie && item is! TvShow) {
      throw Exception('Only Movie or TvShow can be added');
    }
    
    // Check if already in watchlist
    final exists = _watchlist.any((existing) {
      if (existing is Movie && item is Movie) {
        return existing.id == item.id;
      }
      if (existing is TvShow && item is TvShow) {
        return existing.id == item.id;
      }
      return false;
    });

    if (!exists) {
      _watchlist.add(item);
    }
  }

  /// Removes a movie or TV show from the watchlist.
  void removeItem(dynamic item) {
    _watchlist.removeWhere((existing) {
      if (existing is Movie && item is Movie) {
        return existing.id == item.id;
      }
      if (existing is TvShow && item is TvShow) {
        return existing.id == item.id;
      }
      return false;
    });
  }

  /// Checks if an item is in the watchlist.
  bool isInWatchlist(dynamic item) {
    return _watchlist.any((existing) {
      if (existing is Movie && item is Movie) {
        return existing.id == item.id;
      }
      if (existing is TvShow && item is TvShow) {
        return existing.id == item.id;
      }
      return false;
    });
  }

  /// Clears all items from the watchlist.
  void clearAll() {
    _watchlist.clear();
  }
}
