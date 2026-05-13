// lib/shared/models/search_result_item.dart
// VERSION 2 - Unified search result model for mixed Movie/TV results.

/// Unified search result for displaying movies and TV shows together.
/// TODO v3: Add media type enum, better type safety
class SearchResultItem {
  final int id;
  final String title;
  final String posterUrl;
  final double voteAverage;
  final Object originalItem; // Movie or TvShow

  SearchResultItem({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.voteAverage,
    required this.originalItem,
  });

  /// Creates SearchResultItem from JSON.
  factory SearchResultItem.fromJson(Map<String, dynamic> json) {
    return SearchResultItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      posterUrl: json['poster_url'] ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      originalItem: json['original_item'] ?? {},
    );
  }

  /// Converts SearchResultItem to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'poster_url': posterUrl,
      'vote_average': voteAverage,
      'original_item': originalItem,
    };
  }
}
