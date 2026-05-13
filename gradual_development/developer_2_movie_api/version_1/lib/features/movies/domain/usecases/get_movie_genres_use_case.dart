// lib/features/movies/domain/usecases/get_movie_genres_use_case.dart
// VERSION 1 - Use case (simplified, no Result type)

import 'package:movie_watchlist/features/movies/domain/entities/genre.dart';
import 'package:movie_watchlist/features/movies/domain/repositories/movie_repository.dart';

class GetMovieGenresUseCase {
  const GetMovieGenresUseCase(this._repository);

  final MovieRepository _repository;

  // TODO v2: Wrap return type in Result<List<Genre>>
  Future<List<Genre>> call() {
    return _repository.getGenres();
  }
}
