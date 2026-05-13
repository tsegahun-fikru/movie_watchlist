// lib/features/movies/domain/usecases/get_trending_movies_use_case.dart
// VERSION 2 - Use case with Result<T> wrapper

import 'package:movie_watchlist/core/result/result.dart';
import 'package:movie_watchlist/features/movies/domain/entities/movie_page.dart';
import 'package:movie_watchlist/features/movies/domain/repositories/movie_repository.dart';

class GetTrendingMoviesUseCase {
  const GetTrendingMoviesUseCase(this._repository);

  final MovieRepository _repository;

  Future<Result<MoviePage>> call(int page) {
    return _repository.getTrendingMovies(page);
  }
}
