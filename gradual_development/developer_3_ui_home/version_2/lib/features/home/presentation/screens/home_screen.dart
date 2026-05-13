// lib/features/home/presentation/screens/home_screen.dart
// VERSION 2 - Real data with Riverpod providers. Basic error handling.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_watchlist/core/widgets/custom_app_bar.dart';
import 'package:movie_watchlist/core/widgets/movie_card.dart';
import 'package:movie_watchlist/core/widgets/tv_show_card.dart';
import 'package:movie_watchlist/core/widgets/shimmer_loading.dart';
import 'package:movie_watchlist/core/widgets/movie_card_skeleton.dart';
import 'package:movie_watchlist/features/movies/presentation/providers/movie_providers.dart';
import 'package:movie_watchlist/features/home/presentation/widgets/auto_carousel.dart';
import 'package:movie_watchlist/shared/models/movie.dart';
import 'package:movie_watchlist/shared/models/tv_show.dart';

/// Home screen with real API data using Riverpod providers.
/// TODO v3: Add pull-to-refresh, genre chips, watchlist row, recommendations
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const CustomAppBar(),
      body: ListView(
        children: [
          // Trending carousel
          const _TrendingCarousel(),
          const SizedBox(height: 16),

          // Movie sections
          _MovieSection(
            title: 'Popular Movies',
            provider: popularMoviesProvider,
          ),
          _MovieSection(
            title: 'Top Rated Movies',
            provider: topRatedMoviesProvider,
          ),
          _MovieSection(
            title: 'Upcoming Movies',
            provider: upcomingMoviesProvider,
          ),

          // TV sections
          _TvSection(
            title: 'Popular Series',
            provider: popularSeriesProvider,
          ),
          _TvSection(
            title: 'Top Rated Series',
            provider: topRatedSeriesProvider,
          ),

          const SizedBox(height: 50),
        ],
      ),
    );
  }
}

/// Trending movies carousel with loading and error states.
class _TrendingCarousel extends ConsumerWidget {
  const _TrendingCarousel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendingAsync = ref.watch(trendingMoviesProvider);

    return trendingAsync.when(
      data: (movies) {
        if (movies.isEmpty) return const SizedBox.shrink();
        return AspectRatio(
          aspectRatio: 16 / 9,
          child: AutoCarousel(
            items: movies,
            itemBuilder: (ctx, movie) => _CarouselItem(movie: movie as Movie),
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
      error: (error, _) => Container(
        height: 100,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'Failed to load trending movies',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ),
      ),
    );
  }
}

/// Single carousel item showing movie backdrop.
class _CarouselItem extends StatelessWidget {
  final Movie movie;
  const _CarouselItem({required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/details', extra: movie),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Placeholder for backdrop image
          Container(
            color: Colors.grey[900],
            child: const Center(
              child: Icon(Icons.movie, color: Colors.grey, size: 48),
            ),
          ),
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.4, 1.0],
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.9),
                ],
              ),
            ),
          ),
          // Title and rating
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
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 3),
                    Text(
                      movie.voteAverage.toStringAsFixed(1),
                      style: TextStyle(color: Colors.grey[300], fontSize: 12),
                    ),
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

/// Reusable movie section with loading and error states.
class _MovieSection extends ConsumerWidget {
  final String title;
  final ProviderListenable<AsyncValue<List<Movie>>> provider;

  const _MovieSection({
    required this.title,
    required this.provider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncMovies = ref.watch(provider);

    return asyncMovies.when(
      data: (movies) {
        if (movies.isEmpty) return const SizedBox.shrink();
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
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: movies.length,
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => context.push('/details', extra: movies[i]),
                  child: MovieCard(movie: movies[i]),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => _SkeletonSection(title: title),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          '$title: Failed to load',
          style: TextStyle(color: Colors.grey[400]),
        ),
      ),
    );
  }
}

/// Reusable TV section with loading and error states.
class _TvSection extends ConsumerWidget {
  final String title;
  final ProviderListenable<AsyncValue<List<TvShow>>> provider;

  const _TvSection({
    required this.title,
    required this.provider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncShows = ref.watch(provider);

    return asyncShows.when(
      data: (shows) {
        if (shows.isEmpty) return const SizedBox.shrink();
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
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: shows.length,
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => context.push('/details', extra: shows[i]),
                  child: TvShowCard(tvShow: shows[i]),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => _SkeletonSection(title: title),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          '$title: Failed to load',
          style: TextStyle(color: Colors.grey[400]),
        ),
      ),
    );
  }
}

/// Skeleton loading state for sections.
class _SkeletonSection extends StatelessWidget {
  final String title;
  const _SkeletonSection({required this.title});

  @override
  Widget build(BuildContext context) {
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
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: 5,
            itemBuilder: (_, __) => const ShimmerLoading(
              child: MovieCardSkeleton(),
            ),
          ),
        ),
      ],
    );
  }
}
