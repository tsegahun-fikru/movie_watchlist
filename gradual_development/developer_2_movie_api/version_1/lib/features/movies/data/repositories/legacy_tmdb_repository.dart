// lib/features/movies/data/repositories/legacy_tmdb_repository.dart
// VERSION 1 - Mock legacy repository. Returns hardcoded data, no HTTP calls.
// TODO v2: Add real HTTP calls to TMDB API

import 'package:movie_watchlist/shared/models/movie.dart';
import 'package:movie_watchlist/shared/models/tv_show.dart';

/// Mock legacy TMDB repository - returns hardcoded data.
/// Used by home screen and detail screens.
class LegacyTmdbRepository {
  // Mock movie data
  final List<Movie> _mockMovies = [
    Movie(
      id: 1,
      title: 'Inception',
      overview: 'A thief who steals corporate secrets.',
      posterPath: '/inception.jpg',
      releaseDate: '2010-07-16',
      voteAverage: 8.8,
      genreIds: const [28, 878],
    ),
    Movie(
      id: 2,
      title: 'The Dark Knight',
      overview: 'Batman faces the Joker.',
      posterPath: '/dark_knight.jpg',
      releaseDate: '2008-07-18',
      voteAverage: 9.0,
      genreIds: const [28, 80],
    ),
  ];

  // Mock TV show data
  final List<TvShow> _mockTvShows = [
    TvShow(
      id: 100,
      name: 'Breaking Bad',
      overview: 'A chemistry teacher turns to cooking meth.',
      posterPath: '/breaking_bad.jpg',
      firstAirDate: '2008-01-20',
      voteAverage: 9.5,
      genreIds: const [18, 80],
    ),
  ];

  Future<List<Movie>> fetchTrendingMovies() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockMovies;
  }

  Future<List<Movie>> fetchPopularMovies() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockMovies;
  }

  Future<List<Movie>> fetchTopRatedMovies() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockMovies;
  }

  Future<List<Movie>> searchMovies(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockMovies;
  }

  Future<List<TvShow>> fetchSeries() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockTvShows;
  }

  Future<Map<int, String>> fetchGenres() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return {
      28: 'Action',
      12: 'Adventure',
      35: 'Comedy',
      18: 'Drama',
      878: 'Science Fiction',
    };
  }

  Future<Movie> getMovieById(int movieId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockMovies.first;
  }

  Future<Map<String, dynamic>> getMovieDetails(int movieId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'id': movieId,
      'title': 'Mock Movie',
      'overview': 'This is mock data',
    };
  }

  // TODO v2: Add all other methods with real HTTP calls
}
