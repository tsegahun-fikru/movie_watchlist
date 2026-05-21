import 'dart:collection';

import 'package:movie_watchlist/core/error/exceptions.dart';
import 'package:movie_watchlist/core/error/failures.dart';
import 'package:movie_watchlist/core/result/result.dart';
import 'package:movie_watchlist/features/movies/data/datasources/tmdb_remote_data_source.dart';
import 'package:movie_watchlist/features/movies/domain/entities/genre.dart';
import 'package:movie_watchlist/features/movies/domain/entities/movie_filters.dart';
import 'package:movie_watchlist/features/movies/domain/entities/movie_page.dart';
import 'package:movie_watchlist/features/movies/domain/repositories/movie_repository.dart';

class MovieRepositoryImpl implements MovieRepository {
  MovieRepositoryImpl({
    required TmdbRemoteDataSource remoteDataSource,
    int maxMoviePageCacheEntries = 40,
  }) : _remoteDataSource = remoteDataSource,
       _maxMoviePageCacheEntries = maxMoviePageCacheEntries;

  final TmdbRemoteDataSource _remoteDataSource;
  final int _maxMoviePageCacheEntries;
  final LinkedHashMap<String, MoviePage> _moviePageCache =
      LinkedHashMap<String, MoviePage>();
  List<Genre>? _genreCache;

  @override
  Future<Result<MoviePage>> searchMovies(
    String query,
    MovieFilters filters,
    int page,
  ) async {
    final cacheKey =
        'search|${query.trim()}|${filters.genreId}|'
        '${filters.year}|${filters.minimumRating}|$page';

    final cachedPage = _getCachedMoviePage(cacheKey);
    if (cachedPage != null) {
      return Success<MoviePage>(cachedPage);
    }

    try {
      final pageResult = await _remoteDataSource.searchMovies(
        query: query,
        filters: filters,
        page: page,
      );
      _cacheMoviePage(cacheKey, pageResult);
      return Success<MoviePage>(pageResult);
    } on ServerException catch (error) {
      return Error<MoviePage>(ServerFailure(error.message));
    } catch (error) {
      return Error<MoviePage>(UnknownFailure('$error'));
    }
  }

  @override
  Future<Result<MoviePage>> getTrendingMovies(int page) async {
    final cacheKey = 'trending|$page';
    final cachedPage = _getCachedMoviePage(cacheKey);
    if (cachedPage != null) {
      return Success<MoviePage>(cachedPage);
    }

    try {
      final pageResult = await _remoteDataSource.getTrending(page: page);
      _cacheMoviePage(cacheKey, pageResult);
      return Success<MoviePage>(pageResult);
    } on ServerException catch (error) {
      return Error<MoviePage>(ServerFailure(error.message));
    } catch (error) {
      return Error<MoviePage>(UnknownFailure('$error'));
    }
  }

  @override
  Future<Result<List<Genre>>> getGenres() async {
    if (_genreCache != null) {
      return Success<List<Genre>>(_genreCache!);
    }

    try {
      final genres = await _remoteDataSource.getGenres();
      _genreCache = genres;
      return Success<List<Genre>>(genres);
    } on ServerException catch (error) {
      return Error<List<Genre>>(ServerFailure(error.message));
    } catch (error) {
      return Error<List<Genre>>(UnknownFailure('$error'));
    }
  }

  MoviePage? _getCachedMoviePage(String cacheKey) {
    final cachedPage = _moviePageCache.remove(cacheKey);
    if (cachedPage != null) {
      _moviePageCache[cacheKey] = cachedPage;
    }
    return cachedPage;
  }

  void _cacheMoviePage(String cacheKey, MoviePage page) {
    _moviePageCache.remove(cacheKey);
    _moviePageCache[cacheKey] = page;

    while (_moviePageCache.length > _maxMoviePageCacheEntries) {
      _moviePageCache.remove(_moviePageCache.keys.first);
    }
  }
}
