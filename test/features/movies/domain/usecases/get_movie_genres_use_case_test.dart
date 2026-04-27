import 'package:flutter_test/flutter_test.dart';
import 'package:movie_watchlist/core/error/failures.dart';
import 'package:movie_watchlist/core/result/result.dart';
import 'package:movie_watchlist/features/movies/domain/entities/genre.dart';
import 'package:movie_watchlist/features/movies/domain/entities/movie.dart';
import 'package:movie_watchlist/features/movies/domain/entities/movie_filters.dart';
import 'package:movie_watchlist/features/movies/domain/entities/movie_page.dart';
import 'package:movie_watchlist/features/movies/domain/repositories/movie_repository.dart';
import 'package:movie_watchlist/features/movies/domain/usecases/get_movie_genres_use_case.dart';

void main() {
  late GetMovieGenresUseCase useCase;
  late FakeMovieRepository repository;

  setUp(() {
    repository = FakeMovieRepository();
    useCase = GetMovieGenresUseCase(repository);
  });

  test('returns genres when repository succeeds', () async {
    repository.genresResult = const Success<List<Genre>>(<Genre>[
      Genre(id: 1, name: 'Action'),
    ]);

    final result = await useCase();

    expect(result, isA<Success<List<Genre>>>());
  });

  test('returns failure when repository fails', () async {
    repository.genresResult = const Error<List<Genre>>(
      ServerFailure('genres failed'),
    );

    final result = await useCase();

    expect(result, isA<Error<List<Genre>>>());
  });
}

class FakeMovieRepository implements MovieRepository {
  Result<MoviePage> searchResult = const Success<MoviePage>(
    MoviePage(movies: <Movie>[], page: 1, totalPages: 1),
  );

  Result<MoviePage> trendingResult = const Success<MoviePage>(
    MoviePage(movies: <Movie>[], page: 1, totalPages: 1),
  );

  Result<List<Genre>> genresResult = const Success<List<Genre>>(<Genre>[]);

  @override
  Future<Result<List<Genre>>> getGenres() async => genresResult;

  @override
  Future<Result<MoviePage>> getTrendingMovies(int page) async => trendingResult;

  @override
  Future<Result<MoviePage>> searchMovies(
    String query,
    MovieFilters filters,
    int page,
  ) async {
    return searchResult;
  }
}
