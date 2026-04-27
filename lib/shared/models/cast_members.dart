class CastMember {
  final String name;
  final String? profilePath;

  String get profileUrl =>
      profilePath != null ? 'https://image.tmdb.org/t/p/w200$profilePath' : '';

  const CastMember({required this.name, this.profilePath});
}
