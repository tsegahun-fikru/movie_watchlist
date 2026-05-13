// lib/shared/models/tv_episode.dart
// VERSION 2 - TV episode model with details.

/// TV episode model.
/// TODO v3: Add guest stars, crew, runtime
class TvEpisode {
  final int id;
  final String name;
  final int episodeNumber;
  final int seasonNumber;
  final String airDate;
  final String overview;
  final String stillPath;
  final double voteAverage;

  TvEpisode({
    required this.id,
    required this.name,
    required this.episodeNumber,
    required this.seasonNumber,
    this.airDate = '',
    this.overview = '',
    this.stillPath = '',
    this.voteAverage = 0.0,
  });

  /// Full TMDB still image URL.
  String get stillUrl =>
      stillPath.isNotEmpty
          ? 'https://image.tmdb.org/t/p/w300$stillPath'
          : '';

  /// Creates TvEpisode from JSON.
  factory TvEpisode.fromJson(Map<String, dynamic> json) {
    return TvEpisode(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      episodeNumber: json['episode_number'] ?? 0,
      seasonNumber: json['season_number'] ?? 0,
      airDate: json['air_date'] ?? '',
      overview: json['overview'] ?? '',
      stillPath: json['still_path'] ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Converts TvEpisode to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'episode_number': episodeNumber,
      'season_number': seasonNumber,
      'air_date': airDate,
      'overview': overview,
      'still_path': stillPath,
      'vote_average': voteAverage,
    };
  }
}
