import 'package:movie_watchlist/features/movies/domain/entities/movie.dart';

class WatchlistItem {
  const WatchlistItem({
    required this.movie,
    required this.userId,
    required this.addedAt,
  });

  final Movie movie;
  final String userId;
  final DateTime addedAt;
}
