// lib/features/movies/data/repositories/legacy_tmdb_repository.dart
// Legacy TMDB repository used by home-screen providers, TV search, and the
// detail screen. Predates the clean-arch movie repository and uses the shared
// Movie/TvShow models directly instead of domain entities.
//
// New features should use the clean-arch path (TmdbRemoteDataSource +
// MovieRepositoryImpl) via core/di/clean_arch_providers.dart.

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:movie_watchlist/core/config/api_key.dart';
import 'package:movie_watchlist/shared/models/movie.dart';
import 'package:movie_watchlist/shared/models/tv_show.dart';
import 'package:movie_watchlist/shared/models/tv_episode.dart';
import 'package:movie_watchlist/shared/models/search_result_item.dart';

/// Thrown when the device has no internet connection.
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  @override
  String toString() => 'NetworkException: $message';
}

/// Thrown when the TMDB API returns a non-200 status code.
class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);
  @override
  String toString() => 'ApiException: $statusCode - $message';
}

/// Provides all TMDB data access needed by the home screen, detail screen,
/// TV search, and recommendations feature.
class LegacyTmdbRepository {
  final http.Client client;

  LegacyTmdbRepository({required this.client});

  static const String apiKey = tmdbApiKey;
  static const String baseUrl = "https://api.themoviedb.org/3";
  static const String imageBaseUrl = "https://image.tmdb.org/t/p/w500";

  /// In-memory cache for the movie genre map to avoid repeated API calls.
  Map<int, String>? _genreMap;

  // ─── Generic GET helper ───────────────────────────────────────────────────

  /// Performs a GET request to [endpoint] with optional [queryParams].
  /// Throws [NetworkException] on connectivity issues and [ApiException] on
  /// non-200 responses.
  Future<Map<String, dynamic>> _get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    final params = <String, String>{'api_key': apiKey};
    if (queryParams != null) params.addAll(queryParams);
    final uri = Uri.parse('$baseUrl$endpoint').replace(queryParameters: params);
    try {
      final response = await client.get(uri);
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw ApiException(response.statusCode, 'Failed to load data from $endpoint');
      }
    } on SocketException {
      throw NetworkException('No Internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('Network error: $e');
    }
  }

  // ─── List helpers ─────────────────────────────────────────────────────────

  /// Fetches a list of [Movie] objects from [endpoint].
  Future<List<Movie>> _fetchMovieList(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    final data = await _get(endpoint, queryParams: queryParams);
    final results = data['results'] as List<dynamic>;
    return results
        .map((json) => Movie.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetches a list of [TvShow] objects from [endpoint].
  Future<List<TvShow>> _fetchTvList(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    final data = await _get(endpoint, queryParams: queryParams);
    final results = data['results'] as List<dynamic>;
    return results
        .map((json) => TvShow.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ─── Movie fetchers ───────────────────────────────────────────────────────

  Future<List<Movie>> fetchTrendingMovies() => _fetchMovieList('/trending/movie/day');
  Future<List<Movie>> fetchPopularMovies() => _fetchMovieList('/movie/popular');
  Future<List<Movie>> fetchTopRatedMovies() => _fetchMovieList('/movie/top_rated');
  Future<List<Movie>> fetchRecentMovies() => _fetchMovieList('/movie/now_playing');
  Future<List<Movie>> fetchUpcomingMovies() => _fetchMovieList('/movie/upcoming');
  Future<List<Movie>> searchMovies(String query) =>
      _fetchMovieList('/search/movie', queryParams: {'query': query});

  /// Discovers movies filtered by optional [genreIds] and/or [year].
  Future<List<Movie>> discoverMovies({List<int>? genreIds, int? year}) {
    final params = <String, String>{};
    if (genreIds != null && genreIds.isNotEmpty) {
      params['with_genres'] = genreIds.join(',');
    }
    if (year != null) {
      params['primary_release_year'] = year.toString();
    }
    return _fetchMovieList('/discover/movie', queryParams: params);
  }

  // ─── TV fetchers ──────────────────────────────────────────────────────────

  Future<List<TvShow>> fetchSeries() => _fetchTvList('/tv/popular');
  Future<List<TvShow>> fetchOnTheAirSeries() => _fetchTvList('/tv/on_the_air');
  Future<List<TvShow>> fetchTopRatedSeries() => _fetchTvList('/tv/top_rated');

  // ─── Genre cache ──────────────────────────────────────────────────────────

  /// Returns the movie genre map (id → name), fetching from TMDB only once
  /// per app session and caching the result in memory.
  Future<Map<int, String>> fetchGenres() async {
    if (_genreMap != null) return _genreMap!;
    final data = await _get('/genre/movie/list');
    final genres = data['genres'] as List<dynamic>;
    _genreMap = {for (var g in genres) g['id'] as int: g['name'] as String};
    return _genreMap!;
  }

  // ─── Detail endpoints ─────────────────────────────────────────────────────

  /// Fetches basic movie data by ID (no appended responses).
  Future<Movie> getMovieById(int movieId) async {
    final data = await _get('/movie/$movieId');
    return Movie.fromJson(data);
  }

  /// Fetches full movie details including videos and credits.
  Future<Map<String, dynamic>> getMovieDetails(int movieId) => _get(
    '/movie/$movieId',
    queryParams: {'append_to_response': 'videos,credits'},
  );

  /// Fetches full TV show details including videos and credits.
  Future<Map<String, dynamic>> getTvDetails(int seriesId) => _get(
    '/tv/$seriesId',
    queryParams: {'append_to_response': 'videos,credits'},
  );

  // ─── Trailer helpers ──────────────────────────────────────────────────────

  /// Returns the YouTube key of the first official trailer for a movie,
  /// or `null` if none is found or the request fails.
  Future<String?> getMovieTrailerKey(int movieId) async {
    try {
      final data = await _get('/movie/$movieId/videos');
      return _extractTrailerKey(data);
    } catch (e) {
      debugPrint('Error fetching movie trailer for $movieId: $e');
      return null;
    }
  }

  /// Returns the YouTube key of the first official trailer for a TV show,
  /// or `null` if none is found or the request fails.
  Future<String?> getTvTrailerKey(int seriesId) async {
    try {
      final data = await _get('/tv/$seriesId/videos');
      return _extractTrailerKey(data);
    } catch (e) {
      debugPrint('Error fetching TV trailer for $seriesId: $e');
      return null;
    }
  }

  /// Scans the videos results array for the first YouTube Trailer entry.
  String? _extractTrailerKey(Map<String, dynamic> data) {
    final results = data['results'] as List<dynamic>? ?? [];
    for (final video in results) {
      if (video['type'] == 'Trailer' && video['site'] == 'YouTube') {
        return video['key'] as String?;
      }
    }
    return null;
  }

  // ─── Watch providers ──────────────────────────────────────────────────────

  /// Returns the list of streaming providers for a movie in [region].
  /// Each entry has `name` and `logo` keys.
  Future<List<Map<String, dynamic>>> getMovieWatchProviders(
    int movieId,
    String region,
  ) async {
    return _fetchWatchProviders('/movie/$movieId/watch/providers', region);
  }

  /// Returns the list of streaming providers for a TV show in [region].
  Future<List<Map<String, dynamic>>> getTvWatchProviders(
    int seriesId,
    String region,
  ) async {
    return _fetchWatchProviders('/tv/$seriesId/watch/providers', region);
  }

  /// Internal helper that extracts the flatrate (subscription) providers for
  /// the given [region] from the TMDB watch/providers response.
  Future<List<Map<String, dynamic>>> _fetchWatchProviders(
    String endpoint,
    String region,
  ) async {
    final data = await _get(endpoint);
    final results = data['results'] as Map<String, dynamic>?;
    if (results == null || results[region] == null) return [];
    final regionData = results[region] as Map<String, dynamic>;
    final flatrate = regionData['flatrate'] as List<dynamic>? ?? [];
    return flatrate
        .map(
          (p) => {
            'name': p['provider_name'] as String,
            'logo': 'https://image.tmdb.org/t/p/w92${p['logo_path']}',
          },
        )
        .toList();
  }

  // ─── Season details ───────────────────────────────────────────────────────

  /// Fetches all episodes for a specific season of a TV show.
  Future<List<TvEpisode>> getSeasonEpisodes(int seriesId, int seasonNumber) async {
    final data = await _get('/tv/$seriesId/season/$seasonNumber');
    final episodes = data['episodes'] as List<dynamic>? ?? [];
    return episodes
        .map((e) => TvEpisode.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ─── Similar content ──────────────────────────────────────────────────────

  Future<List<Movie>> getSimilarMovies(int movieId) =>
      _fetchMovieList('/movie/$movieId/similar');

  Future<List<TvShow>> getSimilarTvShows(int seriesId) =>
      _fetchTvList('/tv/$seriesId/similar');

  // ─── Person movies ────────────────────────────────────────────────────────

  /// Searches for a person by [name] and returns their movie credits sorted
  /// by rating descending. Only movies with a poster are included.
  Future<List<Movie>> searchPersonMovies(String name) async {
    final data = await _get('/search/person', queryParams: {'query': name});
    final results = data['results'] as List? ?? [];
    if (results.isEmpty) return [];
    final personId = results.first['id'] as int;
    final credits = await _get('/person/$personId/movie_credits');
    final cast = credits['cast'] as List? ?? [];
    return cast
        .map((j) => Movie.fromJson(j as Map<String, dynamic>))
        .where((m) => m.posterPath.isNotEmpty)
        .toList()
      ..sort((a, b) => b.voteAverage.compareTo(a.voteAverage));
  }

  // ─── TV search ────────────────────────────────────────────────────────────

  Future<List<TvShow>> searchTvShows(String query, {int page = 1}) =>
      _fetchTvList('/search/tv',
          queryParams: {'query': query, 'page': page.toString()});

  /// Discovers TV shows with optional server-side filters.
  Future<List<TvShow>> discoverTvShows({
    int page = 1,
    int? genreId,
    int? year,
    double? minimumRating,
  }) {
    final params = <String, String>{'page': page.toString()};
    if (genreId != null) params['with_genres'] = '$genreId';
    if (year != null) params['first_air_date_year'] = '$year';
    if (minimumRating != null) params['vote_average.gte'] = '$minimumRating';
    return _fetchTvList('/discover/tv', queryParams: params);
  }

  /// Returns the TV genre map (id → name).
  Future<Map<int, String>> fetchTvGenres() async {
    final data = await _get('/genre/tv/list');
    final genres = data['genres'] as List<dynamic>;
    return {for (var g in genres) g['id'] as int: g['name'] as String};
  }

  // ─── Multi search (movies + TV) ───────────────────────────────────────────

  /// Searches across both movies and TV shows using the TMDB multi-search
  /// endpoint and returns a normalised list of [SearchResultItem]s.
  Future<List<SearchResultItem>> searchMulti(String query) async {
    final data = await _get('/search/multi', queryParams: {'query': query});

    final results = data['results'] as List<dynamic>;
    final items = <SearchResultItem>[];

    for (final json in results) {
      final mediaType = json['media_type'];

      if (mediaType == 'movie') {
        final movie = Movie.fromJson(json);
        items.add(
          SearchResultItem(
            id: movie.id,
            title: movie.title,
            posterUrl: movie.posterUrl,
            voteAverage: movie.voteAverage,
            originalItem: movie,
          ),
        );
      } else if (mediaType == 'tv') {
        final tv = TvShow.fromJson(json);
        items.add(
          SearchResultItem(
            id: tv.id,
            title: tv.name,
            posterUrl: tv.fullPosterUrl,
            voteAverage: tv.voteAverage,
            originalItem: tv,
          ),
        );
      }
    }

    return items;
  }
}
