// lib/features/movies/data/datasources/tmdb_remote_data_source.dart
// VERSION 1 - Mock data source. Returns hardcoded JSON data, no HTTP calls.

import 'dart:convert';
import 'package:movie_watchlist/features/movies/data/models/movie_model.dart';
import 'package:movie_watchlist/features/movies/domain/entities/genre.dart';
import 'package:movie_watchlist/features/movies/domain/entities/movie_filters.dart';
import 'package:movie_watchlist/features/movies/domain/entities/movie_page.dart';

/// Mock data source - returns hardcoded movie data.
/// TODO v2: Replace with real HTTP calls to TMDB API
class TmdbRemoteDataSource {
  /// Mock search/discover movies - returns hardcoded data.
  Future<MoviePage> searchMovies({
    required String query,
    required MovieFilters filters,
    required int page,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Hardcoded mock JSON response
    final mockJson = {
      'page': page,
      'total_pages': 3,
      'results': [
        {
          'id': 1,
          'title': 'Inception',
          'overview': 'A thief who steals corporate secrets through dream-sharing technology.',
          'poster_path': '/inception.jpg',
          'release_date': '2010-07-16',
          'vote_average': 8.8,
          'genre_ids': [28, 878, 53],
        },
        {
          'id': 2,
          'title': 'The Dark Knight',
          'overview': 'Batman faces the Joker in Gotham City.',
          'poster_path': '/dark_knight.jpg',
          'release_date': '2008-07-18',
          'vote_average': 9.0,
          'genre_ids': [28, 80, 18],
        },
        {
          'id': 3,
          'title': 'Interstellar',
          'overview': 'A team of explorers travel through a wormhole in space.',
          'poster_path': '/interstellar.jpg',
          'release_date': '2014-11-07',
          'vote_average': 8.6,
          'genre_ids': [12, 18, 878],
        },
      ],
    };

    final results = mockJson['results'] as List<dynamic>;
    return MoviePage(
      movies: results
          .map((json) => MovieModel.fromJson(json as Map<String, dynamic>))
          .map((model) => model.toEntity())
          .toList(),
      page: mockJson['page'] as int,
      totalPages: mockJson['total_pages'] as int,
    );
  }

  /// Mock trending movies - returns hardcoded data.
  Future<MoviePage> getTrending({required int page}) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final mockJson = {
      'page': page,
      'total_pages': 2,
      'results': [
        {
          'id': 10,
          'title': 'Oppenheimer',
          'overview': 'The story of J. Robert Oppenheimer.',
          'poster_path': '/oppenheimer.jpg',
          'release_date': '2023-07-21',
          'vote_average': 8.5,
          'genre_ids': [18, 36],
        },
        {
          'id': 11,
          'title': 'Barbie',
          'overview': 'Barbie and Ken have the time of their lives.',
          'poster_path': '/barbie.jpg',
          'release_date': '2023-07-21',
          'vote_average': 7.2,
          'genre_ids': [35, 12, 14],
        },
      ],
    };

    final results = mockJson['results'] as List<dynamic>;
    return MoviePage(
      movies: results
          .map((json) => MovieModel.fromJson(json as Map<String, dynamic>))
          .map((model) => model.toEntity())
          .toList(),
      page: mockJson['page'] as int,
      totalPages: mockJson['total_pages'] as int,
    );
  }

  /// Mock genres - returns hardcoded data.
  Future<List<Genre>> getGenres() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return const [
      Genre(id: 28, name: 'Action'),
      Genre(id: 12, name: 'Adventure'),
      Genre(id: 35, name: 'Comedy'),
      Genre(id: 18, name: 'Drama'),
      Genre(id: 27, name: 'Horror'),
      Genre(id: 878, name: 'Science Fiction'),
      Genre(id: 53, name: 'Thriller'),
    ];
  }
}
