// lib/features/watchlist/presentation/widgets/watchlist_card.dart
// VERSION 1 - Simple watchlist card widget.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_watchlist/shared/models/movie.dart';
import 'package:movie_watchlist/shared/models/tv_show.dart';
import 'package:movie_watchlist/features/watchlist/presentation/providers/watchlist_providers.dart';

/// Card widget for displaying a watchlist item.
/// TODO v2: Add CachedNetworkImage for posters
class WatchlistCard extends ConsumerWidget {
  final Movie? movie;
  final TvShow? tvShow;

  const WatchlistCard({
    super.key,
    this.movie,
    this.tvShow,
  });

  String get _title => movie?.title ?? tvShow?.name ?? '';
  String get _type => movie != null ? 'Movie' : 'TV';
  double get _rating => movie?.voteAverage ?? tvShow?.voteAverage ?? 0.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster placeholder
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: const Center(
                child: Icon(Icons.movie, color: Colors.grey, size: 48),
              ),
            ),
          ),

          // Info section
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _type,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // Title
                Text(
                  _title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),

                // Rating
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 3),
                    Text(
                      _rating.toStringAsFixed(1),
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                    const Spacer(),

                    // Remove button
                    GestureDetector(
                      onTap: () => _removeItem(ref),
                      child: Icon(
                        Icons.remove_circle_outline,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _removeItem(WidgetRef ref) {
    final service = ref.read(watchlistServiceProvider);
    final item = movie ?? tvShow;
    if (item != null) {
      service.removeItem(item);
      // Trigger rebuild
      ref.read(watchlistChangeNotifierProvider.notifier).state++;
    }
  }
}
