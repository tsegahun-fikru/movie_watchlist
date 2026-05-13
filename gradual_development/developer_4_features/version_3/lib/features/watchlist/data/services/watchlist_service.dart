// lib/features/watchlist/data/services/watchlist_service.dart
// Service layer used by the watchlist feature's Riverpod providers.
// Reads and writes to the `users/{uid}/watchlist` Firestore collection and
// supports both Movie and TvShow items.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movie_watchlist/shared/models/movie.dart';
import 'package:movie_watchlist/shared/models/tv_show.dart';
import 'package:movie_watchlist/features/watchlist/data/models/watchlist_item.dart';

/// Manages the user's watchlist in Firestore.
///
/// Document IDs follow the `'type_id'` convention (e.g. `'movie_123'`,
/// `'tv_456'`) to support both movies and TV shows in the same collection.
class WatchlistService {
  final FirebaseFirestore _firestore;
  final String _userId;

  WatchlistService({
    required FirebaseFirestore firestore,
    required String userId,
  }) : _firestore = firestore,
       _userId = userId;

  // ─── Public stream of all watchlist items ─────────────────────────────────

  /// Returns a real-time stream of all watchlist items for the current user.
  Stream<List<WatchlistItem>> getWatchlistStream() {
    return _collectionRef.snapshots().map(
      (snapshot) => snapshot.docs
          .map(
            (doc) => WatchlistItem.fromFirestore(
              doc.id,
              doc.data() as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  // ─── Add any item (Movie or TvShow) ───────────────────────────────────────

  /// Saves [item] (Movie or TvShow) to the watchlist.
  Future<void> addItem(dynamic item) async {
    final (id, type, json) = _extract(item);
    final docId = '${type}_$id';
    json['type'] = type; // store type inside doc for convenience
    await _docRef(docId).set(json);
  }

  // ─── Remove any item ──────────────────────────────────────────────────────

  /// Removes [item] (Movie or TvShow) from the watchlist.
  Future<void> removeItem(dynamic item) async {
    final (id, type, _) = _extract(item);
    final docId = '${type}_$id';
    await _docRef(docId).delete();
  }

  // ─── Check if item is in watchlist ────────────────────────────────────────

  /// Returns `true` if [item] is currently in the watchlist.
  Future<bool> isInWatchlist(dynamic item) async {
    final (id, type, _) = _extract(item);
    final doc = await _docRef('${type}_$id').get();
    return doc.exists;
  }

  // ─── Convenience: remove by id+type ──────────────────────────────────────

  /// Removes an item by its [id] and [type] without needing the full object.
  Future<void> removeById(int id, String type) async {
    await _docRef('${type}_$id').delete();
  }

  // ─── Firestore references ─────────────────────────────────────────────────

  CollectionReference get _collectionRef =>
      _firestore.collection('users').doc(_userId).collection('watchlist');

  DocumentReference _docRef(String docId) => _collectionRef.doc(docId);

  // ─── Helper: extract id, type and Firestore JSON from Movie/TvShow ────────

  /// Extracts the id, type string, and serialised JSON from a Movie or TvShow.
  /// Throws if [item] is neither.
  (int, String, Map<String, dynamic>) _extract(dynamic item) {
    if (item is Movie) {
      return (item.id, 'movie', _movieToJson(item));
    } else if (item is TvShow) {
      return (item.id, 'tv', _tvShowToJson(item));
    }
    throw Exception('Unsupported type for watchlist');
  }

  // ─── JSON converters ──────────────────────────────────────────────────────

  /// Serialises a [Movie] to a Firestore-compatible map.
  /// Note: genres, runtime, cast, and trailerKey are intentionally omitted —
  /// they are fetched fresh from TMDB on the detail screen.
  Map<String, dynamic> _movieToJson(Movie movie) {
    return {
      'title': movie.title,
      'original_title': movie.originalTitle,
      'poster_path': movie.posterPath,
      'backdrop_path': movie.backdropPath,
      'release_date': movie.releaseDate,
      'vote_average': movie.voteAverage,
      'vote_count': movie.voteCount,
      'overview': movie.overview,
      'genre_ids': movie.genreIds,
      'popularity': movie.popularity,
      'original_language': movie.originalLanguage,
    };
  }

  /// Serialises a [TvShow] to a Firestore-compatible map.
  Map<String, dynamic> _tvShowToJson(TvShow tvShow) {
    return {
      'name': tvShow.name,
      'original_name': tvShow.originalName,
      'poster_path': tvShow.posterPath,
      'backdrop_path': tvShow.backdropPath,
      'first_air_date': tvShow.firstAirDate,
      'vote_average': tvShow.voteAverage,
      'vote_count': tvShow.voteCount,
      'overview': tvShow.overview,
      'genre_ids': tvShow.genreIds,
      'popularity': tvShow.popularity,
      'original_language': tvShow.originalLanguage,
      'origin_country': tvShow.originCountry,
    };
  }
}
