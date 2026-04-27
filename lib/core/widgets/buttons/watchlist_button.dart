// lib/core/widgets/buttons/watchlist_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_watchlist/core/theme/app_colors.dart';
import 'package:movie_watchlist/features/watchlist/presentation/providers/watchlist_providers.dart';
import 'package:movie_watchlist/shared/models/movie.dart';
import 'package:movie_watchlist/shared/models/tv_show.dart';
import 'package:movie_watchlist/features/notifications/data/services/notification_service.dart';

class WatchlistButton extends ConsumerStatefulWidget {
  final Object item; // can be Movie or TvShow
  const WatchlistButton({super.key, required this.item});

  @override
  ConsumerState<WatchlistButton> createState() => _WatchlistButtonState();
}

class _WatchlistButtonState extends ConsumerState<WatchlistButton> {
  bool isSaved = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkWatchlist();
  }

  Future<void> _checkWatchlist() async {
    final service = ref.read(watchlistServiceProvider);
    if (service == null) return;
    final exists = await service.isInWatchlist(widget.item);
    if (mounted) setState(() => isSaved = exists);
  }

  Future<void> toggleWatchlist() async {
    final service = ref.read(watchlistServiceProvider);
    if (service == null) return;

    setState(() => isLoading = true);
    try {
      final item = widget.item;
      final title = (item is Movie) ? item.title : (item as TvShow).name;

      if (isSaved) {
        await service.removeItem(item);
        if (mounted) {
          NotificationService.addNotification(
            'Removed from Watchlist',
            '$title was removed from your watchlist.',
          );
        }
      } else {
        await service.addItem(item);
        if (mounted) {
          NotificationService.addNotification(
            'Added to Watchlist',
            '$title was saved to your watchlist.',
          );
        }
      }

      if (mounted) setState(() => isSaved = !isSaved);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
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
              isSaved ? Icons.favorite : Icons.favorite_border,
              color: AppColors.primary,
              size: 28,
            ),
      onPressed: isLoading ? null : toggleWatchlist,
      tooltip: isSaved ? 'Remove from watchlist' : 'Add to watchlist',
    );
  }
}
