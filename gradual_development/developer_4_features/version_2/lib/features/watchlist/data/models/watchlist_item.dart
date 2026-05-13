// lib/features/watchlist/data/models/watchlist_item.dart
// VERSION 2 - Watchlist item with Firestore serialization.

import 'package:movie_watchlist/shared/models/movie.dart';
import 'package:movie_watchlist/shared/models/tv_show.dart';

/// Represents a watchlist item stored in Firestore.
/// TODO v3: Add timestamp for sorting by date added
class WatchlistItem {
  final String id; // Firestore document ID (e.g., 'movie_123')
  final String type; // 'movie' or 'tv'
  final Map<String, dynamic> data; // Raw Firestore data

  WatchlistItem({
    required this.id,
    required this.type,
    required this.data,
  });

  /// Creates a WatchlistItem from Firestore document.
  factory WatchlistItem.fromFirestore(String docId, Map<String, dynamic> data) {
    return WatchlistItem(
      id: docId,
      type: data['type'] ?? 'movie',
      data: data,
    );
  }

  /// Returns the title (works for both movies and TV shows).
  String get title => data['title'] ?? data['name'] ?? '';

  /// Converts back to original Movie or TvShow object.
  dynamic toOriginal() {
    if (type == 'movie') {
      return Movie(
        id: int.parse(id.split('_')[1]),
        title: data['title'] ?? '',
        originalTitle: data['original_title'] ?? '',
        posterPath: data['poster_path'] ?? '',
        backdropPath: data['backdrop_path'] ?? '',
        releaseDate: data['release_date'] ?? '',
        voteAverage: (data['vote_average'] as num?)?.toDouble() ?? 0.0,
        voteCount: data['vote_count'] ?? 0,
        overview: data['overview'] ?? '',
        genreIds: (data['genre_ids'] as List?)?.cast<int>() ?? [],
        popularity: (data['popularity'] as num?)?.toDouble() ?? 0.0,
        originalLanguage: data['original_language'] ?? '',
      );
    } else {
      return TvShow(
        id: int.parse(id.split('_')[1]),
        name: data['name'] ?? '',
        originalName: data['original_name'] ?? '',
        posterPath: data['poster_path'] ?? '',
        backdropPath: data['backdrop_path'] ?? '',
        firstAirDate: data['first_air_date'] ?? '',
        voteAverage: (data['vote_average'] as num?)?.toDouble() ?? 0.0,
        voteCount: data['vote_count'] ?? 0,
        overview: data['overview'] ?? '',
        genreIds: (data['genre_ids'] as List?)?.cast<int>() ?? [],
        popularity: (data['popularity'] as num?)?.toDouble() ?? 0.0,
        originalLanguage: data['original_language'] ?? '',
        originCountry: (data['origin_country'] as List?)?.cast<String>() ?? [],
      );
    }
  }
}
