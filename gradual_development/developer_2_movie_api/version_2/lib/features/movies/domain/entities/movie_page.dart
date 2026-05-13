// lib/features/movies/domain/entities/movie_page.dart
// VERSION 1 - Entity class (same across all versions)

import 'package:movie_watchlist/features/movies/domain/entities/movie.dart';

class MoviePage {
  const MoviePage({
    required this.movies,
    required this.page,
    required this.totalPages,
  });

  final List<Movie> movies;
  final int page;
  final int totalPages;

  bool get hasMore => page < totalPages;
}
