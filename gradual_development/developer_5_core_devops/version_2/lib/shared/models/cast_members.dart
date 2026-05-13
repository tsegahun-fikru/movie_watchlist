// lib/shared/models/cast_members.dart
// VERSION 2 - Cast member model with profile images.

/// Cast member model.
/// TODO v3: Add character details, biography
class CastMember {
  final int id;
  final String name;
  final String character;
  final String profilePath;
  final int order;

  CastMember({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath = '',
    this.order = 0,
  });

  /// Full TMDB profile image URL.
  String get profileUrl =>
      profilePath.isNotEmpty
          ? 'https://image.tmdb.org/t/p/w185$profilePath'
          : '';

  /// Creates CastMember from JSON.
  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      character: json['character'] ?? '',
      profilePath: json['profile_path'] ?? '',
      order: json['order'] ?? 0,
    );
  }

  /// Converts CastMember to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'character': character,
      'profile_path': profilePath,
      'order': order,
    };
  }
}
