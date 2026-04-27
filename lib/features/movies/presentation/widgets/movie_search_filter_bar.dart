import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_watchlist/core/di/clean_arch_providers.dart';

class MovieSearchFilterBar extends ConsumerWidget {
  const MovieSearchFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(
      movieSearchNotifierProvider.select((state) => state.filters),
    );
    final currentYear = DateTime.now().year;
    final years = List<int>.generate(21, (index) => currentYear - index);
    const ratings = <double>[9, 8, 7, 6, 5];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
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
        SizedBox(
          height: 46,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: ratings.length + 1,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
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
