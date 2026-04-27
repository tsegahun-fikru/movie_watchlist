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
