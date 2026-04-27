import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:movie_watchlist/shared/models/movie.dart';
import 'package:movie_watchlist/shared/models/tv_show.dart';
import 'package:movie_watchlist/features/movies/data/repositories/legacy_tmdb_repository.dart';

final httpClientProvider = Provider<http.Client>((ref) {
  return http.Client();
});

final legacyTmdbRepositoryProvider = Provider<LegacyTmdbRepository>((ref) {
  final client = ref.watch(httpClientProvider);
  return LegacyTmdbRepository(client: client);
});

final trendingMoviesProvider = FutureProvider<List<Movie>>((ref) {
  return ref.watch(legacyTmdbRepositoryProvider).fetchTrendingMovies();
});

final popularMoviesProvider = FutureProvider<List<Movie>>((ref) {
  return ref.watch(legacyTmdbRepositoryProvider).fetchPopularMovies();
});

final recentReleasesProvider = FutureProvider<List<Movie>>((ref) {
  return ref.watch(legacyTmdbRepositoryProvider).fetchRecentMovies();
});

final topRatedMoviesProvider = FutureProvider<List<Movie>>((ref) {
  return ref.watch(legacyTmdbRepositoryProvider).fetchTopRatedMovies();
});

final upcomingMoviesProvider = FutureProvider<List<Movie>>((ref) {
  return ref.watch(legacyTmdbRepositoryProvider).fetchUpcomingMovies();
});

final popularSeriesProvider = FutureProvider<List<TvShow>>((ref) {
  return ref.watch(legacyTmdbRepositoryProvider).fetchSeries();
});

final onTheAirSeriesProvider = FutureProvider<List<TvShow>>((ref) {
  return ref.watch(legacyTmdbRepositoryProvider).fetchOnTheAirSeries();
});

final topRatedSeriesProvider = FutureProvider<List<TvShow>>((ref) {
  return ref.watch(legacyTmdbRepositoryProvider).fetchTopRatedSeries();
});

final genreMapProvider = FutureProvider<Map<int, String>>((ref) {
  return ref.watch(legacyTmdbRepositoryProvider).fetchGenres();
});
