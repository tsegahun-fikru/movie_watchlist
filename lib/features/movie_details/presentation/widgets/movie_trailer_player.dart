// lib/features/movie_details/presentation/widgets/movie_trailer_player.dart
// Embedded YouTube trailer player used on the detail screen.

import 'package:flutter/material.dart';
import 'package:movie_watchlist/core/theme/app_colors.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// Renders a YouTube player in a 16:9 aspect ratio with an optional close button.
///
/// [controller] must be pre-initialised by the parent with the trailer's
/// video ID. [thumbnailUrl] is shown as a placeholder before the video loads.
class MovieTrailerPlayer extends StatelessWidget {
  const MovieTrailerPlayer({
    super.key,
    required this.controller,
    this.onClose,
    this.thumbnailUrl,
  });

  final YoutubePlayerController controller;

  /// Called when the user taps the close (×) button. If null, no button is shown.
  final VoidCallback? onClose;

  /// URL of the backdrop image used as the video thumbnail before playback.
  final String? thumbnailUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          // AspectRatio 16:9 ensures the player fills width without cropping
          AspectRatio(
            aspectRatio: 16 / 9,
            child: YoutubePlayer(
              controller: controller,
              showVideoProgressIndicator: true,
              progressIndicatorColor: AppColors.primary,
              progressColors: const ProgressBarColors(
                playedColor: AppColors.primary,
                handleColor: AppColors.primary,
              ),
              thumbnail: thumbnailUrl != null && thumbnailUrl!.isNotEmpty
                  ? Image.network(
                      thumbnailUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.background,
                        child: const Center(
                          child: Icon(Icons.play_circle_outline,
                              color: AppColors.primary, size: 64),
                        ),
                      ),
                    )
                  : Container(
                      color: AppColors.background,
                      child: const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary),
                      ),
                    ),
            ),
          ),
          // Close button overlaid in the top-right corner
          if (onClose != null)
            Positioned(
              top: 8,
              right: 8,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
                  tooltip: 'Close trailer',
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
