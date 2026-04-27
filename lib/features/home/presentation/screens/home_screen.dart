import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
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
          ref.invalidate(popularSeriesProvider);
          ref.invalidate(onTheAirSeriesProvider);
          ref.invalidate(watchlistStreamProvider);
        },
        child: ListView(
          physics: const ClampingScrollPhysics(),
          children: [
            const _TrendingCarousel(),
            const SizedBox(height: 10),
            const _WatchlistRow(),

            // --- Movies Sections ---
            _HorizontalMediaList<Movie>(
              provider: popularMoviesProvider,
              title: 'Popular Movies',
              itemBuilder: (movie) => MovieCard(movie: movie),
            ),
            _HorizontalMediaList<Movie>(
              provider: recentReleasesProvider,
              title: 'Recent Releases',
              itemBuilder: (movie) => MovieCard(movie: movie),
            ),
            _HorizontalMediaList<Movie>(
              provider: topRatedMoviesProvider,
              title: 'Top Rated Movies',
              itemBuilder: (movie) => MovieCard(movie: movie),
            ),

            // --- TV Series Sections ---
            _HorizontalMediaList<TvShow>(
              provider: popularSeriesProvider,
              title: 'Popular Series',
              itemBuilder: (tv) => TvShowCard(tvShow: tv),
            ),
            _HorizontalMediaList<TvShow>(
              provider: onTheAirSeriesProvider,
              title: 'On The Air',
              itemBuilder: (tv) => TvShowCard(tvShow: tv),
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

class _TrendingCarousel extends ConsumerWidget {
  const _TrendingCarousel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendingAsync = ref.watch(trendingMoviesProvider);
    return trendingAsync.when(
      data: (movies) {
        if (movies.isEmpty) return const SizedBox.shrink();
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.45,
          child: AutoCarousel(
            items: movies,
            itemBuilder: (ctx, movie) => _HeroItem(movie: movie as Movie),
          ),
        );
      },
      loading: () => SizedBox(
        height: MediaQuery.of(context).size.height * 0.45,
        child: const Center(
          child: ShimmerLoading(
            child: MovieCardSkeleton(width: 200, height: 300),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _HeroItem extends StatelessWidget {
  final Movie movie;
  const _HeroItem({required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/details', extra: movie),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: movie.posterUrl,
            fit: BoxFit.cover,
            errorWidget: (context, url, error) => Container(color: AppColors.surface),
          ),
          Container(color: AppColors.background.withOpacity(0.7)),
          Center(
            child: CachedNetworkImage(
              imageUrl: movie.posterUrl,
              fit: BoxFit.contain,
              errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 50, color: AppColors.textTertiary),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, AppColors.background.withOpacity(0.87)],
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Text(
              movie.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                shadows: [Shadow(blurRadius: 10, color: AppColors.background)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
        return _buildList(context, items, 'My Watchlist', (movie) => MovieCard(movie: movie));
      },
      loading: () => const _SkeletonRow(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _HorizontalMediaList<T> extends ConsumerWidget {
  final ProviderListenable<AsyncValue<List<T>>> provider;
  final String title;
  final Widget Function(T item) itemBuilder;

  const _HorizontalMediaList({
    required this.provider,
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
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

Widget _buildList<T>(BuildContext context, List<T> items, String title, Widget Function(T) itemBuilder) {
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
        height: 260,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: items.length,
          itemBuilder: (_, i) => GestureDetector(
            onTap: () => context.push('/details', extra: items[i]),
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
            itemBuilder: (_, __) => const ShimmerLoading(child: MovieCardSkeleton()),
          ),
        ),
      ],
    );
  }
}
