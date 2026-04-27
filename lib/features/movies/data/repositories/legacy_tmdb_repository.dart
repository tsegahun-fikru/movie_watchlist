import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:movie_watchlist/core/config/api_key.dart';
import 'package:movie_watchlist/shared/models/movie.dart';
import 'package:movie_watchlist/shared/models/tv_show.dart';
import 'package:movie_watchlist/shared/models/search_result_item.dart';

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  @override
  String toString() => 'NetworkException: $message';
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);
  @override
  String toString() => 'ApiException: $statusCode - $message';
}

class LegacyTmdbRepository {
  final http.Client client;
  
  LegacyTmdbRepository({required this.client});

  static const String apiKey = tmdbApiKey;
  static const String baseUrl = "https://api.themoviedb.org/3";
  static const String imageBaseUrl = "https://image.tmdb.org/t/p/w500";

  Map<int, String>? _genreMap;

  // ─── Generic GET helper ───
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

  // ─── List helpers ───
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

  // ─── Movie fetchers ───
  Future<List<Movie>> fetchTrendingMovies() => _fetchMovieList('/trending/movie/day');
  Future<List<Movie>> fetchPopularMovies() => _fetchMovieList('/movie/popular');
  Future<List<Movie>> fetchTopRatedMovies() => _fetchMovieList('/movie/top_rated');
  Future<List<Movie>> fetchRecentMovies() => _fetchMovieList('/movie/now_playing');
  Future<List<Movie>> fetchUpcomingMovies() => _fetchMovieList('/movie/upcoming');
  Future<List<Movie>> searchMovies(String query) =>
      _fetchMovieList('/search/movie', queryParams: {'query': query});
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

  // ─── TV fetchers ───
  Future<List<TvShow>> fetchSeries() => _fetchTvList('/tv/popular');
  Future<List<TvShow>> fetchOnTheAirSeries() => _fetchTvList('/tv/on_the_air');
  Future<List<TvShow>> fetchTopRatedSeries() => _fetchTvList('/tv/top_rated');

  // ─── Genre cache ───
  Future<Map<int, String>> fetchGenres() async {
    if (_genreMap != null) return _genreMap!;
    final data = await _get('/genre/movie/list');
    final genres = data['genres'] as List<dynamic>;
    _genreMap = {for (var g in genres) g['id'] as int: g['name'] as String};
    return _genreMap!;
  }

  // ─── Details ───
  Future<Movie> getMovieById(int movieId) async {
    final data = await _get('/movie/$movieId');
    return Movie.fromJson(data);
  }

  Future<Map<String, dynamic>> getMovieDetails(int movieId) => _get(
    '/movie/$movieId',
    queryParams: {'append_to_response': 'videos,credits'},
  );

  Future<Map<String, dynamic>> getTvDetails(int seriesId) => _get(
    '/tv/$seriesId',
    queryParams: {'append_to_response': 'videos,credits'},
  );

  // ─── Trailer helpers ───
  Future<String?> getMovieTrailerKey(int movieId) async {
    try {
      final data = await _get('/movie/$movieId/videos');
      return _extractTrailerKey(data);
    } catch (e) {
      debugPrint('Error fetching movie trailer for $movieId: $e');
      return null;
    }
  }

  Future<String?> getTvTrailerKey(int seriesId) async {
    try {
      final data = await _get('/tv/$seriesId/videos');
      return _extractTrailerKey(data);
    } catch (e) {
      debugPrint('Error fetching TV trailer for $seriesId: $e');
      return null;
    }
  }

  String? _extractTrailerKey(Map<String, dynamic> data) {
    final results = data['results'] as List<dynamic>? ?? [];
    for (final video in results) {
      if (video['type'] == 'Trailer' && video['site'] == 'YouTube') {
        return video['key'] as String?;
      }
    }
    return null;
  }

  // ─── Watch providers ───
  Future<List<Map<String, dynamic>>> getMovieWatchProviders(
    int movieId,
    String region,
  ) async {
    return _fetchWatchProviders('/movie/$movieId/watch/providers', region);
  }

  Future<List<Map<String, dynamic>>> getTvWatchProviders(
    int seriesId,
    String region,
  ) async {
    return _fetchWatchProviders('/tv/$seriesId/watch/providers', region);
  }

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

  // ─── Multi search (movies + TV) ───
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
