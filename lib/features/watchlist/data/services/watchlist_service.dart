// lib/features/watchlist/data/services/watchlist_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movie_watchlist/shared/models/movie.dart';
import 'package:movie_watchlist/shared/models/tv_show.dart';
import 'package:movie_watchlist/features/watchlist/data/models/watchlist_item.dart';

class WatchlistService {
  final FirebaseFirestore _firestore;
  final String _userId;

  WatchlistService({
    required FirebaseFirestore firestore,
    required String userId,
  }) : _firestore = firestore,
       _userId = userId;

  // ─── Public stream of all watchlist items ───
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

  // ─── Add any item (Movie or TvShow) ───
  Future<void> addItem(dynamic item) async {
    final (id, type, json) = _extract(item);
    final docId = '${type}_$id';
    json['type'] = type; // store type inside doc for convenience
    await _docRef(docId).set(json);
  }

  // ─── Remove any item ───
  Future<void> removeItem(dynamic item) async {
    final (id, type, _) = _extract(item);
    final docId = '${type}_$id';
    await _docRef(docId).delete();
  }

  // ─── Check if item is in watchlist ───
  Future<bool> isInWatchlist(dynamic item) async {
    final (id, type, _) = _extract(item);
    final doc = await _docRef('${type}_$id').get();
    return doc.exists;
  }

  // ─── Convenience: remove by id+type (used in some places) ───
  Future<void> removeById(int id, String type) async {
    await _docRef('${type}_$id').delete();
  }

  // ─── Firestore references ───
  CollectionReference get _collectionRef =>
      _firestore.collection('users').doc(_userId).collection('watchlist');

  DocumentReference _docRef(String docId) => _collectionRef.doc(docId);

  // ─── Helper: extract id, type and full Firestore JSON from Movie/TvShow ───
  (int, String, Map<String, dynamic>) _extract(dynamic item) {
    if (item is Movie) {
      return (item.id, 'movie', _movieToJson(item));
    } else if (item is TvShow) {
      return (item.id, 'tv', _tvShowToJson(item));
    }
    throw Exception('Unsupported type for watchlist');
  }

  // ─── JSON converters ───
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
      // genres, runtime, cast, trailerKey are not stored – they are fetched on detail screen
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
