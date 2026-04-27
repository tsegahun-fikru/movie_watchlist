import 'package:flutter_test/flutter_test.dart';
import 'package:movie_watchlist/core/error/failures.dart';
import 'package:movie_watchlist/core/result/result.dart';
import 'package:movie_watchlist/features/movies/domain/entities/movie.dart';
import 'package:movie_watchlist/features/watchlist/domain/entities/watchlist_item.dart';
import 'package:movie_watchlist/features/watchlist/domain/repositories/watchlist_repository.dart';
import 'package:movie_watchlist/features/watchlist/domain/usecases/add_to_watchlist_use_case.dart';

void main() {
  late AddToWatchlistUseCase useCase;
  late FakeWatchlistRepository repository;

  setUp(() {
    repository = FakeWatchlistRepository();
    useCase = AddToWatchlistUseCase(repository);
  });

  test('returns success when repository succeeds', () async {
    repository.addResult = const Success<Unit>(Unit());

    final result = await useCase(repository.movie);

    expect(result, isA<Success<Unit>>());
  });

  test('returns failure when repository fails', () async {
    repository.addResult = const Error<Unit>(CacheFailure('add failed'));

    final result = await useCase(repository.movie);

    expect(result, isA<Error<Unit>>());
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
