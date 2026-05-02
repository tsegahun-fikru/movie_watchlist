// lib/features/watchlist/presentation/widgets/watchlist_card.dart
// Card widget used in the watchlist grid. Displays the movie poster and title.

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movie_watchlist/core/theme/app_colors.dart';
import 'package:movie_watchlist/shared/models/movie.dart';

/// A grid card that shows a [Movie]'s poster and title.
///
/// Used inside the watchlist screen's [GridView]. Navigation to the detail
/// screen is handled by the parent [GestureDetector] in [WatchlistScreen].
class WatchlistCard extends StatelessWidget {
  final Movie movie;

  const WatchlistCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.surface,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Poster — fills the available space above the title
          Expanded(
            child: movie.posterUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: movie.posterUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (context, url) => Container(
                      color: AppColors.surfaceLight,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => _noImagePlaceholder(),
                  )
                : _noImagePlaceholder(),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              movie.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Fallback widget shown when the poster URL is empty or fails to load.
  Widget _noImagePlaceholder() {
    return Container(
      color: AppColors.surfaceLight,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.movie, color: AppColors.textTertiary, size: 32),
            const SizedBox(height: 4),
            Text(
              movie.title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textTertiary, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
