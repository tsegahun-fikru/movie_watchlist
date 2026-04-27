import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_watchlist/core/theme/app_colors.dart';
import 'package:movie_watchlist/shared/models/tv_show.dart';

class TvShowCard extends StatelessWidget {
  final TvShow tvShow;

  const TvShowCard({super.key, required this.tvShow});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/details', extra: tvShow),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: tvShow.fullPosterUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: tvShow.fullPosterUrl,
                      height: 180,
                      width: 140,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            const SizedBox(height: 6),
            Text(
              tvShow.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            ),
            const SizedBox(height: 2),
            Text(
              tvShow.firstAirDate.isNotEmpty ? '📅 ${tvShow.firstAirDate}' : '',
              style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
            ),
            Text(
              '⭐ ${tvShow.voteAverage.toStringAsFixed(1)}',
              style: const TextStyle(color: AppColors.star, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    height: 180,
    width: 140,
    color: AppColors.surface,
    child: const Center(child: Icon(Icons.tv, color: AppColors.textTertiary, size: 40)),
  );
}
