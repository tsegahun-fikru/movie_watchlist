// lib/features/movies/domain/entities/movie.dart
// VERSION 1 - Entity class (same across all versions)

class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.releaseDate,
    required this.rating,
    required this.genreIds,
  });

  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String releaseDate;
  final double rating;
  final List<int> genreIds;
}
