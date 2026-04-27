// lib/features/watchlist/data/models/watchlist_item.dart
import 'package:movie_watchlist/shared/models/movie.dart';
import 'package:movie_watchlist/shared/models/tv_show.dart';

class WatchlistItem {
  final int id;
  final String type; // 'movie' or 'tv'
  final Map<String, dynamic> data;

  const WatchlistItem({
    required this.id,
    required this.type,
    required this.data,
  });

  /// Construct from Firestore document data.
  /// docId: 'movie_123' or 'tv_456' or legacy '12345'
  factory WatchlistItem.fromFirestore(String docId, Map<String, dynamic> json) {
    int id;
    String type;

    // Legacy support: old docs had numeric-only IDs like "12345"
    if (!docId.contains('_')) {
      id = int.parse(docId);
      type = 'movie';
    } else {
      final parts = docId.split('_');
      id = int.parse(parts.last);
      type = parts.first;
    }

    // 🔥 Inject the id into the data map so the models can read it
    json['id'] = id;

    return WatchlistItem(id: id, type: type, data: json);
  }

  /// Convert back to the original model.
  Object toOriginal() {
    if (type == 'movie') {
      return Movie.fromJson(data);
    } else if (type == 'tv') {
      return TvShow.fromJson(data);
    }
    // Fallback – should never be reached with the inject above
    return Movie.fromJson(data);
  }

  /// Common title (used in notifications).
  String get title {
    if (type == 'movie') return data['title'] ?? '';
    if (type == 'tv') return data['name'] ?? '';
    return '';
  }

  /// The Firestore document ID.
  String get docId => '${type}_$id';
}
