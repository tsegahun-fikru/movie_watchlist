// lib/core/widgets/movie_card_skeleton.dart
import 'package:flutter/material.dart';
import 'package:movie_watchlist/core/theme/app_colors.dart';
import 'package:movie_watchlist/core/widgets/shimmer_loading.dart';

class MovieCardSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const MovieCardSkeleton({
    super.key,
    this.width = 100,
    this.height = 140,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster placeholder with shimmer
          ShimmerLoading(
            child: Container(
              height: height,
              width: width,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Title placeholder
          ShimmerLoading(
            child: Container(
              height: 12,
              width: width * 0.8,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
