// lib/shared/models/cast_members.dart
// Plain Dart model representing a single cast member returned by TMDB.

/// Represents an actor or crew member from the TMDB credits endpoint.
class CastMember {
  final String name;

  /// TMDB profile image path (e.g. `/abc123.jpg`). May be null if unavailable.
  final String? profilePath;

  /// The character name this person plays in the title.
  final String character;

  /// Constructs the full TMDB image URL for the profile photo (w200 size).
  /// Returns an empty string when [profilePath] is null.
  String get profileUrl =>
      profilePath != null ? 'https://image.tmdb.org/t/p/w200$profilePath' : '';

  const CastMember({
    required this.name,
    this.profilePath,
    this.character = '',
  });
}
