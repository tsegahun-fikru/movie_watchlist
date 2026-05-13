// lib/shared/models/tv_show.dart
// VERSION 2 - TV Show model with JSON serialization and full TMDB URLs.

/// TV Show model with TMDB integration.
/// TODO v3: Add seasons, episodes, networks
class TvShow {
  final int id;
  final String name;
  final String originalName;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final String firstAirDate;
  final double voteAverage;
  final int voteCount;
  final List<int> genreIds;
  final double popularity;
  final String originalLanguage;
  final List<String> originCountry;

  TvShow({
    required this.id,
    required this.name,
    this.originalName = '',
    required this.overview,
    required this.posterPath,
    this.backdropPath = '',
    required this.firstAirDate,
    required this.voteAverage,
    this.voteCount = 0,
    required this.genreIds,
    this.popularity = 0.0,
    this.originalLanguage = '',
    this.originCountry = const [],
  });

  /// Full TMDB poster URL.
  String get fullPosterUrl =>
      posterPath.isNotEmpty
          ? 'https://image.tmdb.org/t/p/w500$posterPath'
          : '';

  /// Full TMDB backdrop URL.
  String get backdropUrl =>
      backdropPath.isNotEmpty
          ? 'https://image.tmdb.org/t/p/w500$backdropPath'
          : '';

  /// Creates TvShow from JSON.
  factory TvShow.fromJson(Map<String, dynamic> json) {
    return TvShow(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      originalName: json['original_name'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      firstAirDate: json['first_air_date'] ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] ?? 0,
      genreIds: (json['genre_ids'] as List?)?.cast<int>() ?? [],
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0.0,
      originalLanguage: json['original_language'] ?? '',
      originCountry: (json['origin_country'] as List?)?.cast<String>() ?? [],
    );
  }

  /// Converts TvShow to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'original_name': originalName,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'first_air_date': firstAirDate,
      'vote_average': voteAverage,
      'vote_count': voteCount,
      'genre_ids': genreIds,
      'popularity': popularity,
      'original_language': originalLanguage,
      'origin_country': originCountry,
    };
  }
}
