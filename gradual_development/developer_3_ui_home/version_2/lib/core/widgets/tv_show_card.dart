// lib/core/widgets/tv_show_card.dart
// VERSION 2 - Adds CachedNetworkImage and GoRouter navigation.

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_watchlist/shared/models/tv_show.dart';

/// TV show card with network image loading and navigation.
/// TODO v3: Add Hero animation
class TvShowCard extends StatelessWidget {
  final TvShow tvShow;
  const TvShowCard({super.key, required this.tvShow});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/tv-details', extra: tvShow),
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: tvShow.fullPosterUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: tvShow.fullPosterUrl,
                      height: 170,
                      width: 120,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        height: 170,
                        width: 120,
                        color: const Color(0xFF1E1E1E),
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            const SizedBox(height: 6),
            Text(
              tvShow.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 12),
                const SizedBox(width: 3),
                Text(
                  tvShow.voteAverage.toStringAsFixed(1),
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
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
      color: const Color(0xFF1E1E1E),
      child: const Center(
        child: Icon(Icons.tv, color: Colors.grey, size: 40),
      ),
    );
  }
}
