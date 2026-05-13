import 'package:movie_watchlist/core/result/result.dart';
import 'package:movie_watchlist/features/movies/domain/entities/movie.dart';
import 'package:movie_watchlist/features/watchlist/domain/repositories/watchlist_repository.dart';

class AddToWatchlistUseCase {
  const AddToWatchlistUseCase(this._repository);

  final WatchlistRepository _repository;

  Future<Result<Unit>> call(Movie movie) {
    return _repository.addToWatchlist(movie);
  }
}
