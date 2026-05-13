// lib/features/watchlist/data/models/watchlist_item.dart
// Lightweight model used by [WatchlistService] and [WatchedService] to
// represent a saved item (movie or TV show) from Firestore.

import 'package:movie_watchlist/shared/models/movie.dart';
import 'package:movie_watchlist/shared/models/tv_show.dart';

/// Represents a single item in the user's watchlist or watched history.
///
/// The [type] field distinguishes movies (`'movie'`) from TV shows (`'tv'`).
/// [data] holds the raw Firestore document map so the original model can be
/// reconstructed via [toOriginal].
class WatchlistItem {
  final int id;

  /// `'movie'` or `'tv'`
  final String type;

  /// Raw Firestore document data. Used to reconstruct the original model.
  final Map<String, dynamic> data;

  const WatchlistItem({
    required this.id,
    required this.type,
    required this.data,
  });

  /// Constructs a [WatchlistItem] from a Firestore document.
  ///
  /// [docId] format is `'movie_123'` or `'tv_456'`.
  /// Legacy documents used numeric-only IDs (e.g. `'12345'`) and are treated
  /// as movies for backwards compatibility.
  factory WatchlistItem.fromFirestore(String docId, Map<String, dynamic> json) {
    int id;
    String type;

    // Legacy support: old docs had numeric-only IDs like "12345"
    if (!docId.contains('_')) {
      id = int.parse(docId);
      type = 'movie';
    } else {
      final parts = docId.split('_');
      id = int.parse(parts.last);
      type = parts.first;
    }

    // Inject the id into the data map so Movie/TvShow.fromJson can read it
    json['id'] = id;

    return WatchlistItem(id: id, type: type, data: json);
  }

  /// Reconstructs the original [Movie] or [TvShow] from [data].
  Object toOriginal() {
    if (type == 'movie') {
      return Movie.fromJson(data);
    } else if (type == 'tv') {
      return TvShow.fromJson(data);
    }
    // Fallback — should never be reached with the id injection above
    return Movie.fromJson(data);
  }

  /// The display title extracted from [data].
  String get title {
    if (type == 'movie') return data['title'] ?? '';
    if (type == 'tv') return data['name'] ?? '';
    return '';
  }

  /// The Firestore document ID in `'type_id'` format.
  String get docId => '${type}_$id';
}
