// lib/core/widgets/buttons/watchlist_button.dart
// VERSION 2 - Adds Riverpod provider integration.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_watchlist/features/watchlist/presentation/providers/watchlist_providers.dart';

/// Watchlist button with Riverpod provider.
/// TODO v3: Add optimistic updates, error handling
class WatchlistButton extends ConsumerWidget {
  final int movieId;
  final String title;
  final String posterPath;

  const WatchlistButton({
    super.key,
    required this.movieId,
    required this.title,
    required this.posterPath,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlistAsync = ref.watch(watchlistStreamProvider);

    return watchlistAsync.when(
      data: (items) {
        final isInWatchlist = items.any((item) => item.id == movieId);

        return IconButton(
          icon: Icon(
            isInWatchlist ? Icons.bookmark : Icons.bookmark_border,
            color: isInWatchlist ? Colors.red : Colors.white,
          ),
          onPressed: () async {
            if (isInWatchlist) {
              // TODO v3: Add confirmation dialog
              await ref
                  .read(watchlistServiceProvider)
                  .removeFromWatchlist(movieId);
            } else {
              await ref.read(watchlistServiceProvider).addToWatchlist(
                    movieId,
                    title,
                    posterPath,
                    'movie',
                  );
            }
          },
        );
      },
      loading: () => const IconButton(
        icon: Icon(Icons.bookmark_border, color: Colors.grey),
        onPressed: null,
      ),
      error: (_, __) => const IconButton(
        icon: Icon(Icons.bookmark_border, color: Colors.grey),
        onPressed: null,
      ),
    );
  }
}
