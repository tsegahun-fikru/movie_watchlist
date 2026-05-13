// lib/features/watched/data/services/watched_service.dart
// VERSION 2 - Firestore-based watched service with user ratings.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movie_watchlist/shared/models/movie.dart';
import 'package:movie_watchlist/shared/models/tv_show.dart';
import 'package:movie_watchlist/features/watchlist/data/models/watchlist_item.dart';

/// Manages the user's watched history in Firestore with rating support.
/// TODO v3: Add advanced error handling, offline support
class WatchedService {
  final FirebaseFirestore _firestore;
  final String _userId;

  WatchedService({
    required FirebaseFirestore firestore,
    required String userId,
  })  : _firestore = firestore,
        _userId = userId;

  /// Returns a real-time stream of all watched items.
  Stream<List<WatchlistItem>> getWatchedStream() {
    return _collectionRef.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => WatchlistItem.fromFirestore(
                doc.id,
                doc.data() as Map<String, dynamic>,
              ))
          .toList(),
    );
  }

  /// Marks an item as watched.
  Future<void> addItem(dynamic item) async {
    final (id, type, json) = extract(item);
    final docId = '${type}_$id';
    json['id'] = id;
    json['type'] = type;
    await _docRef(docId).set(json);
  }

  /// Sets user rating (1-5 stars) for an item.
  Future<void> setRating(dynamic item, int rating) async {
    if (rating < 1 || rating > 5) {
      throw Exception('Rating must be between 1 and 5');
    }
    final (id, type, _) = extract(item);
    final docId = '${type}_$id';
    await _docRef(docId).update({'user_rating': rating});
  }

  /// Gets user rating for an item.
  Future<int?> getRating(dynamic item) async {
    final (id, type, _) = extract(item);
    final doc = await _docRef('${type}_$id').get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>?;
    return data?['user_rating'] as int?;
  }

  /// Clears user rating for an item.
  Future<void> clearRating(dynamic item) async {
    final (id, type, _) = extract(item);
    final docId = '${type}_$id';
    await _docRef(docId).update({'user_rating': FieldValue.delete()});
  }

  /// Removes an item from watched history.
  Future<void> removeItem(dynamic item) async {
    final (id, type, _) = extract(item);
    final docId = '${type}_$id';
    await _docRef(docId).delete();
  }

  /// Checks if an item is watched.
  Future<bool> isWatched(dynamic item) async {
    final (id, type, _) = extract(item);
    final doc = await _docRef('${type}_$id').get();
    return doc.exists;
  }

  // Firestore references
  CollectionReference get _collectionRef =>
      _firestore.collection('users').doc(_userId).collection('watched');

  DocumentReference _docRef(String docId) => _collectionRef.doc(docId);

  // Helper to extract id, type, and JSON
  (int, String, Map<String, dynamic>) extract(dynamic item) {
    if (item is Movie) {
      return (item.id, 'movie', _movieToJson(item));
    } else if (item is TvShow) {
      return (item.id, 'tv', _tvShowToJson(item));
    }
    throw Exception('Unsupported type for watched');
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
