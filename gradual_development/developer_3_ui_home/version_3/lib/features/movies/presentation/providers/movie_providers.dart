// lib/features/movies/presentation/providers/movie_providers.dart
// Legacy Riverpod providers that use [LegacyTmdbRepository] directly.
// These power the home screen's horizontal media lists and genre map.
//
// Note: New features should use the clean-arch path in
// `core/di/clean_arch_providers.dart` instead.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:movie_watchlist/shared/models/movie.dart';
import 'package:movie_watchlist/shared/models/tv_show.dart';
import 'package:movie_watchlist/features/movies/data/repositories/legacy_tmdb_repository.dart';

/// Shared HTTP client for legacy providers.
final httpClientProvider = Provider<http.Client>((ref) {
  return http.Client();
});

/// [LegacyTmdbRepository] instance used by home-screen and detail providers.
final legacyTmdbRepositoryProvider = Provider<LegacyTmdbRepository>((ref) {
  final client = ref.watch(httpClientProvider);
  return LegacyTmdbRepository(client: client);
});

// ─── Movie list providers ─────────────────────────────────────────────────────

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

// ─── TV series list providers ─────────────────────────────────────────────────

final popularSeriesProvider = FutureProvider<List<TvShow>>((ref) {
  return ref.watch(legacyTmdbRepositoryProvider).fetchSeries();
});

final onTheAirSeriesProvider = FutureProvider<List<TvShow>>((ref) {
  return ref.watch(legacyTmdbRepositoryProvider).fetchOnTheAirSeries();
});

final topRatedSeriesProvider = FutureProvider<List<TvShow>>((ref) {
  return ref.watch(legacyTmdbRepositoryProvider).fetchTopRatedSeries();
});

// ─── Genre map ────────────────────────────────────────────────────────────────

/// Cached map of movie genre IDs to names (e.g. `{28: 'Action'}`).
/// Used by the genre chips row on the home screen.
final genreMapProvider = FutureProvider<Map<int, String>>((ref) {
  return ref.watch(legacyTmdbRepositoryProvider).fetchGenres();
});
