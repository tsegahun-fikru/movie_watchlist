// lib/shared/models/search_result_item.dart

class SearchResultItem {
  final int id;
  final String title;
  final String posterUrl;
  final double voteAverage;
  final Object originalItem;

  const SearchResultItem({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.voteAverage,
    required this.originalItem,
  });
}
