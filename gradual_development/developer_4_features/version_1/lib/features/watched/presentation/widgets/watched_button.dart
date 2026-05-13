// lib/features/watched/presentation/widgets/watched_button.dart
// VERSION 1 - Simple watched button widget.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_watchlist/features/watched/presentation/providers/watched_providers.dart';

/// Button to mark/unmark an item as watched.
/// TODO v2: Add user rating functionality
class WatchedButton extends ConsumerWidget {
  final dynamic item; // Movie or TvShow

  const WatchedButton({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(watchedServiceProvider);
    final isWatched = service.isWatched(item);

    return IconButton(
      icon: Icon(
        isWatched ? Icons.check_circle : Icons.check_circle_outline,
        color: isWatched ? Colors.red : Colors.grey,
      ),
      onPressed: () {
        if (isWatched) {
          service.removeItem(item);
        } else {
          service.addItem(item);
        }
        // Trigger rebuild
        ref.read(watchedChangeNotifierProvider.notifier).state++;
      },
      tooltip: isWatched ? 'Mark as unwatched' : 'Mark as watched',
    );
  }
}
