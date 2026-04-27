import 'package:flutter_test/flutter_test.dart';
import 'package:movie_watchlist/core/error/failures.dart';
import 'package:movie_watchlist/core/result/result.dart';
import 'package:movie_watchlist/features/movies/domain/entities/movie.dart';
import 'package:movie_watchlist/features/watchlist/domain/entities/watchlist_item.dart';
import 'package:movie_watchlist/features/watchlist/domain/repositories/watchlist_repository.dart';
import 'package:movie_watchlist/features/watchlist/domain/usecases/get_watchlist_use_case.dart';

void main() {
  late GetWatchlistUseCase useCase;
  late FakeWatchlistRepository repository;

  setUp(() {
    repository = FakeWatchlistRepository();
    useCase = GetWatchlistUseCase(repository);
  });

  test('returns watchlist when repository succeeds', () async {
    repository.getResult = Success<List<WatchlistItem>>(<WatchlistItem>[
      WatchlistItem(
        movie: repository.movie,
        userId: 'user-1',
        addedAt: DateTime(2024),
      ),
    ]);

    final result = await useCase('user-1');

    expect(result, isA<Success<List<WatchlistItem>>>());
  });

  test('returns failure when repository fails', () async {
    repository.getResult = const Error<List<WatchlistItem>>(
      CacheFailure('fetch failed'),
    );

    final result = await useCase('user-1');

    expect(result, isA<Error<List<WatchlistItem>>>());
  });
}

class FakeWatchlistRepository implements WatchlistRepository {
  Movie get movie => const Movie(
    id: 1,
    title: 'Movie',
    overview: 'Overview',
    posterPath: '/poster.jpg',
    releaseDate: '2024-01-01',
    rating: 8.0,
    genreIds: <int>[1],
  );

  Result<List<WatchlistItem>> getResult = const Success<List<WatchlistItem>>(
    <WatchlistItem>[],
  );
  Result<Unit> addResult = const Success<Unit>(Unit());
  Result<Unit> removeResult = const Success<Unit>(Unit());

  @override
  Future<Result<Unit>> addToWatchlist(Movie movie) async => addResult;

  @override
  Future<Result<List<WatchlistItem>>> getWatchlist(String userId) async {
    return getResult;
  }

  @override
  Future<Result<Unit>> removeFromWatchlist(int movieId) async => removeResult;
}
