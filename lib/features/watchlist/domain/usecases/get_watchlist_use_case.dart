import 'package:movie_watchlist/core/result/result.dart';
import 'package:movie_watchlist/features/watchlist/domain/entities/watchlist_item.dart';
import 'package:movie_watchlist/features/watchlist/domain/repositories/watchlist_repository.dart';

class GetWatchlistUseCase {
  const GetWatchlistUseCase(this._repository);

  final WatchlistRepository _repository;

  Future<Result<List<WatchlistItem>>> call(String userId) {
    return _repository.getWatchlist(userId);
  }
}
