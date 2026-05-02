// lib/features/movie_details/presentation/widgets/cast_movies_sheet.dart
// Bottom sheet that shows a grid of movies featuring a selected cast member.

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_watchlist/core/theme/app_colors.dart';
import 'package:movie_watchlist/features/movies/data/repositories/legacy_tmdb_repository.dart';
import 'package:movie_watchlist/shared/models/movie.dart';

/// Shows a draggable bottom sheet with movies featuring the given actor.
///
/// Fetches the actor's filmography via [LegacyTmdbRepository.searchPersonMovies]
/// and displays the results in a 3-column grid.
Future<void> showCastMoviesSheet(
  BuildContext context,
  LegacyTmdbRepository repository,
  String actorName,
) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CastMoviesSheet(
      repository: repository,
      actorName: actorName,
    ),
  );
}

class _CastMoviesSheet extends StatefulWidget {
  final LegacyTmdbRepository repository;
  final String actorName;

  const _CastMoviesSheet({
    required this.repository,
    required this.actorName,
  });

  @override
  State<_CastMoviesSheet> createState() => _CastMoviesSheetState();
}

class _CastMoviesSheetState extends State<_CastMoviesSheet> {
  late Future<List<Movie>> _moviesFuture;

  @override
  void initState() {
    super.initState();
    _moviesFuture = widget.repository.searchPersonMovies(widget.actorName);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle bar
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header with actor name and close button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Movies featuring',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            widget.actorName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: Colors.white10),

              // Movie grid
              Expanded(
                child: FutureBuilder<List<Movie>>(
                  future: _moviesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'Could not load movies.\n${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }

                    final movies = snapshot.data ?? [];
                    if (movies.isEmpty) {
                      return const Center(
                        child: Text(
                          'No movies found.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      );
                    }

                    return GridView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.6,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: movies.length,
                      itemBuilder: (_, i) {
                        final movie = movies[i];
                        return _MoviePosterCard(movie: movie);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A small poster card used inside the cast movies grid.
class _MoviePosterCard extends StatelessWidget {
  final Movie movie;
  const _MoviePosterCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        context.push('/details', extra: movie);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: movie.posterUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: movie.posterUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (_, __) =>
                          Container(color: AppColors.surfaceLight),
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.surfaceLight,
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      color: AppColors.surfaceLight,
                      child: const Center(
                        child: Icon(
                          Icons.movie,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            movie.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
