// lib/shared/models/tv_show.dart
// Shared TvShow model used across features (home, search, watchlist, details).
// Mirrors the structure of [Movie] but adapted for TV-specific TMDB fields.

import 'package:movie_watchlist/shared/models/cast_members.dart';
import 'package:movie_watchlist/core/domain/entities/media_item.dart';

/// Represents a TV show from the TMDB API.
///
/// Like [Movie], fields such as [genres], [trailerKey], [cast], and
/// [numberOfSeasons] are only populated when the detail endpoint is used
/// (`/tv/{id}?append_to_response=videos,credits`).
class TvShow implements MediaItem {
  @override
  final int id;
  final String name;
  final String originalName;
  @override
  final String posterPath;
  @override
  final String backdropPath;
  final String firstAirDate;
  final double voteAverage;
  final int voteCount;
  @override
  final String overview;

  /// Genre IDs from list endpoints (e.g. /tv/popular).
  @override
  final List<int> genreIds;
  final double popularity;
  final String originalLanguage;
  final List<String> originCountry;

  /// Typical episode lengths in minutes (usually one element). Only from detail endpoint.
  final List<int> episodeRunTime;

  /// Total number of seasons. Only from detail endpoint.
  final int numberOfSeasons;

  /// Human-readable genre names. Only from detail endpoint.
  final List<String> genres;

  /// YouTube video key for the official trailer. Only from detail endpoint.
  final String? trailerKey;

  /// Top-billed cast members. Only from detail endpoint.
  final List<CastMember> cast;

  TvShow({
    required this.id,
    required this.name,
    required this.originalName,
    required this.posterPath,
    required this.backdropPath,
    required this.firstAirDate,
    required this.voteAverage,
    required this.voteCount,
    required this.overview,
    required this.genreIds,
    required this.popularity,
    required this.originalLanguage,
    required this.originCountry,
    this.episodeRunTime = const [],
    this.numberOfSeasons = 0,
    this.genres = const [],
    this.trailerKey,
    this.cast = const [],
  });

  /// Full TMDB poster URL at w500 resolution. Empty string if no path.
  String get fullPosterUrl =>
      posterPath.isNotEmpty ? 'https://image.tmdb.org/t/p/w500$posterPath' : '';

  /// Full TMDB backdrop URL at w780 resolution. Empty string if no path.
  String get fullBackdropUrl => backdropPath.isNotEmpty
      ? 'https://image.tmdb.org/t/p/w780$backdropPath'
      : '';

  @override
  String get title => name;

  @override
  String get releaseDate => firstAirDate;

  @override
  double get rating => voteAverage;

  @override
  String get type => 'tv';

  @override
  String get posterUrl => fullPosterUrl;

  @override
  String get backdropUrl => fullBackdropUrl;

  /// Parses a [TvShow] from a TMDB JSON map.
  ///
  /// Handles both list-endpoint responses and detail-endpoint responses
  /// (with appended videos and credits).
  factory TvShow.fromJson(Map<String, dynamic> json) {
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

    return TvShow(
      id: json['id'],
      name: json['name'] ?? '',
      originalName: json['original_name'] ?? '',
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      firstAirDate: json['first_air_date'] ?? '',
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      voteCount: json['vote_count'] ?? 0,
      overview: json['overview'] ?? '',
      genreIds: List<int>.from(json['genre_ids'] ?? []),
      popularity: (json['popularity'] ?? 0).toDouble(),
      originalLanguage: json['original_language'] ?? '',
      originCountry: List<String>.from(json['origin_country'] ?? []),
      episodeRunTime: List<int>.from(json['episode_run_time'] ?? []),
      numberOfSeasons: json['number_of_seasons'] ?? 0,
      genres: genres,
      trailerKey: trailerKey,
      cast: cast,
    );
  }
}
