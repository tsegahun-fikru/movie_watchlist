// lib/core/widgets/media_card.dart
// Compact poster card for any Movie/TvShow model implementing MediaItem.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_watchlist/app/router/media_routes.dart';
import 'package:movie_watchlist/core/domain/entities/media_item.dart';
import 'package:movie_watchlist/core/theme/app_colors.dart';

class MediaCard extends StatelessWidget {
  const MediaCard({super.key, required this.item});

  final MediaItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(mediaDetailsPath(item)),
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: '${item.type}-${item.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: item.posterUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: item.posterUrl,
                        height: 170,
                        width: 120,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Container(
                          height: 170,
                          width: 120,
                          color: AppColors.surfaceLight,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (_, _, _) => _placeholder(),
                        fadeInDuration: const Duration(milliseconds: 200),
                      )
                    : _placeholder(),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.star_rounded, color: AppColors.star, size: 12),
                const SizedBox(width: 3),
                Text(
                  item.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
                if (item.releaseDate.length >= 4) ...[
                  const SizedBox(width: 6),
                  Text(
                    item.releaseDate.substring(0, 4),
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      height: 170,
      width: 120,
      color: AppColors.surface,
      child: Center(
        child: Icon(
          item.type == 'tv' ? Icons.tv : Icons.movie,
          color: AppColors.textTertiary,
          size: 40,
        ),
      ),
    );
  }
}
