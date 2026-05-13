// lib/shared/models/movie.dart
// VERSION 1 - Basic Movie model.

/// Simple Movie model.
/// TODO v2: Add more fields, JSON serialization
class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String releaseDate;
  final double voteAverage;
  final List<int> genreIds;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.releaseDate,
    required this.voteAverage,
    required this.genreIds,
  });

  /// Placeholder for poster URL.
  /// TODO v2: Build full TMDB image URL
  String get posterUrl => posterPath;
}
