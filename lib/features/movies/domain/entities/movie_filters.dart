class MovieFilters {
  const MovieFilters({this.genreId, this.year, this.minimumRating});

  final int? genreId;
  final int? year;
  final double? minimumRating;

  bool get isEmpty => genreId == null && year == null && minimumRating == null;

  MovieFilters copyWith({
    int? genreId,
    bool clearGenre = false,
    int? year,
    bool clearYear = false,
    double? minimumRating,
    bool clearRating = false,
  }) {
    return MovieFilters(
      genreId: clearGenre ? null : genreId ?? this.genreId,
      year: clearYear ? null : year ?? this.year,
      minimumRating: clearRating ? null : minimumRating ?? this.minimumRating,
    );
  }
}
