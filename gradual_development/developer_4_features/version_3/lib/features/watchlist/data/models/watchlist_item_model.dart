import 'package:movie_watchlist/features/movies/data/models/movie_model.dart';
import 'package:movie_watchlist/features/movies/domain/entities/movie.dart';
import 'package:movie_watchlist/features/watchlist/domain/entities/watchlist_item.dart';

class WatchlistItemModel {
  const WatchlistItemModel({
    required this.userId,
    required this.movie,
    required this.addedAt,
  });

  final String userId;
  final MovieModel movie;
  final DateTime addedAt;

  factory WatchlistItemModel.fromFirestore(
    String userId,
    Map<String, dynamic> json,
  ) {
    return WatchlistItemModel(
      userId: userId,
      movie: MovieModel.fromJson(json),
      addedAt:
          DateTime.tryParse(json['added_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  factory WatchlistItemModel.fromMovie({
    required String userId,
    required Movie movie,
    required DateTime addedAt,
  }) {
    return WatchlistItemModel(
      userId: userId,
      movie: MovieModel(
        id: movie.id,
        title: movie.title,
        overview: movie.overview,
        posterPath: movie.posterPath,
        releaseDate: movie.releaseDate,
        rating: movie.rating,
        genreIds: movie.genreIds,
      ),
      addedAt: addedAt,
    );
  }

  WatchlistItem toEntity() {
    return WatchlistItem(
      movie: movie.toEntity(),
      userId: userId,
      addedAt: addedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': movie.id,
      'title': movie.title,
      'overview': movie.overview,
      'poster_path': movie.posterPath,
      'release_date': movie.releaseDate,
      'vote_average': movie.rating,
      'genre_ids': movie.genreIds,
      'added_at': addedAt.toUtc().toIso8601String(),
    };
  }
}
