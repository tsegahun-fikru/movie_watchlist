// lib/features/watched/data/services/watched_service.dart
// Service layer for the watched history feature. Mirrors [WatchlistService]
// but persists to the `users/{uid}/watched` Firestore collection and adds
// user-rating support.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movie_watchlist/shared/models/movie.dart';
import 'package:movie_watchlist/shared/models/tv_show.dart';
import 'package:movie_watchlist/features/watchlist/data/models/watchlist_item.dart';

/// Manages the user's watched history in Firestore.
///
/// Reuses [WatchlistItem] as the data model since the document structure is
/// identical. Adds [setRating], [getRating], and [clearRating] for the
/// 1–5 star user rating feature.
class WatchedService {
  final FirebaseFirestore _firestore;
  final String _userId;

  WatchedService({
    required FirebaseFirestore firestore,
    required String userId,
  })  : _firestore = firestore,
        _userId = userId;

  // ─── Public stream of all watched items ───────────────────────────────────

  /// Returns a real-time stream of all watched items for the current user.
  Stream<List<WatchlistItem>> getWatchedStream() {
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

  /// Marks [item] as watched by saving it to the watched collection.
  Future<void> addItem(dynamic item) async {
    final (id, type, json) = extract(item);
    final docId = '${type}_$id';
    json['id'] = id;
    json['type'] = type;
    await _docRef(docId).set(json);
  }

  // ─── User rating ──────────────────────────────────────────────────────────

  /// Saves or updates the user's rating (1–5) for [item].
  Future<void> setRating(dynamic item, int rating) async {
    final (id, type, _) = extract(item);
    final docId = '${type}_$id';
    await _docRef(docId).update({'user_rating': rating});
  }

  /// Returns the user's rating for [item], or `null` if not yet rated.
  Future<int?> getRating(dynamic item) async {
    final (id, type, _) = extract(item);
    final doc = await _docRef('${type}_$id').get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>?;
    return data?['user_rating'] as int?;
  }

  /// Removes the user's rating for [item] using a Firestore field delete.
  Future<void> clearRating(dynamic item) async {
    final (id, type, _) = extract(item);
    final docId = '${type}_$id';
    await _docRef(docId).update({'user_rating': FieldValue.delete()});
  }

  // ─── Remove any item ──────────────────────────────────────────────────────

  /// Removes [item] from the watched history.
  Future<void> removeItem(dynamic item) async {
    final (id, type, _) = extract(item);
    final docId = '${type}_$id';
    await _docRef(docId).delete();
  }

  // ─── Check if item is in watched ──────────────────────────────────────────

  /// Returns `true` if [item] is in the watched history.
  Future<bool> isWatched(dynamic item) async {
    final (id, type, _) = extract(item);
    final doc = await _docRef('${type}_$id').get();
    return doc.exists;
  }

  // ─── Firestore references ─────────────────────────────────────────────────

  CollectionReference get _collectionRef =>
      _firestore.collection('users').doc(_userId).collection('watched');

  DocumentReference _docRef(String docId) => _collectionRef.doc(docId);

  // ─── Helper: extract id, type and Firestore JSON from Movie/TvShow ────────

  /// Extracts the id, type string, and serialised JSON from a Movie or TvShow.
  /// Exposed as a public method so [WatchedButton] can derive the docId.
  (int, String, Map<String, dynamic>) extract(dynamic item) {
    if (item is Movie) {
      return (item.id, 'movie', _movieToJson(item));
    } else if (item is TvShow) {
      return (item.id, 'tv', _tvShowToJson(item));
    }
    throw Exception('Unsupported type for watched');
  }

  // ─── JSON converters ──────────────────────────────────────────────────────

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
