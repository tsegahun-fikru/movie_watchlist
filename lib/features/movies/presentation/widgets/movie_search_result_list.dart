// lib/features/movies/presentation/widgets/movie_search_result_list.dart
// Scrollable list of movie search results with skeleton loading, error, and
// empty states. Supports infinite scroll via an external [ScrollController].

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_watchlist/app/router/media_routes.dart';
import 'package:movie_watchlist/core/theme/app_colors.dart';
import 'package:movie_watchlist/core/di/clean_arch_providers.dart';
import 'package:movie_watchlist/features/movies/domain/entities/movie.dart';

/// Renders the list of movies from [movieSearchNotifierProvider].
///
/// [scrollController] is provided by the parent so it can detect when the
/// user is near the bottom and trigger [loadNextPage].
class MovieSearchResultList extends ConsumerWidget {
  const MovieSearchResultList({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(
      movieSearchNotifierProvider.select((state) => state.results),
    );
    final isLoading = ref.watch(
      movieSearchNotifierProvider.select((state) => state.isLoading),
    );
    final isLoadingMore = ref.watch(
      movieSearchNotifierProvider.select((state) => state.isLoadingMore),
    );
    final error = ref.watch(
      movieSearchNotifierProvider.select((state) => state.error),
    );

    // Show skeleton tiles during the initial load
    if (isLoading && results.isEmpty) {
      return ListView.separated(
        controller: scrollController,
        itemCount: 8,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) => const _SkeletonTile(),
      );
    }

    if (error != null && results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            error,
            style: const TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (results.isEmpty) {
      return const Center(
        child: Text(
          'No movies found.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      controller: scrollController,
      itemCount: results.length + (isLoadingMore ? 1 : 0),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        // Show a spinner at the bottom while loading the next page
        if (index >= results.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final movie = results[index];
        return _MovieSearchTile(movie: movie);
      },
    );
  }
}

/// A single row tile for a movie search result.
///
/// Navigates with stable route parameters so search results support cold
/// starts and state restoration.
class _MovieSearchTile extends StatelessWidget {
  const _MovieSearchTile({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    final releaseYear = movie.releaseDate.length >= 4
        ? movie.releaseDate.substring(0, 4)
        : 'TBA';

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        context.push(mediaDetailsPathById('movie', movie.id));
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Poster thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 92,
                height: 132,
                child: movie.posterPath.isEmpty
                    ? Container(
                        color: AppColors.surfaceLight,
                        child: const Icon(
                          Icons.local_movies_outlined,
                          color: AppColors.textTertiary,
                        ),
                      )
                    : CachedNetworkImage(
                        imageUrl:
                            'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // Movie info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$releaseYear • ${movie.rating.toStringAsFixed(1)}',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    movie.overview.isEmpty
                        ? 'No overview available.'
                        : movie.overview,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textTertiary.withValues(alpha: 0.85),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder tile shown while the initial search results are loading.
class _SkeletonTile extends StatelessWidget {
  const _SkeletonTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 156,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
