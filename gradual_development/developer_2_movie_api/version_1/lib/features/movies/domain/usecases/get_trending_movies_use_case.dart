// lib/features/movies/domain/usecases/get_trending_movies_use_case.dart
// VERSION 1 - Use case (simplified, no Result type)

import 'package:movie_watchlist/features/movies/domain/entities/movie_page.dart';
import 'package:movie_watchlist/features/movies/domain/repositories/movie_repository.dart';

class GetTrendingMoviesUseCase {
  const GetTrendingMoviesUseCase(this._repository);

  final MovieRepository _repository;

  // TODO v2: Wrap return type in Result<MoviePage>
  Future<MoviePage> call(int page) {
    return _repository.getTrendingMovies(page);
  }
}
