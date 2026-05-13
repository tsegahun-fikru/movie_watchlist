// lib/features/watchlist/presentation/widgets/watchlist_card.dart
// VERSION 2 - Watchlist card with CachedNetworkImage.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movie_watchlist/shared/models/movie.dart';
import 'package:movie_watchlist/shared/models/tv_show.dart';
import 'package:movie_watchlist/features/watchlist/presentation/providers/watchlist_providers.dart';

/// Card widget for displaying a watchlist item with poster image.
/// TODO v3: Add long-press menu, swipe to delete
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
  String get _posterUrl {
    if (movie != null) return movie!.posterUrl;
    if (tvShow != null) return tvShow!.fullPosterUrl;
    return '';
  }

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
          // Poster image
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: _posterUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: _posterUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (_, __) => Container(
                        color: Colors.grey[800],
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
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

                // Rating and remove button
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
                      onTap: () => _confirmRemove(context, ref),
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

  Widget _placeholder() {
    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: Icon(Icons.movie, color: Colors.grey, size: 48),
      ),
    );
  }

  void _confirmRemove(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Remove "$_title"?',
          style: const TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This will remove it from your watchlist.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final service = ref.read(watchlistServiceProvider);
              final item = movie ?? tvShow;
              if (item != null) {
                await service?.removeItem(item);
              }
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
