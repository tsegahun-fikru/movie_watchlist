// lib/features/movies/data/repositories/legacy_tmdb_repository.dart
// VERSION 2 - Real HTTP calls to TMDB API. Basic error handling.
// TODO v3: Add caching, retry logic, detailed error handling

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movie_watchlist/core/config/api_key.dart';
import 'package:movie_watchlist/shared/models/movie.dart';
import 'package:movie_watchlist/shared/models/tv_show.dart';

/// Legacy TMDB repository with real HTTP calls.
class LegacyTmdbRepository {
  final http.Client client;

  LegacyTmdbRepository({required this.client});

  static const String baseUrl = "https://api.themoviedb.org/3";

  /// Generic GET helper.
  Future<Map<String, dynamic>> _get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    final params = <String, String>{'api_key': tmdbApiKey};
    if (queryParams != null) params.addAll(queryParams);
    final uri = Uri.parse('$baseUrl$endpoint').replace(queryParameters: params);

    final response = await client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load data from $endpoint');
    }

    return json.decode(response.body) as Map<String, dynamic>;
  }

  /// Fetches a list of movies from endpoint.
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

  /// Fetches a list of TV shows from endpoint.
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

  Future<List<Movie>> fetchTrendingMovies() => _fetchMovieList('/trending/movie/day');
  Future<List<Movie>> fetchPopularMovies() => _fetchMovieList('/movie/popular');
  Future<List<Movie>> fetchTopRatedMovies() => _fetchMovieList('/movie/top_rated');
  Future<List<Movie>> searchMovies(String query) =>
      _fetchMovieList('/search/movie', queryParams: {'query': query});

  Future<List<TvShow>> fetchSeries() => _fetchTvList('/tv/popular');

  Future<Map<int, String>> fetchGenres() async {
    final data = await _get('/genre/movie/list');
    final genres = data['genres'] as List<dynamic>;
    return {for (var g in genres) g['id'] as int: g['name'] as String};
  }

  Future<Movie> getMovieById(int movieId) async {
    final data = await _get('/movie/$movieId');
    return Movie.fromJson(data);
  }

  Future<Map<String, dynamic>> getMovieDetails(int movieId) => _get(
    '/movie/$movieId',
    queryParams: {'append_to_response': 'videos,credits'},
  );

  // TODO v3: Add all remaining methods with caching and retry logic
}
