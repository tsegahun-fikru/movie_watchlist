import 'package:movie_watchlist/shared/models/cast_members.dart';

class TvShow {
  final int id;
  final String name;
  final String originalName;
  final String posterPath;
  final String backdropPath;
  final String firstAirDate;
  final double voteAverage;
  final int voteCount;
  final String overview;
  final List<int> genreIds;
  final double popularity;
  final String originalLanguage;
  final List<String> originCountry;
  // new fields
  final List<int> episodeRunTime; // episode lengths (usually one element)
  final int numberOfSeasons;
  final List<String> genres;
  final String? trailerKey;
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

  String get fullPosterUrl =>
      posterPath.isNotEmpty ? 'https://image.tmdb.org/t/p/w500$posterPath' : '';
  String get fullBackdropUrl => backdropPath.isNotEmpty
      ? 'https://image.tmdb.org/t/p/w780$backdropPath'
      : '';

  factory TvShow.fromJson(Map<String, dynamic> json) {
    final List<String> genres =
        (json['genres'] as List?)?.map((g) => g['name'] as String).toList() ??
        [];

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
