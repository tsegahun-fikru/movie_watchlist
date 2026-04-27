import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_watchlist/core/theme/app_colors.dart';
import 'package:movie_watchlist/core/di/clean_arch_providers.dart';
import 'package:movie_watchlist/features/movies/domain/entities/movie.dart';
import 'package:movie_watchlist/shared/models/movie.dart' as legacy;

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
        context.push(
          '/details',
          extra: legacy.Movie(
            id: movie.id,
            title: movie.title,
            originalTitle: movie.title,
            posterPath: movie.posterPath,
            backdropPath: '',
            releaseDate: movie.releaseDate,
            voteAverage: movie.rating,
            voteCount: 0,
            overview: movie.overview,
            genreIds: movie.genreIds,
            popularity: 0,
            originalLanguage: '',
          ),
        );
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
                    style: TextStyle(color: AppColors.textTertiary.withOpacity(0.85), height: 1.4),
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
