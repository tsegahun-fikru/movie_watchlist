// lib/features/movies/domain/usecases/search_movies_use_case.dart
// VERSION 2 - Use case with Result<T> wrapper

import 'package:movie_watchlist/core/result/result.dart';
import 'package:movie_watchlist/features/movies/domain/entities/movie_filters.dart';
import 'package:movie_watchlist/features/movies/domain/entities/movie_page.dart';
import 'package:movie_watchlist/features/movies/domain/repositories/movie_repository.dart';

class SearchMoviesUseCase {
  const SearchMoviesUseCase(this._repository);

  final MovieRepository _repository;

  Future<Result<MoviePage>> call(SearchMoviesParams params) {
    return _repository.searchMovies(params.query, params.filters, params.page);
  }
}

class SearchMoviesParams {
  const SearchMoviesParams({
    required this.query,
    required this.filters,
    required this.page,
  });

  final String query;
  final MovieFilters filters;
  final int page;
}
