// lib/features/watchlist/data/services/watchlist_service.dart
// VERSION 2 - Firestore-based watchlist service with basic error handling.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movie_watchlist/shared/models/movie.dart';
import 'package:movie_watchlist/shared/models/tv_show.dart';
import 'package:movie_watchlist/features/watchlist/data/models/watchlist_item.dart';

/// Manages the user's watchlist in Firestore.
/// TODO v3: Add optimistic updates, advanced error handling, offline support
class WatchlistService {
  final FirebaseFirestore _firestore;
  final String _userId;

  WatchlistService({
    required FirebaseFirestore firestore,
    required String userId,
  })  : _firestore = firestore,
        _userId = userId;

  /// Returns a real-time stream of all watchlist items.
  Stream<List<WatchlistItem>> getWatchlistStream() {
    return _collectionRef.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => WatchlistItem.fromFirestore(
                doc.id,
                doc.data() as Map<String, dynamic>,
              ))
          .toList(),
    );
  }

  /// Adds a movie or TV show to the watchlist.
  Future<void> addItem(dynamic item) async {
    final (id, type, json) = _extract(item);
    final docId = '${type}_$id';
    json['type'] = type;
    await _docRef(docId).set(json);
  }

  /// Removes an item from the watchlist.
  Future<void> removeItem(dynamic item) async {
    final (id, type, _) = _extract(item);
    final docId = '${type}_$id';
    await _docRef(docId).delete();
  }

  /// Checks if an item is in the watchlist.
  Future<bool> isInWatchlist(dynamic item) async {
    final (id, type, _) = _extract(item);
    final doc = await _docRef('${type}_$id').get();
    return doc.exists;
  }

  /// Removes an item by id and type.
  Future<void> removeById(int id, String type) async {
    await _docRef('${type}_$id').delete();
  }

  // Firestore references
  CollectionReference get _collectionRef =>
      _firestore.collection('users').doc(_userId).collection('watchlist');

  DocumentReference _docRef(String docId) => _collectionRef.doc(docId);

  // Helper to extract id, type, and JSON from Movie/TvShow
  (int, String, Map<String, dynamic>) _extract(dynamic item) {
    if (item is Movie) {
      return (item.id, 'movie', _movieToJson(item));
    } else if (item is TvShow) {
      return (item.id, 'tv', _tvShowToJson(item));
    }
    throw Exception('Unsupported type for watchlist');
  }

  // JSON converters
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
