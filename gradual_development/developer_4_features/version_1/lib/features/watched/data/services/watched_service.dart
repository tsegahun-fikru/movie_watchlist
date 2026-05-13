// lib/features/watched/data/services/watched_service.dart
// VERSION 1 - In-memory watched history service. No Firestore, no persistence.

import 'package:movie_watchlist/shared/models/movie.dart';
import 'package:movie_watchlist/shared/models/tv_show.dart';

/// Simple in-memory watched history service.
/// TODO v2: Replace with Firestore persistence and add user ratings
class WatchedService {
  // In-memory storage
  static final List<dynamic> _watched = [];

  /// Returns all watched items.
  List<dynamic> getWatched() {
    return List.from(_watched);
  }

  /// Marks a movie or TV show as watched.
  void addItem(dynamic item) {
    if (item is! Movie && item is! TvShow) {
      throw Exception('Only Movie or TvShow can be added');
    }

    // Check if already watched
    final exists = _watched.any((existing) {
      if (existing is Movie && item is Movie) {
        return existing.id == item.id;
      }
      if (existing is TvShow && item is TvShow) {
        return existing.id == item.id;
      }
      return false;
    });

    if (!exists) {
      _watched.add(item);
    }
  }

  /// Removes an item from watched history.
  void removeItem(dynamic item) {
    _watched.removeWhere((existing) {
      if (existing is Movie && item is Movie) {
        return existing.id == item.id;
      }
      if (existing is TvShow && item is TvShow) {
        return existing.id == item.id;
      }
      return false;
    });
  }

  /// Checks if an item is marked as watched.
  bool isWatched(dynamic item) {
    return _watched.any((existing) {
      if (existing is Movie && item is Movie) {
        return existing.id == item.id;
      }
      if (existing is TvShow && item is TvShow) {
        return existing.id == item.id;
      }
      return false;
    });
  }

  /// Clears all watched history.
  void clearAll() {
    _watched.clear();
  }
}
