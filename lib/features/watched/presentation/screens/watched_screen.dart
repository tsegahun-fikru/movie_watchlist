// lib/features/watched/presentation/screens/watched_screen.dart
// Watched history screen showing all content the user has marked as watched.
// Supports long-press to remove individual items and a bulk clear action.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movie_watchlist/app/router/media_routes.dart';
import 'package:movie_watchlist/core/theme/app_colors.dart';
import 'package:movie_watchlist/features/watched/presentation/providers/watched_providers.dart';
import 'package:movie_watchlist/features/watchlist/data/models/watchlist_item.dart';
import 'package:movie_watchlist/shared/models/movie.dart';
import 'package:movie_watchlist/shared/models/tv_show.dart';

/// Displays the user's watched history in a 2-column grid.
///
/// The app bar shows a "Clear all" button when the list is non-empty.
/// Long-pressing a card shows a confirmation dialog to remove that item.
class WatchedScreen extends ConsumerWidget {
  const WatchedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchedAsync = ref.watch(watchedStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Watched History'),
        actions: [
          watchedAsync.maybeWhen(
            data: (items) => items.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.delete_sweep_outlined),
                    tooltip: 'Clear all',
                    onPressed: () => _confirmClearAll(context, ref),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: watchedAsync.when(
        data: (items) {
          if (items.isEmpty) return const _EmptyState();
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => ref.invalidate(watchedStreamProvider),
            child: _WatchedGrid(items: items),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => Center(
          child: Text(
            'Error: $error',
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ),
    );
  }

  void _confirmClearAll(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Clear watched history?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'This will remove all items from your watched history.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final service = ref.read(watchedServiceProvider);
              final items = ref.read(watchedStreamProvider).valueOrNull ?? [];
              for (final item in items) {
                await service?.removeItem(item.toOriginal());
              }
            },
            child: const Text(
              'Clear all',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Grid ───────────────────────────────────────────────────────────────────

/// 2-column grid of watched items.
class _WatchedGrid extends StatelessWidget {
  final List<WatchlistItem> items;
  const _WatchedGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.62,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final watchItem = items[i];
          final original = watchItem.toOriginal();
          return _WatchedCard(
            item: watchItem,
            original: original,
            onTap: () => context.push(mediaDetailsPathForObject(original)),
          );
        },
      ),
    );
  }
}

// ─── Card ────────────────────────────────────────────────────────────────────

/// A single watched item card with a poster, type badge, watched checkmark,
/// and a long-press confirmation to remove the item.
class _WatchedCard extends ConsumerWidget {
  final WatchlistItem item;
  final Object original;
  final VoidCallback onTap;

  const _WatchedCard({
    required this.item,
    required this.original,
    required this.onTap,
  });

  String get _posterUrl {
    if (original is Movie) return (original as Movie).posterUrl;
    if (original is TvShow) return (original as TvShow).fullPosterUrl;
    return '';
  }

  String get _title {
    if (original is Movie) return (original as Movie).title;
    if (original is TvShow) return (original as TvShow).name;
    return '';
  }

  String get _typeLabel => item.type == 'tv' ? 'TV' : 'Movie';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.surface,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Poster
            Column(
              children: [
                Expanded(
                  child: _posterUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: _posterUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (_, __) => Container(
                            color: AppColors.surfaceLight,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (_, __, ___) => _placeholder(),
                        )
                      : _placeholder(),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                  child: Text(
                    _title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            // Type badge (Movie / TV)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _typeLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Watched checkmark badge
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
            ),

            // Long-press to remove
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  onLongPress: () => _confirmRemove(context, ref),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.surfaceLight,
      child: const Center(
        child: Icon(Icons.movie, color: AppColors.textTertiary, size: 32),
      ),
    );
  }

  void _confirmRemove(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Remove "$_title"?',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'This will remove it from your watched history.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(watchedServiceProvider)?.removeItem(original);
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty state ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.visibility_off_outlined,
              size: 72,
              color: AppColors.textTertiary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Nothing watched yet',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Mark movies and TV shows as watched from their detail page.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
