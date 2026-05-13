// lib/features/watchlist/data/models/watchlist_item.dart
// VERSION 1 - Simple wrapper for watchlist items. No Firestore serialization.

import 'package:movie_watchlist/shared/models/movie.dart';
import 'package:movie_watchlist/shared/models/tv_show.dart';

/// Wrapper class for watchlist items.
/// TODO v2: Add Firestore serialization methods
class WatchlistItem {
  final int id;
  final String type; // 'movie' or 'tv'
  final String title;
  final String posterPath;
  final double voteAverage;
  final dynamic originalItem; // Store the original Movie or TvShow

  WatchlistItem({
    required this.id,
    required this.type,
    required this.title,
    required this.posterPath,
    required this.voteAverage,
    required this.originalItem,
  });

  /// Creates a WatchlistItem from a Movie or TvShow.
  factory WatchlistItem.fromItem(dynamic item) {
    if (item is Movie) {
      return WatchlistItem(
        id: item.id,
        type: 'movie',
        title: item.title,
        posterPath: item.posterPath,
        voteAverage: item.voteAverage,
        originalItem: item,
      );
    } else if (item is TvShow) {
      return WatchlistItem(
        id: item.id,
        type: 'tv',
        title: item.name,
        posterPath: item.posterPath,
        voteAverage: item.voteAverage,
        originalItem: item,
      );
    }
    throw Exception('Unsupported item type');
  }

  /// Returns the original Movie or TvShow object.
  dynamic toOriginal() => originalItem;
}
