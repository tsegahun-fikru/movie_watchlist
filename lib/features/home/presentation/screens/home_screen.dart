// lib/features/home/presentation/screens/home_screen.dart
// Main home screen showing a trending carousel, genre chips, watchlist row,
// personalised recommendations, and multiple horizontal media lists.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_watchlist/app/router/media_routes.dart';
import 'package:movie_watchlist/core/theme/app_colors.dart';
import 'package:movie_watchlist/features/movies/presentation/providers/movie_providers.dart';
import 'package:movie_watchlist/features/watchlist/presentation/providers/watchlist_providers.dart';
import 'package:movie_watchlist/core/widgets/custom_app_bar.dart';
import 'package:movie_watchlist/core/widgets/movie_card.dart';
import 'package:movie_watchlist/core/widgets/movie_card_skeleton.dart';
import 'package:movie_watchlist/core/widgets/shimmer_loading.dart';
import 'package:movie_watchlist/features/home/presentation/widgets/auto_carousel.dart';
import 'package:movie_watchlist/shared/models/movie.dart';
import 'package:movie_watchlist/shared/models/tv_show.dart';
import 'package:movie_watchlist/core/widgets/tv_show_card.dart';
import 'package:movie_watchlist/features/home/presentation/widgets/recommendations_row.dart';

/// The main home screen.
///
/// Uses [AutomaticKeepAliveClientMixin] so the scroll position and provider
/// state are preserved when the user switches tabs and returns.
/// Pull-to-refresh invalidates all home-screen providers simultaneously.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(trendingMoviesProvider);
          ref.invalidate(popularMoviesProvider);
          ref.invalidate(recentReleasesProvider);
          ref.invalidate(topRatedMoviesProvider);
          ref.invalidate(upcomingMoviesProvider);
          ref.invalidate(popularSeriesProvider);
          ref.invalidate(onTheAirSeriesProvider);
          ref.invalidate(topRatedSeriesProvider);
          ref.invalidate(watchlistStreamProvider);
          ref.invalidate(recommendationsProvider);
        },
        child: ListView(
          physics: const ClampingScrollPhysics(),
          children: [
            const _TrendingCarousel(),
            const SizedBox(height: 10),
            const _GenreChipsRow(),
            const SizedBox(height: 4),
            const _WatchlistRow(),

            // --- Recommendations based on watchlist ---
            const RecommendationsRow(),

            // --- Movies Sections ---
            _HorizontalMediaList<Movie>(
              provider: popularMoviesProvider,
              refreshProvider: popularMoviesProvider,
              title: 'Popular Movies',
              itemBuilder: (movie) => MovieCard(movie: movie),
            ),
            _HorizontalMediaList<Movie>(
              provider: recentReleasesProvider,
              refreshProvider: recentReleasesProvider,
              title: 'Recent Releases',
              itemBuilder: (movie) => MovieCard(movie: movie),
            ),
            _HorizontalMediaList<Movie>(
              provider: topRatedMoviesProvider,
              refreshProvider: topRatedMoviesProvider,
              title: 'Top Rated Movies',
              itemBuilder: (movie) => MovieCard(movie: movie),
            ),
            _HorizontalMediaList<Movie>(
              provider: upcomingMoviesProvider,
              refreshProvider: upcomingMoviesProvider,
              title: 'Upcoming Movies',
              itemBuilder: (movie) => MovieCard(movie: movie),
            ),

            // --- TV Series Sections ---
            _HorizontalMediaList<TvShow>(
              provider: popularSeriesProvider,
              refreshProvider: popularSeriesProvider,
              title: 'Popular Series',
              itemBuilder: (tv) => TvShowCard(tvShow: tv),
            ),
            _HorizontalMediaList<TvShow>(
              provider: onTheAirSeriesProvider,
              refreshProvider: onTheAirSeriesProvider,
              title: 'On The Air',
              itemBuilder: (tv) => TvShowCard(tvShow: tv),
            ),
            _HorizontalMediaList<TvShow>(
              provider: topRatedSeriesProvider,
              refreshProvider: topRatedSeriesProvider,
              title: 'Top Rated Series',
              itemBuilder: (tv) => TvShowCard(tvShow: tv),
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

/// Renders the trending movies as a full-width 16:9 [AutoCarousel].
/// Falls back to a shimmer skeleton while loading and shows a retry button on error.
class _TrendingCarousel extends ConsumerWidget {
  const _TrendingCarousel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendingAsync = ref.watch(trendingMoviesProvider);

    return trendingAsync.when(
      data: (movies) {
        if (movies.isEmpty) return const SizedBox.shrink();
        // AspectRatio 16:9 — backdrop fills full width, never overflows
        return AspectRatio(
          aspectRatio: 16 / 9,
          child: AutoCarousel(
            items: movies,
            itemBuilder: (ctx, movie) => _HeroItem(movie: movie as Movie),
          ),
        );
      },
      loading: () => const AspectRatio(
        aspectRatio: 16 / 9,
        child: Center(
          child: ShimmerLoading(
            child: MovieCardSkeleton(width: 200, height: 120),
          ),
        ),
      ),
      error: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Text(
              'Trending',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => ref.invalidate(trendingMoviesProvider),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single trending movie item rendered as a full-bleed backdrop with a
/// gradient overlay and title/rating metadata at the bottom.
class _HeroItem extends StatelessWidget {
  final Movie movie;
  const _HeroItem({required this.movie});

  @override
  Widget build(BuildContext context) {
    // Use backdrop (16:9 landscape) — fits the container perfectly
    final imageUrl = movie.backdropUrl.isNotEmpty
        ? movie.backdropUrl
        : movie.posterUrl;

    return GestureDetector(
      onTap: () => context.push(mediaDetailsPath(movie)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => Container(color: AppColors.surface),
          ),
          // Bottom gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.4, 1.0],
                colors: [
                  Colors.transparent,
                  AppColors.background.withValues(alpha: 0.92),
                ],
              ),
            ),
          ),
          // Title + meta
          Positioned(
            bottom: 12,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  movie.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    shadows: [Shadow(blurRadius: 6, color: Colors.black54)],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: AppColors.star,
                      size: 14,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      movie.voteAverage.toStringAsFixed(1),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    if (movie.releaseDate.length >= 4) ...[
                      const SizedBox(width: 10),
                      Text(
                        movie.releaseDate.substring(0, 4),
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Filters the watchlist to movies only and renders them in a horizontal row.
/// Hidden when the watchlist is empty.
class _WatchlistRow extends ConsumerWidget {
  const _WatchlistRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlistAsync = ref.watch(watchlistStreamProvider);
    final moviesAsync = watchlistAsync.when(
      data: (items) => AsyncValue.data(
        items
            .where((item) => item.type == 'movie')
            .map((item) => item.toOriginal() as Movie)
            .toList(),
      ),
      loading: () => const AsyncValue<List<Movie>>.loading(),
      error: (err, stack) => AsyncValue<List<Movie>>.error(err, stack),
    );

    return moviesAsync.when(
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        return _buildList(
          context,
          items,
          'My Watchlist',
          (movie) => MovieCard(movie: movie),
        );
      },
      loading: () => const _SkeletonRow(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

/// Generic horizontal media list that works for both [Movie] and [TvShow].
///
/// Shows a shimmer skeleton while loading, a retry button on error, and
/// hides itself when the list is empty.
class _HorizontalMediaList<T extends Object> extends ConsumerWidget {
  final ProviderListenable<AsyncValue<List<T>>> provider;
  final ProviderOrFamily? refreshProvider;
  final String title;
  final Widget Function(T item) itemBuilder;

  const _HorizontalMediaList({
    required this.provider,
    this.refreshProvider,
    required this.title,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncItems = ref.watch(provider);
    return asyncItems.when(
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        return _buildList(context, items, title, itemBuilder);
      },
      loading: () => const _SkeletonRow(),
      error: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                if (refreshProvider != null) {
                  ref.invalidate(refreshProvider!);
                }
              },
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildList<T extends Object>(
  BuildContext context,
  List<T> items,
  String title,
  Widget Function(T) itemBuilder,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      SizedBox(
        height: 220, // 170px poster + title + rating row
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: items.length,
          itemBuilder: (_, i) => GestureDetector(
            onTap: () => context.push(mediaDetailsPathForObject(items[i])),
            child: itemBuilder(items[i]),
          ),
        ),
      ),
    ],
  );
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: 5,
            itemBuilder: (_, __) =>
                const ShimmerLoading(child: MovieCardSkeleton()),
          ),
        ),
      ],
    );
  }
}

// ─── Genre chips row ──────────────────────────────────────────────────────────

/// Horizontally scrollable row of genre [ActionChip]s.
/// Tapping a chip navigates to [GenreBrowseScreen] for that genre.
class _GenreChipsRow extends ConsumerWidget {
  const _GenreChipsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final genreAsync = ref.watch(genreMapProvider);

    return genreAsync.when(
      data: (genreMap) {
        if (genreMap.isEmpty) return const SizedBox.shrink();
        final entries = genreMap.entries.toList();
        return SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: entries.length,
            itemBuilder: (_, i) {
              final entry = entries[i];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  label: Text(
                    entry.value,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                    ),
                  ),
                  backgroundColor: AppColors.surface,
                  side: const BorderSide(color: Colors.white12),
                  onPressed: () => context.push(
                    '/genre-browse',
                    extra: {'genreId': entry.key, 'genreName': entry.value},
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
