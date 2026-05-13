// lib/core/widgets/movie_card.dart
// VERSION 1 - Basic UI only. No CachedNetworkImage, no GoRouter, no Hero animation.

import 'package:flutter/material.dart';
import 'package:movie_watchlist/shared/models/movie.dart';

/// Simple movie card with poster, title, and rating.
/// TODO v2: Add CachedNetworkImage, GoRouter navigation, Hero animation
class MovieCard extends StatelessWidget {
  final Movie movie;
  const MovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO v2: Replace with context.push('/details', extra: movie)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tapped: ${movie.title}')),
        );
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Simple placeholder instead of network image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 170,
                width: 120,
                color: const Color(0xFF1E1E1E),
                child: const Center(
                  child: Icon(Icons.movie, color: Colors.grey, size: 40),
                ),
              ),
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
}
