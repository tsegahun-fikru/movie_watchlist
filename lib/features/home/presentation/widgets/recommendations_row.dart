// lib/features/home/presentation/widgets/recommendations_row.dart
// Personalised recommendations row shown on the home screen.
// Derives the user's favourite genre from their watchlist and fetches
// matching movies from TMDB.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_watchlist/core/theme/app_colors.dart';
import 'package:movie_watchlist/core/widgets/movie_card.dart';
import 'package:movie_watchlist/core/widgets/shimmer_loading.dart';
import 'package:movie_watchlist/core/widgets/movie_card_skeleton.dart';
import 'package:movie_watchlist/features/movies/presentation/providers/movie_providers.dart';
import 'package:movie_watchlist/features/watchlist/presentation/providers/watchlist_providers.dart';
import 'package:movie_watchlist/shared/models/movie.dart';

/// Fetches movies based on the most common genre in the user's watchlist.
///
/// Algorithm:
/// 1. Collect all genre IDs from watchlist items.
/// 2. Find the most frequently occurring genre ID.
/// 3. Discover movies for that genre via TMDB.
/// 4. Filter out movies already in the watchlist and those without posters.
///
/// Returns an empty list (and the row is hidden) when the watchlist is empty
/// or the fetch fails.
final recommendationsProvider = FutureProvider<List<Movie>>((ref) async {
  final watchlistItems = ref.watch(watchlistStreamProvider).valueOrNull ?? [];
  if (watchlistItems.isEmpty) return [];

  // Tally genre IDs across all watchlist items
  final genreFrequency = <int, int>{};
  for (final item in watchlistItems) {
    final genreIds = (item.data['genre_ids'] as List?)
            ?.map((e) => e as int)
            .toList() ??
        [];
    for (final id in genreIds) {
      genreFrequency[id] = (genreFrequency[id] ?? 0) + 1;
    }
  }
  if (genreFrequency.isEmpty) return [];

  // Pick the most frequent genre
  final topGenreId = genreFrequency.entries
      .reduce((a, b) => a.value >= b.value ? a : b)
      .key;

  final repo = ref.read(legacyTmdbRepositoryProvider);
  final results = await repo.discoverMovies(genreIds: [topGenreId]);

  // Exclude movies already saved to the watchlist
  final watchlistIds = watchlistItems
      .where((i) => i.type == 'movie')
      .map((i) => i.id)
      .toSet();

  return results
      .where((m) => !watchlistIds.contains(m.id) && m.posterPath.isNotEmpty)
      .take(20)
      .toList();
});

/// Horizontal scrolling row of recommended movies.
///
/// Silently hidden when the watchlist is empty or the fetch fails.
class RecommendationsRow extends ConsumerWidget {
  const RecommendationsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncRecs = ref.watch(recommendationsProvider);

    return asyncRecs.when(
      data: (movies) {
        if (movies.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  const Icon(Icons.recommend,
                      color: AppColors.primary, size: 18),
                  const SizedBox(width: 6),
                  const Text(
                    'Recommended For You',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 260,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: movies.length,
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => context.push('/details', extra: movies[i]),
                  child: MovieCard(movie: movies[i]),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: 5,
              itemBuilder: (_, __) =>
                  const ShimmerLoading(child: MovieCardSkeleton()),
            ),
          ),
        ],
      ),
      // Silently hide on error — recommendations are non-critical
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
