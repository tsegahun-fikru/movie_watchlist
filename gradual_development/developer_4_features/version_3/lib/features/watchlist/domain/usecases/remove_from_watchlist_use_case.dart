import 'package:movie_watchlist/core/result/result.dart';
import 'package:movie_watchlist/features/watchlist/domain/repositories/watchlist_repository.dart';

class RemoveFromWatchlistUseCase {
  const RemoveFromWatchlistUseCase(this._repository);

  final WatchlistRepository _repository;

  Future<Result<Unit>> call(int movieId) {
    return _repository.removeFromWatchlist(movieId);
  }
}
