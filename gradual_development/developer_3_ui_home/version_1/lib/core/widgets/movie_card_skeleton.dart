// lib/core/widgets/movie_card_skeleton.dart
// VERSION 1 - Skeleton placeholder (same across all versions)

import 'package:flutter/material.dart';

/// Skeleton placeholder for movie cards while loading.
class MovieCardSkeleton extends StatelessWidget {
  final double width;
  final double height;

  const MovieCardSkeleton({
    super.key,
    this.width = 120,
    this.height = 170,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 12,
            width: width * 0.8,
            color: const Color(0xFF1E1E1E),
          ),
          const SizedBox(height: 4),
          Container(
            height: 10,
            width: width * 0.5,
            color: const Color(0xFF1E1E1E),
          ),
        ],
      ),
    );
  }
}
