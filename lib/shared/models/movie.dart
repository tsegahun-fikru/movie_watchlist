// lib/shared/models/movie.dart
// Shared Movie model used across features (home, search, watchlist, details).
// Parsed from TMDB JSON responses; supports both list endpoints (genre_ids)
// and detail endpoints (genres, videos, credits).

import 'package:movie_watchlist/shared/models/cast_members.dart';

/// Represents a movie from the TMDB API.
///
/// Fields like [genres], [trailerKey], and [cast] are only populated when
/// the detail endpoint (`/movie/{id}?append_to_response=videos,credits`) is
/// used. List endpoints populate [genreIds] instead.
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

  /// Genre IDs from list endpoints (e.g. /movie/popular).
  final List<int> genreIds;
  final double popularity;
  final String originalLanguage;

  /// Runtime in minutes. Only available from the detail endpoint.
  final int runtime;

  /// Human-readable genre names. Only available from the detail endpoint.
  final List<String> genres;

  /// YouTube video key for the official trailer. Only available from the
  /// detail endpoint when `append_to_response=videos` is used.
  final String? trailerKey;

  /// Top-billed cast members. Only available from the detail endpoint when
  /// `append_to_response=credits` is used.
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

  /// Full TMDB poster URL at w500 resolution. Empty string if no path.
  String get posterUrl =>
      posterPath.isNotEmpty ? 'https://image.tmdb.org/t/p/w500$posterPath' : '';

  /// Full TMDB backdrop URL at w780 resolution. Empty string if no path.
  String get backdropUrl => backdropPath.isNotEmpty
      ? 'https://image.tmdb.org/t/p/w780$backdropPath'
      : '';

  /// Parses a [Movie] from a TMDB JSON map.
  ///
  /// Handles both list-endpoint responses (no genres/videos/credits) and
  /// detail-endpoint responses (with appended data).
  factory Movie.fromJson(Map<String, dynamic> json) {
    // Parse genre names from the detail endpoint's genres array
    final List<String> genres =
        (json['genres'] as List?)?.map((g) => g['name'] as String).toList() ??
        [];

    // Extract the first YouTube trailer key from the videos array
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

    // Parse cast members from the credits array
    final credits = json['credits']?['cast'] as List?;
    final List<CastMember> cast =
        credits
            ?.map(
              (c) => CastMember(
                name: c['name'] ?? '',
                profilePath: c['profile_path'],
                character: c['character'] ?? '',
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
