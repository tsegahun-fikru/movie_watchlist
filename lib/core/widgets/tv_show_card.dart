// lib/core/widgets/tv_show_card.dart
// Compact TV show card used in horizontal scrolling lists, mirroring the
// layout of [MovieCard] but adapted for [TvShow] data.

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_watchlist/core/theme/app_colors.dart';
import 'package:movie_watchlist/shared/models/tv_show.dart';

/// A fixed-width card that displays a TV show poster, name, rating, and year.
///
/// Tapping navigates to [DetailScreen] via `/details` with the [TvShow] as
/// `extra`. Uses a [Hero] animation keyed on `'tv-${tvShow.id}'`.
class TvShowCard extends StatelessWidget {
  final TvShow tvShow;

  const TvShowCard({super.key, required this.tvShow});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/details', extra: tvShow),
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'tv-${tvShow.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: tvShow.fullPosterUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: tvShow.fullPosterUrl,
                        height: 170,
                        width: 120,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              tvShow.name,
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
                  tvShow.voteAverage.toStringAsFixed(1),
                  style: const TextStyle(
                      color: AppColors.textTertiary, fontSize: 11),
                ),
                // Only show the year if the air date is long enough
                if (tvShow.firstAirDate.length >= 4) ...[
                  const SizedBox(width: 6),
                  Text(
                    tvShow.firstAirDate.substring(0, 4),
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

  Widget _placeholder() => Container(
        height: 170,
        width: 120,
        color: AppColors.surface,
        child: const Center(
            child: Icon(Icons.tv, color: AppColors.textTertiary, size: 40)),
      );
}
