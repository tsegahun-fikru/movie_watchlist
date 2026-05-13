// lib/features/watchlist/presentation/screens/watchlist_screen.dart
// Watchlist screen showing the user's saved movies and TV shows in a grid.
// Supports sorting (date added, title, rating) and filtering (all, movies, TV).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_watchlist/core/theme/app_colors.dart';
import 'package:movie_watchlist/features/watchlist/presentation/providers/watchlist_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_watchlist/features/watchlist/presentation/widgets/watchlist_card.dart';
import 'package:movie_watchlist/core/widgets/tv_show_card.dart';
import 'package:movie_watchlist/features/watchlist/data/models/watchlist_item.dart';
import 'package:movie_watchlist/shared/models/movie.dart';
import 'package:movie_watchlist/shared/models/tv_show.dart';

// ─── Sort & Filter enums ──────────────────────────────────────────────────────

/// Available sort orders for the watchlist grid.
enum WatchlistSort { dateAdded, titleAZ, ratingHighLow }

/// Available content-type filters for the watchlist grid.
enum WatchlistFilter { all, moviesOnly, tvOnly }

// ─── Providers ────────────────────────────────────────────────────────────────

/// Persists the active sort order for the watchlist grid.
final watchlistSortProvider =
    StateProvider<WatchlistSort>((ref) => WatchlistSort.dateAdded);

/// Persists the active content-type filter for the watchlist grid.
final watchlistFilterProvider =
    StateProvider<WatchlistFilter>((ref) => WatchlistFilter.all);

// ─── Screen ───────────────────────────────────────────────────────────────────

/// Displays the user's watchlist in a 2-column grid with sort and filter controls.
class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlistAsync = ref.watch(watchlistStreamProvider);
    final sort = ref.watch(watchlistSortProvider);
    final filter = ref.watch(watchlistFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Watchlist'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort & Filter',
            onPressed: () => _showSortFilterSheet(context, ref, sort, filter),
          ),
        ],
      ),
      body: watchlistAsync.when(
        data: (items) {
          // Apply filter
          List<WatchlistItem> filtered;
          switch (filter) {
            case WatchlistFilter.moviesOnly:
              filtered = items.where((i) => i.type == 'movie').toList();
              break;
            case WatchlistFilter.tvOnly:
              filtered = items.where((i) => i.type == 'tv').toList();
              break;
            case WatchlistFilter.all:
              filtered = List.from(items);
              break;
          }

          // Apply sort
          switch (sort) {
            case WatchlistSort.titleAZ:
              filtered.sort((a, b) => a.title.compareTo(b.title));
              break;
            case WatchlistSort.ratingHighLow:
              filtered.sort((a, b) {
                final ratingA =
                    (a.data['vote_average'] as num?)?.toDouble() ?? 0.0;
                final ratingB =
                    (b.data['vote_average'] as num?)?.toDouble() ?? 0.0;
                return ratingB.compareTo(ratingA);
              });
              break;
            case WatchlistSort.dateAdded:
              // Firestore returns in insertion order; keep as-is
              break;
          }

          if (filtered.isEmpty) return const _EmptyState();

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async => ref.invalidate(watchlistStreamProvider),
              child: GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final watchItem = filtered[i];
                  final original = watchItem.toOriginal();

                  Widget card;
                  if (original is Movie) {
                    card = WatchlistCard(movie: original);
                  } else if (original is TvShow) {
                    card = TvShowCard(tvShow: original);
                  } else {
                    return const SizedBox.shrink();
                  }

                  return GestureDetector(
                    onTap: () => context.push('/details', extra: original),
                    child: card,
                  );
                },
              ),
            ),
          );
        },
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (error, _) => Center(
          child: Text('Error: $error',
              style: const TextStyle(color: AppColors.error)),
        ),
      ),
    );
  }

  void _showSortFilterSheet(
    BuildContext context,
    WidgetRef ref,
    WatchlistSort currentSort,
    WatchlistFilter currentFilter,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _SortFilterSheet(
        currentSort: currentSort,
        currentFilter: currentFilter,
        onSortChanged: (s) =>
            ref.read(watchlistSortProvider.notifier).state = s,
        onFilterChanged: (f) =>
            ref.read(watchlistFilterProvider.notifier).state = f,
      ),
    );
  }
}

// ─── Sort/Filter bottom sheet ─────────────────────────────────────────────────

class _SortFilterSheet extends StatefulWidget {
  final WatchlistSort currentSort;
  final WatchlistFilter currentFilter;
  final ValueChanged<WatchlistSort> onSortChanged;
  final ValueChanged<WatchlistFilter> onFilterChanged;

  const _SortFilterSheet({
    required this.currentSort,
    required this.currentFilter,
    required this.onSortChanged,
    required this.onFilterChanged,
  });

  @override
  State<_SortFilterSheet> createState() => _SortFilterSheetState();
}

class _SortFilterSheetState extends State<_SortFilterSheet> {
  late WatchlistSort _sort;
  late WatchlistFilter _filter;

  @override
  void initState() {
    super.initState();
    _sort = widget.currentSort;
    _filter = widget.currentFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Sort section
          const Text(
            'Sort by',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _SortOption(
            label: 'Date Added',
            selected: _sort == WatchlistSort.dateAdded,
            onTap: () => setState(() => _sort = WatchlistSort.dateAdded),
          ),
          _SortOption(
            label: 'Title A–Z',
            selected: _sort == WatchlistSort.titleAZ,
            onTap: () => setState(() => _sort = WatchlistSort.titleAZ),
          ),
          _SortOption(
            label: 'Rating: High to Low',
            selected: _sort == WatchlistSort.ratingHighLow,
            onTap: () => setState(() => _sort = WatchlistSort.ratingHighLow),
          ),

          const SizedBox(height: 16),
          const Divider(color: Colors.white10),
          const SizedBox(height: 8),

          // Filter section
          const Text(
            'Filter',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _SortOption(
            label: 'All',
            selected: _filter == WatchlistFilter.all,
            onTap: () => setState(() => _filter = WatchlistFilter.all),
          ),
          _SortOption(
            label: 'Movies only',
            selected: _filter == WatchlistFilter.moviesOnly,
            onTap: () => setState(() => _filter = WatchlistFilter.moviesOnly),
          ),
          _SortOption(
            label: 'TV shows only',
            selected: _filter == WatchlistFilter.tvOnly,
            onTap: () => setState(() => _filter = WatchlistFilter.tvOnly),
          ),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onSortChanged(_sort);
                widget.onFilterChanged(_filter);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Apply',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SortOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: TextStyle(
          color: selected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: selected
          ? const Icon(Icons.check_circle, color: AppColors.primary, size: 20)
          : const Icon(Icons.circle_outlined,
              color: AppColors.textTertiary, size: 20),
      onTap: onTap,
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

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
              Icons.bookmark_border_rounded,
              size: 80,
              color: AppColors.textTertiary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            const Text(
              'Nothing saved yet',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap the bookmark icon on any movie or TV show to save it here.',
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
