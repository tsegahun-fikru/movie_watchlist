// lib/core/widgets/movie_card.dart
// Compact movie card used in horizontal scrolling lists throughout the app.

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_watchlist/core/theme/app_colors.dart';
import 'package:movie_watchlist/shared/models/movie.dart';

/// A fixed-width card that displays a movie poster, title, rating, and year.
///
/// Tapping navigates to [DetailScreen] via `/details` with the [Movie] as
/// `extra`. Uses a [Hero] animation keyed on `'movie-${movie.id}'`.
class MovieCard extends StatelessWidget {
  final Movie movie;
  const MovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/details', extra: movie),
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'movie-${movie.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: movie.posterUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: movie.posterUrl,
                        height: 170,
                        width: 120,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          height: 170,
                          width: 120,
                          color: AppColors.surfaceLight,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (_, __, ___) => _placeholder(),
                        fadeInDuration: const Duration(milliseconds: 200),
                      )
                    : _placeholder(),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              movie.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.star_rounded, color: AppColors.star, size: 12),
                const SizedBox(width: 3),
                Text(
                  movie.voteAverage.toStringAsFixed(1),
                  style: const TextStyle(
                      color: AppColors.textTertiary, fontSize: 11),
                ),
                // Only show the year if the release date is long enough
                if (movie.releaseDate.length >= 4) ...[
                  const SizedBox(width: 6),
                  Text(
                    movie.releaseDate.substring(0, 4),
                    style: const TextStyle(
                        color: AppColors.textTertiary, fontSize: 11),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Fallback widget shown when the poster URL is empty or fails to load.
  Widget _placeholder() {
    return Container(
      height: 170,
      width: 120,
      color: AppColors.surface,
      child: const Center(
        child: Icon(Icons.movie, color: AppColors.textTertiary, size: 40),
      ),
    );
  }
}
