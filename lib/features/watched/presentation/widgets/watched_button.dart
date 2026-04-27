// lib/features/watched/presentation/widgets/watched_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_watchlist/core/theme/app_colors.dart';
import 'package:movie_watchlist/features/watched/presentation/providers/watched_providers.dart';
import 'package:movie_watchlist/features/notifications/data/services/notification_service.dart';
import 'package:movie_watchlist/shared/models/movie.dart';
import 'package:movie_watchlist/shared/models/tv_show.dart';

/// A reactive toggle button that marks a Movie or TvShow as watched/unwatched.
/// It watches the [watchedStreamProvider] to maintain a single source of truth.
class WatchedButton extends ConsumerWidget {
  final Object item; // can be Movie or TvShow
  const WatchedButton({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchedAsync = ref.watch(watchedStreamProvider);
    final service = ref.watch(watchedServiceProvider);

    if (service == null) return const SizedBox.shrink();

    // Determine if the current item is in the watched list
    final (id, type, _) = service.extract(item);
    final docId = '${type}_$id';
    final isWatched =
        watchedAsync.valueOrNull?.any((w) => w.docId == docId) ?? false;
    final isLoading = watchedAsync.isLoading;

    Future<void> toggleWatched() async {
      final title = (item is Movie) ? (item as Movie).title : (item as TvShow).name;

      try {
        if (isWatched) {
          await service.removeItem(item);
          NotificationService.addNotification(
            'Marked as Unwatched',
            '$title was removed from your watched list.',
          );
        } else {
          await service.addItem(item);
          NotificationService.addNotification(
            'Marked as Watched',
            '$title was added to your watched list.',
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              : Icon(
                  isWatched ? Icons.visibility : Icons.visibility_outlined,
                  color: isWatched ? AppColors.primary : AppColors.textSecondary,
                  size: 28,
                ),
          onPressed: isLoading ? null : toggleWatched,
          tooltip: isWatched ? 'Mark as unwwatched' : 'Mark as watched',
        ),
        Text(
          isWatched ? 'Watched' : 'Mark watched',
          style: TextStyle(
            fontSize: 11,
            color: isWatched ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
