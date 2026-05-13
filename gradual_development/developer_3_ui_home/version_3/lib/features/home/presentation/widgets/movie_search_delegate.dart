// lib/features/home/presentation/widgets/movie_search_delegate.dart
// Full-screen search screen supporting both movie and TV show search with
// filters, infinite scroll, and search history.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movie_watchlist/core/theme/app_colors.dart';
import 'package:movie_watchlist/core/di/clean_arch_providers.dart';
import 'package:movie_watchlist/features/movies/presentation/widgets/movie_search_filter_bar.dart';
import 'package:movie_watchlist/features/movies/presentation/widgets/tv_search_filter_bar.dart';
import 'package:movie_watchlist/features/movies/presentation/widgets/movie_search_result_list.dart';
import 'package:movie_watchlist/features/home/presentation/widgets/search_history_widget.dart';
import 'package:movie_watchlist/shared/models/tv_show.dart';

enum _SearchTab { movies, tv }

/// Tracks which search tab (Movies or TV) is currently active.
final _searchTabProvider = StateProvider<_SearchTab>(
  (_) => _SearchTab.movies,
);

// ─── Screen ───────────────────────────────────────────────────────────────────

/// Full-screen search UI with a Movies / TV toggle, filter sheet, infinite
/// scroll, and search history shown when the query is empty.
class MovieSearchScreen extends ConsumerStatefulWidget {
  const MovieSearchScreen({super.key});

  @override
  ConsumerState<MovieSearchScreen> createState() => _MovieSearchScreenState();
}

class _MovieSearchScreenState extends ConsumerState<MovieSearchScreen> {
  late final TextEditingController _controller;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _scrollController = ScrollController()..addListener(_handleScroll);
  }

  /// Triggers pagination when the user scrolls to 80% of the list height.
  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    if (currentScroll >= maxScroll * 0.8) {
      final tab = ref.read(_searchTabProvider);
      if (tab == _SearchTab.movies) {
        ref.read(movieSearchNotifierProvider.notifier).loadNextPage();
      } else {
        ref.read(tvSearchNotifierProvider.notifier).loadNextPage();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    final tab = ref.read(_searchTabProvider);
    if (tab == _SearchTab.movies) {
      ref.read(movieSearchNotifierProvider.notifier).setQuery(value);
    } else {
      ref.read(tvSearchNotifierProvider.notifier).setQuery(value);
    }
  }

  /// Saves the query to history and triggers a search.
  void _onQuerySubmitted(String value) {
    if (value.trim().isNotEmpty) {
      SearchHistoryService.add(value.trim());
    }
    _onQueryChanged(value);
  }

  void _selectHistoryQuery(String query) {
    _controller.value = _controller.value.copyWith(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
    _onQuerySubmitted(query);
  }

  void _clearQuery() {
    _controller.clear();
    final tab = ref.read(_searchTabProvider);
    if (tab == _SearchTab.movies) {
      ref.read(movieSearchNotifierProvider.notifier).setQuery('');
    } else {
      ref.read(tvSearchNotifierProvider.notifier).setQuery('');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tab = ref.watch(_searchTabProvider);

    // Keep controller in sync with active notifier query
    final movieQuery = ref.watch(
      movieSearchNotifierProvider.select((s) => s.query),
    );
    final tvQuery = ref.watch(
      tvSearchNotifierProvider.select((s) => s.query),
    );
    final activeQuery = tab == _SearchTab.movies ? movieQuery : tvQuery;

    if (_controller.text != activeQuery) {
      _controller.value = _controller.value.copyWith(
        text: activeQuery,
        selection: TextSelection.collapsed(offset: activeQuery.length),
        composing: TextRange.empty,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: TextField(
            controller: _controller,
            autofocus: false,
            onChanged: _onQueryChanged,
            onSubmitted: _onQuerySubmitted,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: tab == _SearchTab.movies
                  ? 'Search movies…'
                  : 'Search TV shows…',
              hintStyle: const TextStyle(color: AppColors.textTertiary),
              filled: true,
              fillColor: AppColors.surface,
              prefixIcon:
                  const Icon(Icons.search, color: AppColors.textSecondary),
              suffixIcon: activeQuery.isEmpty
                  ? null
                  : IconButton(
                      onPressed: _clearQuery,
                      icon: const Icon(Icons.close,
                          color: AppColors.textSecondary),
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        actions: [
          // Filter button — both tabs
          Consumer(
            builder: (context, ref, _) {
              final isMovies = tab == _SearchTab.movies;
              final hasFilters = isMovies
                  ? !ref.watch(movieSearchNotifierProvider
                      .select((s) => s.filters.isEmpty))
                  : !ref.watch(
                      tvSearchNotifierProvider.select((s) => s.filters.isEmpty));
              return IconButton(
                icon: Badge(
                  isLabelVisible: hasFilters,
                  smallSize: 8,
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.tune),
                ),
                tooltip: 'Filters',
                onPressed: () => _showFilterSheet(context, tab),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Column(
          children: [
            // ── Movies / TV toggle ──
            _SearchToggle(
              current: tab,
              onChanged: (t) {
                ref.read(_searchTabProvider.notifier).state = t;
                if (_scrollController.hasClients) {
                  _scrollController.jumpTo(0);
                }
              },
            ),
            const SizedBox(height: 8),

            // ── Results ──
            Expanded(
              child: tab == _SearchTab.movies
                  ? (movieQuery.isEmpty
                      ? SearchHistoryWidget(
                          onQuerySelected: _selectHistoryQuery,
                        )
                      : MovieSearchResultList(
                          scrollController: _scrollController))
                  : (tvQuery.isEmpty
                      ? SearchHistoryWidget(
                          onQuerySelected: _selectHistoryQuery,
                        )
                      : _TvSearchResultList(
                          scrollController: _scrollController)),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, _SearchTab tab) {
    final isMovies = tab == _SearchTab.movies;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Row(
                  children: [
                    Text(
                      isMovies ? 'Filter Movies' : 'Filter TV Shows',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Consumer(
                      builder: (context, ref, _) => TextButton(
                        onPressed: () {
                          if (isMovies) {
                            ref
                                .read(movieSearchNotifierProvider.notifier)
                                .clearFilters();
                          } else {
                            ref
                                .read(tvSearchNotifierProvider.notifier)
                                .clearFilters();
                          }
                          Navigator.of(context).pop();
                        },
                        child: const Text('Clear all',
                            style: TextStyle(color: AppColors.primary)),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Colors.white10),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: isMovies
                      ? const MovieSearchFilterBar()
                      : const TvSearchFilterBar(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Apply',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Toggle widget ────────────────────────────────────────────────────────────

class _SearchToggle extends StatelessWidget {
  final _SearchTab current;
  final ValueChanged<_SearchTab> onChanged;

  const _SearchToggle({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _ToggleOption(
            label: 'Movies',
            icon: Icons.movie_outlined,
            selected: current == _SearchTab.movies,
            onTap: () => onChanged(_SearchTab.movies),
          ),
          _ToggleOption(
            label: 'TV Shows',
            icon: Icons.tv_outlined,
            selected: current == _SearchTab.tv,
            onTap: () => onChanged(_SearchTab.tv),
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected
                    ? Colors.white
                    : AppColors.textTertiary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      selected ? FontWeight.bold : FontWeight.normal,
                  color: selected
                      ? Colors.white
                      : AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── TV results list ──────────────────────────────────────────────────────────

class _TvSearchResultList extends ConsumerWidget {
  final ScrollController scrollController;
  const _TvSearchResultList({required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tvSearchNotifierProvider);

    if (state.isLoading && state.results.isEmpty) {
      return ListView.separated(
        controller: scrollController,
        itemCount: 8,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => _TvSkeletonTile(),
      );
    }

    if (state.error != null && state.results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            state.error!,
            style: const TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (state.results.isEmpty) {
      return const Center(
        child: Text(
          'No TV shows found.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      controller: scrollController,
      itemCount: state.results.length + (state.isLoadingMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        if (i >= state.results.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return _TvSearchTile(show: state.results[i]);
      },
    );
  }
}

class _TvSearchTile extends StatelessWidget {
  final TvShow show;
  const _TvSearchTile({required this.show});

  @override
  Widget build(BuildContext context) {
    final year = show.firstAirDate.length >= 4
        ? show.firstAirDate.substring(0, 4)
        : 'TBA';

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.push('/details', extra: show),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 92,
                height: 132,
                child: show.fullPosterUrl.isEmpty
                    ? Container(
                        color: AppColors.surfaceLight,
                        child: const Icon(Icons.tv,
                            color: AppColors.textTertiary),
                      )
                    : CachedNetworkImage(
                        imageUrl: show.fullPosterUrl,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TV badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'TV',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    show.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$year • ★ ${show.voteAverage.toStringAsFixed(1)}',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    show.overview.isEmpty
                        ? 'No overview available.'
                        : show.overview,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      height: 1.4,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TvSkeletonTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 156,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
