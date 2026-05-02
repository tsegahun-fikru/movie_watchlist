// lib/features/movies/presentation/widgets/movie_search_filter_bar.dart
// Filter bar widget for the movie search screen. Renders horizontally
// scrollable chip rows for genre, release year, and minimum rating.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_watchlist/core/di/clean_arch_providers.dart';

/// Renders three rows of [FilterChip]s for genre, year, and minimum rating.
///
/// Each chip toggles the corresponding filter on [MovieSearchNotifier].
/// Tapping an already-selected chip deselects it (sets the filter to null).
class MovieSearchFilterBar extends ConsumerWidget {
  const MovieSearchFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(
      movieSearchNotifierProvider.select((state) => state.filters),
    );
    final currentYear = DateTime.now().year;
    // Show the last 21 years (current year down to current - 20)
    final years = List<int>.generate(21, (index) => currentYear - index);
    const ratings = <double>[9, 8, 7, 6, 5];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // ── Genre chips ──
        ref
            .watch(movieGenresProvider)
            .when(
              data: (genres) => SizedBox(
                height: 46,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: genres.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final genre = genres[index];
                    final isSelected = filters.genreId == genre.id;

                    return FilterChip(
                      label: Text(genre.name),
                      selected: isSelected,
                      onSelected: (_) {
                        // Toggle: deselect if already selected
                        ref
                            .read(movieSearchNotifierProvider.notifier)
                            .updateGenre(isSelected ? null : genre.id);
                      },
                    );
                  },
                ),
              ),
              loading: () => const SizedBox(
                height: 46,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stackTrace) => const SizedBox.shrink(),
            ),
        const SizedBox(height: 12),

        // ── Year chips ──
        SizedBox(
          height: 46,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: years.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final year = years[index];
              final isSelected = filters.year == year;

              return FilterChip(
                label: Text('$year'),
                selected: isSelected,
                onSelected: (_) {
                  ref
                      .read(movieSearchNotifierProvider.notifier)
                      .updateYear(isSelected ? null : year);
                },
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
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              // Last item is the "Clear filters" action chip
              if (index == ratings.length) {
                return ActionChip(
                  label: const Text('Clear filters'),
                  onPressed: () {
                    ref
                        .read(movieSearchNotifierProvider.notifier)
                        .clearFilters();
                  },
                );
              }

              final rating = ratings[index];
              final isSelected = filters.minimumRating == rating;

              return FilterChip(
                label: Text('$rating+'),
                selected: isSelected,
                onSelected: (_) {
                  ref
                      .read(movieSearchNotifierProvider.notifier)
                      .updateMinimumRating(isSelected ? null : rating);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
