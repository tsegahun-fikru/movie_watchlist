// lib/features/movies/presentation/widgets/tv_search_filter_bar.dart
// Filter bar widget for the TV show search screen. Mirrors [MovieSearchFilterBar]
// but targets [TvSearchNotifier] and uses TV genre data.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_watchlist/core/di/clean_arch_providers.dart';

/// Renders three rows of [FilterChip]s for TV genre, year, and minimum rating.
///
/// Each chip toggles the corresponding filter on [TvSearchNotifier].
class TvSearchFilterBar extends ConsumerWidget {
  const TvSearchFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(
      tvSearchNotifierProvider.select((s) => s.filters),
    );
    final currentYear = DateTime.now().year;
    final years = List<int>.generate(21, (i) => currentYear - i);
    const ratings = <double>[9, 8, 7, 6, 5];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Genre chips ──
        ref.watch(tvGenresProvider).when(
              data: (genreMap) => SizedBox(
                height: 46,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: genreMap.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final entry = genreMap.entries.elementAt(i);
                    final isSelected = filters.genreId == entry.key;
                    return FilterChip(
                      label: Text(entry.value),
                      selected: isSelected,
                      onSelected: (_) => ref
                          .read(tvSearchNotifierProvider.notifier)
                          .updateGenre(isSelected ? null : entry.key),
                    );
                  },
                ),
              ),
              loading: () => const SizedBox(
                  height: 46,
                  child: Center(child: CircularProgressIndicator())),
              error: (_, __) => const SizedBox.shrink(),
            ),
        const SizedBox(height: 12),

        // ── Year chips ──
        SizedBox(
          height: 46,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: years.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final year = years[i];
              final isSelected = filters.year == year;
              return FilterChip(
                label: Text('$year'),
                selected: isSelected,
                onSelected: (_) => ref
                    .read(tvSearchNotifierProvider.notifier)
                    .updateYear(isSelected ? null : year),
              );
            },
          ),
        ),
        const SizedBox(height: 12),

        // ── Minimum rating chips + clear button ──
        SizedBox(
          height: 46,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: ratings.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              // Last item is the "Clear filters" action chip
              if (i == ratings.length) {
                return ActionChip(
                  label: const Text('Clear filters'),
                  onPressed: () => ref
                      .read(tvSearchNotifierProvider.notifier)
                      .clearFilters(),
                );
              }
              final rating = ratings[i];
              final isSelected = filters.minimumRating == rating;
              return FilterChip(
                label: Text('$rating+'),
                selected: isSelected,
                onSelected: (_) => ref
                    .read(tvSearchNotifierProvider.notifier)
                    .updateMinimumRating(isSelected ? null : rating),
              );
            },
          ),
        ),
      ],
    );
  }
}
