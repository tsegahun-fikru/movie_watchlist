// lib/features/watchlist/presentation/screens/watchlist_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_watchlist/core/theme/app_colors.dart';
import 'package:movie_watchlist/features/watchlist/presentation/providers/watchlist_providers.dart';

import 'package:go_router/go_router.dart';
import 'package:movie_watchlist/features/watchlist/presentation/widgets/watchlist_card.dart';
import 'package:movie_watchlist/core/widgets/tv_show_card.dart';
import 'package:movie_watchlist/shared/models/movie.dart';
import 'package:movie_watchlist/shared/models/tv_show.dart';

class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlistAsync = ref.watch(watchlistStreamProvider);

    return watchlistAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return const Center(
            child: Text(
              'Your saved movies and TV shows appear here.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: GridView.builder(
            physics: const ClampingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: items.length,
            itemBuilder: (_, i) {
              final watchItem = items[i];
              final original = watchItem.toOriginal();

              Widget card;
              if (original is Movie) {
                card = WatchlistCard(movie: original);
              } else if (original is TvShow) {
                card = TvShowCard(tvShow: original);
              } else {
                return const SizedBox.shrink();
              }

              return GestureDetector(
                onTap: () => context.push('/details', extra: original),
                child: card,
              );
            },
          ),
        );
      },
      loading: () =>
          const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (error, _) => Center(
        child: Text('Error: $error', style: const TextStyle(color: AppColors.error)),
      ),
    );
  }
}
