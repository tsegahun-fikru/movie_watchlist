// lib/features/movies/domain/usecases/get_movie_genres_use_case.dart
// VERSION 2 - Use case with Result<T> wrapper

import 'package:movie_watchlist/core/result/result.dart';
import 'package:movie_watchlist/features/movies/domain/entities/genre.dart';
import 'package:movie_watchlist/features/movies/domain/repositories/movie_repository.dart';

class GetMovieGenresUseCase {
  const GetMovieGenresUseCase(this._repository);

  final MovieRepository _repository;

  Future<Result<List<Genre>>> call() {
    return _repository.getGenres();
  }
}
