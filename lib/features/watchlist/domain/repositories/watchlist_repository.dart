import 'package:movie_watchlist/core/result/result.dart';
import 'package:movie_watchlist/features/movies/domain/entities/movie.dart';
import 'package:movie_watchlist/features/watchlist/domain/entities/watchlist_item.dart';

abstract class WatchlistRepository {
  Future<Result<List<WatchlistItem>>> getWatchlist(String userId);

  Future<Result<Unit>> addToWatchlist(Movie movie);

  Future<Result<Unit>> removeFromWatchlist(int movieId);
}
