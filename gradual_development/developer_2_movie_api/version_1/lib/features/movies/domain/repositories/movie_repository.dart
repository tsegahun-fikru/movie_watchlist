// lib/features/movies/domain/repositories/movie_repository.dart
// VERSION 1 - Repository interface (simplified, no Result type)

import 'package:movie_watchlist/features/movies/domain/entities/genre.dart';
import 'package:movie_watchlist/features/movies/domain/entities/movie_filters.dart';
import 'package:movie_watchlist/features/movies/domain/entities/movie_page.dart';

/// Abstract repository interface for movie data.
/// TODO v2: Add Result<T> wrapper for error handling
abstract class MovieRepository {
  Future<MoviePage> searchMovies(
    String query,
    MovieFilters filters,
    int page,
  );

  Future<MoviePage> getTrendingMovies(int page);

  Future<List<Genre>> getGenres();
}
