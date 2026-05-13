// lib/features/home/presentation/widgets/recommendations_row.dart
// VERSION 2 - Basic recommendations based on hardcoded genre.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_watchlist/core/widgets/movie_card.dart';
import 'package:movie_watchlist/core/widgets/shimmer_loading.dart';
import 'package:movie_watchlist/core/widgets/movie_card_skeleton.dart';
import 'package:movie_watchlist/features/movies/presentation/providers/movie_providers.dart';
import 'package:movie_watchlist/shared/models/movie.dart';

/// Simple recommendations provider using popular movies.
/// TODO v3: Derive genre from user's watchlist and fetch personalized recommendations
final recommendationsProvider = FutureProvider<List<Movie>>((ref) async {
  // For now, just return popular movies as recommendations
  final popular = await ref.watch(legacyTmdbRepositoryProvider).fetchPopularMovies();
  return popular.take(10).toList();
});

/// Horizontal row of recommended movies.
/// TODO v3: Personalize based on watchlist genres
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
                  const Icon(Icons.recommend, color: Colors.red, size: 18),
                  const SizedBox(width: 6),
                  const Text(
                    'Recommended For You',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
