// lib/features/movies/data/datasources/tmdb_remote_data_source.dart
// Clean-arch remote data source for the movies feature. Communicates with
// the TMDB REST API and returns typed domain objects.

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:movie_watchlist/core/config/api_key.dart';
import 'package:movie_watchlist/core/error/exceptions.dart';
import 'package:movie_watchlist/features/movies/data/models/movie_model.dart';
import 'package:movie_watchlist/features/movies/domain/entities/genre.dart';
import 'package:movie_watchlist/features/movies/domain/entities/movie_filters.dart';
import 'package:movie_watchlist/features/movies/domain/entities/movie_page.dart';

/// Fetches movie data from the TMDB REST API.
///
/// All methods throw [ServerException] on non-200 responses.
class TmdbRemoteDataSource {
  TmdbRemoteDataSource({required http.Client client}) : _client = client;

  static const String _baseUrl = 'https://api.themoviedb.org/3';

  final http.Client _client;

  /// Searches or discovers movies depending on whether [query] is non-empty.
  ///
  /// - Non-empty [query] → `/search/movie`
  /// - Empty [query] → `/discover/movie` (supports genre/year/rating filters)
  Future<MoviePage> searchMovies({
    required String query,
    required MovieFilters filters,
    required int page,
  }) async {
    final hasQuery = query.trim().isNotEmpty;
    final endpoint = hasQuery ? '/search/movie' : '/discover/movie';

    final queryParameters = <String, String>{
      'api_key': tmdbApiKey,
      'page': page.toString(),
      if (hasQuery) 'query': query.trim(),
      if (filters.genreId != null) 'with_genres': '${filters.genreId}',
      if (filters.year != null) 'primary_release_year': '${filters.year}',
      if (filters.minimumRating != null)
        'vote_average.gte': '${filters.minimumRating}',
    };

    return _fetchMoviePage(endpoint, queryParameters);
  }

  /// Fetches the daily trending movies list for the given [page].
  Future<MoviePage> getTrending({required int page}) {
    return _fetchMoviePage('/trending/movie/day', <String, String>{
      'api_key': tmdbApiKey,
      'page': page.toString(),
    });
  }

  /// Fetches the list of TMDB movie genres.
  Future<List<Genre>> getGenres() async {
    final uri = Uri.parse(
      '$_baseUrl/genre/movie/list',
    ).replace(queryParameters: <String, String>{'api_key': tmdbApiKey});

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw ServerException(
        'TMDB genres request failed with ${response.statusCode}.',
      );
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final genres = payload['genres'] as List<dynamic>? ?? const [];

    return genres
        .map(
          (genre) => Genre(
            id: genre['id'] as int? ?? 0,
            name: genre['name'] as String? ?? '',
          ),
        )
        .toList();
  }

  /// Internal helper that fetches a paginated movie list from [endpoint].
  Future<MoviePage> _fetchMoviePage(
    String endpoint,
    Map<String, String> queryParameters,
  ) async {
    final uri = Uri.parse(
      '$_baseUrl$endpoint',
    ).replace(queryParameters: queryParameters);

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw ServerException('TMDB request failed with ${response.statusCode}.');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final results = payload['results'] as List<dynamic>? ?? const [];

    return MoviePage(
      movies: results
          .map((json) => MovieModel.fromJson(json as Map<String, dynamic>))
          .map((model) => model.toEntity())
          .toList(),
      page: payload['page'] as int? ?? 1,
      totalPages: payload['total_pages'] as int? ?? 1,
    );
  }
}
