// lib/core/widgets/tv_show_card.dart
// VERSION 1 - Basic UI only. No CachedNetworkImage, no GoRouter.

import 'package:flutter/material.dart';
import 'package:movie_watchlist/shared/models/tv_show.dart';

/// Simple TV show card with poster, title, and rating.
/// TODO v2: Add CachedNetworkImage, GoRouter navigation
class TvShowCard extends StatelessWidget {
  final TvShow tvShow;
  const TvShowCard({super.key, required this.tvShow});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO v2: Replace with context.push('/tv-details', extra: tvShow)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tapped: ${tvShow.name}')),
        );
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 170,
                width: 120,
                color: const Color(0xFF1E1E1E),
                child: const Center(
                  child: Icon(Icons.tv, color: Colors.grey, size: 40),
                ),
              ),
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
}
