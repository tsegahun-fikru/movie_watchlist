// lib/shared/models/movie.dart
// VERSION 2 - Movie model with JSON serialization and full TMDB URLs.

/// Movie model with TMDB integration.
/// TODO v3: Add genres, runtime, cast, trailers
class Movie {
  final int id;
  final String title;
  final String originalTitle;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final String releaseDate;
  final double voteAverage;
  final int voteCount;
  final List<int> genreIds;
  final double popularity;
  final String originalLanguage;

  Movie({
    required this.id,
    required this.title,
    this.originalTitle = '',
    required this.overview,
    required this.posterPath,
    this.backdropPath = '',
    required this.releaseDate,
    required this.voteAverage,
    this.voteCount = 0,
    required this.genreIds,
    this.popularity = 0.0,
    this.originalLanguage = '',
  });

  /// Full TMDB poster URL.
  String get posterUrl =>
      posterPath.isNotEmpty
          ? 'https://image.tmdb.org/t/p/w500$posterPath'
          : '';

  /// Full TMDB backdrop URL.
  String get backdropUrl =>
      backdropPath.isNotEmpty
          ? 'https://image.tmdb.org/t/p/w500$backdropPath'
          : '';

  /// Creates Movie from JSON.
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      originalTitle: json['original_title'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      releaseDate: json['release_date'] ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] ?? 0,
      genreIds: (json['genre_ids'] as List?)?.cast<int>() ?? [],
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0.0,
      originalLanguage: json['original_language'] ?? '',
    );
  }

  /// Converts Movie to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'original_title': originalTitle,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'release_date': releaseDate,
      'vote_average': voteAverage,
      'vote_count': voteCount,
      'genre_ids': genreIds,
      'popularity': popularity,
      'original_language': originalLanguage,
    };
  }
}
