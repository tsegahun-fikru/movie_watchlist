import 'package:movie_watchlist/core/result/result.dart';
import 'package:movie_watchlist/features/movies/domain/entities/genre.dart';
import 'package:movie_watchlist/features/movies/domain/entities/movie_filters.dart';
import 'package:movie_watchlist/features/movies/domain/entities/movie_page.dart';

abstract class MovieRepository {
  Future<Result<MoviePage>> searchMovies(
    String query,
    MovieFilters filters,
    int page,
  );

  Future<Result<MoviePage>> getTrendingMovies(int page);

  Future<Result<List<Genre>>> getGenres();
}
