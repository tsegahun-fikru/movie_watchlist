// lib/shared/models/tv_show.dart
// VERSION 1 - Basic TvShow model.

/// Simple TV Show model.
/// TODO v2: Add more fields, JSON serialization
class TvShow {
  final int id;
  final String name;
  final String overview;
  final String posterPath;
  final String firstAirDate;
  final double voteAverage;
  final List<int> genreIds;

  TvShow({
    required this.id,
    required this.name,
    required this.overview,
    required this.posterPath,
    required this.firstAirDate,
    required this.voteAverage,
    required this.genreIds,
  });

  /// Placeholder for poster URL.
  /// TODO v2: Build full TMDB image URL
  String get fullPosterUrl => posterPath;
}
