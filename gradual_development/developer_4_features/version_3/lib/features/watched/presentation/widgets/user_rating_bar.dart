// lib/features/watched/presentation/widgets/user_rating_bar.dart
// Interactive 5-star rating bar shown on the detail screen for watched items.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_watchlist/core/theme/app_colors.dart';
import 'package:movie_watchlist/features/watched/presentation/providers/watched_providers.dart';

/// Interactive 5-star rating bar. Only shown when the item is already watched.
///
/// [docId] is the Firestore document ID, e.g. `"movie_123"` or `"tv_456"`.
/// Tapping a filled star again clears the rating (toggle behaviour).
class UserRatingBar extends ConsumerWidget {
  final Object item; // Movie or TvShow
  final String docId;

  const UserRatingBar({super.key, required this.item, required this.docId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only render when the item is in the watched list
    final isWatched =
        ref.watch(watchedStreamProvider).valueOrNull?.any((w) => w.docId == docId) ??
            false;

    if (!isWatched) return const SizedBox.shrink();

    final currentRating = ref.watch(userRatingProvider(docId));
    final service = ref.watch(watchedServiceProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Rating',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: List.generate(5, (index) {
            final starValue = index + 1;
            final filled = currentRating != null && starValue <= currentRating;
            return GestureDetector(
              onTap: () async {
                if (service == null) return;
                // Tapping the same star again clears the rating
                final newRating =
                    currentRating == starValue ? null : starValue;
                try {
                  if (newRating == null) {
                    await service.clearRating(item);
                  } else {
                    await service.setRating(item, newRating);
                  }
                } catch (_) {}
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  filled ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: filled ? AppColors.star : AppColors.textTertiary,
                  size: 32,
                ),
              ),
            );
          }),
        ),
        // Show a text label for the current rating
        if (currentRating != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _ratingLabel(currentRating),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  /// Returns a human-readable label for a 1–5 star rating.
  String _ratingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Terrible';
      case 2:
        return 'Bad';
      case 3:
        return 'OK';
      case 4:
        return 'Good';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }
}
