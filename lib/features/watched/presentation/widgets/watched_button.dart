// lib/features/watched/presentation/widgets/watched_button.dart
// Reactive toggle button that marks a Movie or TvShow as watched/unwatched.
// Derives its state from the live [watchedStreamProvider] stream.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_watchlist/core/theme/app_colors.dart';
import 'package:movie_watchlist/features/notifications/presentation/providers/notification_providers.dart';
import 'package:movie_watchlist/features/watched/presentation/providers/watched_providers.dart';
import 'package:movie_watchlist/shared/models/movie.dart';
import 'package:movie_watchlist/shared/models/tv_show.dart';

/// A reactive toggle button that marks a Movie or TvShow as watched/unwatched.
///
/// Watches [watchedStreamProvider] to maintain a single source of truth —
/// the button state is always consistent with Firestore.
/// A local notification is fired after each successful toggle.
class WatchedButton extends ConsumerWidget {
  final Object item; // can be Movie or TvShow
  const WatchedButton({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchedAsync = ref.watch(watchedStreamProvider);
    final service = ref.watch(watchedServiceProvider);

    // Don't render if the user is not signed in
    if (service == null) return const SizedBox.shrink();

    // Derive the document ID to check against the stream
    final (id, type, _) = service.extract(item);
    final docId = '${type}_$id';
    final isWatched =
        watchedAsync.valueOrNull?.any((w) => w.docId == docId) ?? false;
    final isLoading = watchedAsync.isLoading;

    Future<void> toggleWatched() async {
      final title = (item is Movie)
          ? (item as Movie).title
          : (item as TvShow).name;

      try {
        if (isWatched) {
          await service.removeItem(item);
          ref
              .read(notificationNotifierProvider.notifier)
              .addNotification(
                'Marked as Unwatched',
                '$title was removed from your watched list.',
              );
        } else {
          await service.addItem(item);
          ref
              .read(notificationNotifierProvider.notifier)
              .addNotification(
                'Marked as Watched',
                '$title was added to your watched list.',
              );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
                  color: isWatched
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  size: 28,
                ),
          onPressed: isLoading ? null : toggleWatched,
          tooltip: isWatched ? 'Mark as unwatched' : 'Mark as watched',
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
