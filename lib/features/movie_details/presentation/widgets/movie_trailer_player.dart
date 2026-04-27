import 'package:flutter/material.dart';
import 'package:movie_watchlist/core/theme/app_colors.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MovieTrailerPlayer extends StatelessWidget {
  const MovieTrailerPlayer({
    super.key,
    required this.controller,
    this.onClose,
    this.thumbnailUrl,
  });

  final YoutubePlayerController controller;
  final VoidCallback? onClose;
  final String? thumbnailUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          YoutubePlayer(
            controller: controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: AppColors.primary,
            progressColors: const ProgressBarColors(
              playedColor: AppColors.primary,
              handleColor: AppColors.primary,
            ),
            // Light implementation: Use the movie's backdrop or a placeholder 
            // while the YouTube stream buffers.
            thumbnail: thumbnailUrl != null && thumbnailUrl!.isNotEmpty
                ? Image.network(
                    thumbnailUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  )
                : Container(
                    color: AppColors.background,
                    child: const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  ),
          ),
          if (onClose != null)
            Positioned(
              top: 12,
              right: 12,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close, color: AppColors.textPrimary),
                  tooltip: 'Close trailer',
                ),
              ),
            ),
        ],
      ),
    );
  }
}
