import 'package:flutter_test/flutter_test.dart';
import 'package:movie_watchlist/core/error/failures.dart';
import 'package:movie_watchlist/core/result/result.dart';
import 'package:movie_watchlist/features/movies/domain/entities/movie.dart';
import 'package:movie_watchlist/features/movies/domain/entities/movie_filters.dart';
import 'package:movie_watchlist/features/movies/domain/entities/movie_page.dart';
import 'package:movie_watchlist/features/movies/domain/entities/genre.dart';
import 'package:movie_watchlist/features/movies/domain/repositories/movie_repository.dart';
import 'package:movie_watchlist/features/movies/domain/usecases/get_trending_movies_use_case.dart';

void main() {
  late GetTrendingMoviesUseCase useCase;
  late FakeMovieRepository repository;

  setUp(() {
    repository = FakeMovieRepository();
    useCase = GetTrendingMoviesUseCase(repository);
  });

  test('returns movies when repository succeeds', () async {
    repository.trendingResult = Success<MoviePage>(
      MoviePage(movies: <Movie>[repository.movie], page: 1, totalPages: 3),
    );

    final result = await useCase(1);

    expect(result, isA<Success<MoviePage>>());
  });

  test('returns failure when repository fails', () async {
    repository.trendingResult = const Error<MoviePage>(
      ServerFailure('trending failed'),
    );

    final result = await useCase(1);

    expect(result, isA<Error<MoviePage>>());
  });
}

class FakeMovieRepository implements MovieRepository {
  Movie get movie => const Movie(
    id: 1,
    title: 'Movie',
    overview: 'Overview',
    posterPath: '/poster.jpg',
    releaseDate: '2024-01-01',
    rating: 8.0,
    genreIds: <int>[1],
  );

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
