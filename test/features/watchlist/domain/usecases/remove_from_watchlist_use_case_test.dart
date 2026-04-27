import 'package:flutter_test/flutter_test.dart';
import 'package:movie_watchlist/core/error/failures.dart';
import 'package:movie_watchlist/core/result/result.dart';
import 'package:movie_watchlist/features/movies/domain/entities/movie.dart';
import 'package:movie_watchlist/features/watchlist/domain/entities/watchlist_item.dart';
import 'package:movie_watchlist/features/watchlist/domain/repositories/watchlist_repository.dart';
import 'package:movie_watchlist/features/watchlist/domain/usecases/remove_from_watchlist_use_case.dart';

void main() {
  late RemoveFromWatchlistUseCase useCase;
  late FakeWatchlistRepository repository;

  setUp(() {
    repository = FakeWatchlistRepository();
    useCase = RemoveFromWatchlistUseCase(repository);
  });

  test('returns success when repository succeeds', () async {
    repository.removeResult = const Success<Unit>(Unit());

    final result = await useCase(1);

    expect(result, isA<Success<Unit>>());
  });

  test('returns failure when repository fails', () async {
    repository.removeResult = const Error<Unit>(CacheFailure('remove failed'));

    final result = await useCase(1);

    expect(result, isA<Error<Unit>>());
  });
}

class FakeWatchlistRepository implements WatchlistRepository {
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
