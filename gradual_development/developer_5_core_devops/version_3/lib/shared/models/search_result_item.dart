// lib/shared/models/search_result_item.dart
// Unified search result model that normalises Movie and TvShow into a single
// type for display in mixed search result lists.

/// A normalised search result that can represent either a [Movie] or a [TvShow].
///
/// [originalItem] holds the underlying typed object so callers can cast it
/// back when navigating to the detail screen.
class SearchResultItem {
  final int id;
  final String title;
  final String posterUrl;
  final double voteAverage;

  /// The original [Movie] or [TvShow] object. Cast before use.
  final Object originalItem;

  const SearchResultItem({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.voteAverage,
    required this.originalItem,
  });
}
