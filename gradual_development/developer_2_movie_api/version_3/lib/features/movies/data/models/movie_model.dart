import 'package:movie_watchlist/features/movies/domain/entities/movie.dart';

class MovieModel {
  const MovieModel({
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

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    final rawGenreIds =
        json['genre_ids'] as List<dynamic>? ??
        (json['genres'] as List<dynamic>?)
            ?.map((genre) => genre['id'])
            .toList() ??
        const <dynamic>[];

    return MovieModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      overview: json['overview'] as String? ?? '',
      posterPath: json['poster_path'] as String? ?? '',
      releaseDate: json['release_date'] as String? ?? '',
      rating: (json['vote_average'] as num? ?? 0).toDouble(),
      genreIds: rawGenreIds.map((genreId) => genreId as int).toList(),
    );
  }

  Movie toEntity() {
    return Movie(
      id: id,
      title: title,
      overview: overview,
      posterPath: posterPath,
      releaseDate: releaseDate,
      rating: rating,
      genreIds: genreIds,
    );
  }
}
