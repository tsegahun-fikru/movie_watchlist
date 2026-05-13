// lib/features/movies/data/repositories/movie_repository_impl.dart
// VERSION 2 - Repository with Result<T> wrapper. Basic error handling, no caching.

import 'package:movie_watchlist/core/error/failures.dart';
import 'package:movie_watchlist/core/result/result.dart';
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
  Future<Result<MoviePage>> searchMovies(
    String query,
    MovieFilters filters,
    int page,
  ) async {
    try {
      final pageResult = await _remoteDataSource.searchMovies(
        query: query,
        filters: filters,
        page: page,
      );
      return Success<MoviePage>(pageResult);
    } catch (error) {
      // TODO v3: Distinguish ServerException from other errors
      return Error<MoviePage>(UnknownFailure('$error'));
    }
  }

  @override
  Future<Result<MoviePage>> getTrendingMovies(int page) async {
    try {
      final pageResult = await _remoteDataSource.getTrending(page: page);
      return Success<MoviePage>(pageResult);
    } catch (error) {
      return Error<MoviePage>(UnknownFailure('$error'));
    }
  }

  @override
  Future<Result<List<Genre>>> getGenres() async {
    try {
      final genres = await _remoteDataSource.getGenres();
      return Success<List<Genre>>(genres);
    } catch (error) {
      return Error<List<Genre>>(UnknownFailure('$error'));
    }
  }
  // TODO v3: Add caching for all methods
}
