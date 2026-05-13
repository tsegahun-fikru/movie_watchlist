// lib/features/movies/presentation/providers/movie_providers.dart
// VERSION 2 - Real TMDB API providers using LegacyTmdbRepository.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:movie_watchlist/shared/models/movie.dart';
import 'package:movie_watchlist/shared/models/tv_show.dart';
import 'package:movie_watchlist/features/movies/data/repositories/legacy_tmdb_repository.dart';

/// Shared HTTP client for all providers.
/// TODO v3: Add connection pooling and timeout configuration
final httpClientProvider = Provider<http.Client>((ref) {
  return http.Client();
});

/// Legacy TMDB repository instance.
/// TODO v3: Migrate to clean architecture providers
final legacyTmdbRepositoryProvider = Provider<LegacyTmdbRepository>((ref) {
  final client = ref.watch(httpClientProvider);
  return LegacyTmdbRepository(client: client);
});

// ─── Movie Providers ──────────────────────────────────────────────────────────

/// Fetches trending movies from TMDB API.
/// TODO v3: Add caching layer
final trendingMoviesProvider = FutureProvider<List<Movie>>((ref) {
  return ref.watch(legacyTmdbRepositoryProvider).fetchTrendingMovies();
});

/// Fetches popular movies from TMDB API.
final popularMoviesProvider = FutureProvider<List<Movie>>((ref) {
  return ref.watch(legacyTmdbRepositoryProvider).fetchPopularMovies();
});

/// Fetches recent movie releases from TMDB API.
final recentReleasesProvider = FutureProvider<List<Movie>>((ref) {
  return ref.watch(legacyTmdbRepositoryProvider).fetchRecentMovies();
});

/// Fetches top rated movies from TMDB API.
final topRatedMoviesProvider = FutureProvider<List<Movie>>((ref) {
  return ref.watch(legacyTmdbRepositoryProvider).fetchTopRatedMovies();
});

/// Fetches upcoming movies from TMDB API.
final upcomingMoviesProvider = FutureProvider<List<Movie>>((ref) {
  return ref.watch(legacyTmdbRepositoryProvider).fetchUpcomingMovies();
});

// ─── TV Show Providers ────────────────────────────────────────────────────────

/// Fetches popular TV series from TMDB API.
final popularSeriesProvider = FutureProvider<List<TvShow>>((ref) {
  return ref.watch(legacyTmdbRepositoryProvider).fetchSeries();
});

/// Fetches currently airing TV series from TMDB API.
final onTheAirSeriesProvider = FutureProvider<List<TvShow>>((ref) {
  return ref.watch(legacyTmdbRepositoryProvider).fetchOnTheAirSeries();
});

/// Fetches top rated TV series from TMDB API.
final topRatedSeriesProvider = FutureProvider<List<TvShow>>((ref) {
  return ref.watch(legacyTmdbRepositoryProvider).fetchTopRatedSeries();
});

// ─── Genre Provider ───────────────────────────────────────────────────────────

/// Fetches movie genres map from TMDB API.
/// Returns a map of genre ID to genre name (e.g., {28: 'Action'}).
/// TODO v3: Cache genres locally since they rarely change
final genreMapProvider = FutureProvider<Map<int, String>>((ref) {
  return ref.watch(legacyTmdbRepositoryProvider).fetchGenres();
});
