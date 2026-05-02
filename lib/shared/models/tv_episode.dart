// lib/shared/models/tv_episode.dart
// Model for a single TV episode returned by the TMDB season endpoint.

/// Represents one episode within a TV show season.
///
/// Parsed from the TMDB `/tv/{id}/season/{season_number}` endpoint.
class TvEpisode {
  final int id;
  final int episodeNumber;
  final String name;
  final String overview;
  final String airDate;
  final double voteAverage;

  /// TMDB still image path (e.g. `/abc123.jpg`). May be null.
  final String? stillPath;

  /// Episode runtime in minutes. May be 0 if not provided by TMDB.
  final int runtime;

  const TvEpisode({
    required this.id,
    required this.episodeNumber,
    required this.name,
    required this.overview,
    required this.airDate,
    required this.voteAverage,
    this.stillPath,
    this.runtime = 0,
  });

  /// Full TMDB still image URL at w300 resolution. Empty string if no path.
  String get stillUrl => stillPath != null && stillPath!.isNotEmpty
      ? 'https://image.tmdb.org/t/p/w300$stillPath'
      : '';

  factory TvEpisode.fromJson(Map<String, dynamic> json) {
    return TvEpisode(
      id: json['id'] ?? 0,
      episodeNumber: json['episode_number'] ?? 0,
      name: json['name'] ?? '',
      overview: json['overview'] ?? '',
      airDate: json['air_date'] ?? '',
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      stillPath: json['still_path'],
      runtime: json['runtime'] ?? 0,
    );
  }
}
