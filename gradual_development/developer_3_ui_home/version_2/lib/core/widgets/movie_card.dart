// lib/core/widgets/movie_card.dart
// VERSION 2 - Adds CachedNetworkImage and GoRouter navigation. No Hero animation yet.

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_watchlist/shared/models/movie.dart';

/// Movie card with network image loading and navigation.
/// TODO v3: Add Hero animation
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
            ClipRRect(
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
              movie.title,
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
                  movie.voteAverage.toStringAsFixed(1),
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
                if (movie.releaseDate.length >= 4) ...[
                  const SizedBox(width: 6),
                  Text(
                    movie.releaseDate.substring(0, 4),
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
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
      color: const Color(0xFF1E1E1E),
      child: const Center(
        child: Icon(Icons.movie, color: Colors.grey, size: 40),
      ),
    );
  }
}
