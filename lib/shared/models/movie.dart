import 'package:movie_watchlist/shared/models/cast_members.dart';

class Movie {
  final int id;
  final String title;
  final String originalTitle;
  final String posterPath;
  final String backdropPath;
  final String releaseDate;
  final double voteAverage;
  final int voteCount;
  final String overview;
  final List<int> genreIds;
  final double popularity;
  final String originalLanguage;
  // new fields
  final int runtime; // in minutes
  final List<String> genres; // genre names
  final String? trailerKey; // YouTube trailer key
  final List<CastMember> cast;

  Movie({
    required this.id,
    required this.title,
    required this.originalTitle,
    required this.posterPath,
    required this.backdropPath,
    required this.releaseDate,
    required this.voteAverage,
    required this.voteCount,
    required this.overview,
    required this.genreIds,
    required this.popularity,
    required this.originalLanguage,
    this.runtime = 0,
    this.genres = const [],
    this.trailerKey,
    this.cast = const [],
  });

  String get posterUrl =>
      posterPath.isNotEmpty ? 'https://image.tmdb.org/t/p/w500$posterPath' : '';

  String get backdropUrl => backdropPath.isNotEmpty
      ? 'https://image.tmdb.org/t/p/w780$backdropPath'
      : '';

  factory Movie.fromJson(Map<String, dynamic> json) {
    // Parse genres
    final List<String> genres =
        (json['genres'] as List?)?.map((g) => g['name'] as String).toList() ??
        [];

    // Parse videos
    final videos = json['videos']?['results'] as List?;
    String? trailerKey;
    if (videos != null) {
      for (final v in videos) {
        if (v['type'] == 'Trailer' && v['site'] == 'YouTube') {
          trailerKey = v['key'];
          break;
        }
      }
    }

    // Parse cast
    final credits = json['credits']?['cast'] as List?;
    final List<CastMember> cast =
        credits
            ?.map(
              (c) => CastMember(
                name: c['name'] ?? '',
                profilePath: c['profile_path'],
              ),
            )
            .toList() ??
        [];

    return Movie(
      id: json['id'],
      title: json['title'] ?? '',
      originalTitle: json['original_title'] ?? '',
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      releaseDate: json['release_date'] ?? '',
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      voteCount: json['vote_count'] ?? 0,
      overview: json['overview'] ?? '',
      genreIds: List<int>.from(json['genre_ids'] ?? []),
      popularity: (json['popularity'] ?? 0).toDouble(),
      originalLanguage: json['original_language'] ?? '',
      runtime: json['runtime'] ?? 0,
      genres: genres,
      trailerKey: trailerKey,
      cast: cast,
    );
  }
}
