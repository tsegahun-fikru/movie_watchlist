// lib/features/movies/data/repositories/movie_repository_impl.dart
// VERSION 1 - Repository implementation with mock data source. No caching, no error handling.

import 'package:movie_watchlist/features/movies/data/datasources/tmdb_remote_data_source.dart';
import 'package:movie_watchlist/features/movies/domain/entities/genre.dart';
import 'package:movie_watchlist/features/movies/domain/entities/movie_filters.dart';
import 'package:movie_watchlist/features/movies/domain/entities/movie_page.dart';
import 'package:movie_watchlist/features/movies/domain/repositories/movie_repository.dart';

class MovieRepositoryImpl implements MovieRepository {
  MovieRepositoryImpl({required TmdbRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final TmdbRemoteDataSource _remoteDataSource;

  @override
  Future<MoviePage> searchMovies(
    String query,
    MovieFilters filters,
    int page,
  ) async {
    // TODO v2: Add Result<T> wrapper for error handling
    // TODO v3: Add caching
    return _remoteDataSource.searchMovies(
      query: query,
      filters: filters,
      page: page,
    );
  }

  @override
  Future<MoviePage> getTrendingMovies(int page) async {
    // TODO v2: Add Result<T> wrapper for error handling
    // TODO v3: Add caching
    return _remoteDataSource.getTrending(page: page);
  }

  @override
  Future<List<Genre>> getGenres() async {
    // TODO v2: Add Result<T> wrapper for error handling
    // TODO v3: Add caching
    return _remoteDataSource.getGenres();
  }
}
