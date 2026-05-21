// lib/features/movies/presentation/screens/genre_browse_screen.dart
// Screen that shows a paginated grid of movies for a specific TMDB genre.
// Uses a self-contained StateNotifier to manage loading state.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_watchlist/app/router/media_routes.dart';
import 'package:movie_watchlist/core/theme/app_colors.dart';
import 'package:movie_watchlist/features/movies/presentation/providers/movie_providers.dart';
import 'package:movie_watchlist/features/movies/data/repositories/legacy_tmdb_repository.dart';
import 'package:movie_watchlist/shared/models/movie.dart';

// ─── State ────────────────────────────────────────────────────────────────────

class _GenreBrowseState {
  final List<Movie> movies;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final String? error;

  const _GenreBrowseState({
    this.movies = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 0,
    this.error,
  });

  _GenreBrowseState copyWith({
    List<Movie>? movies,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    String? error,
  }) {
    return _GenreBrowseState(
      movies: movies ?? this.movies,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      error: error,
    );
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

/// Manages loading state for the genre browse grid.
/// Fetches the first page on construction and supports pull-to-refresh.
class _GenreBrowseNotifier extends StateNotifier<_GenreBrowseState> {
  final int genreId;
  final LegacyTmdbRepository _repo;

  _GenreBrowseNotifier({
    required this.genreId,
    required LegacyTmdbRepository repo,
  }) : _repo = repo,
       super(const _GenreBrowseState()) {
    loadFirstPage();
  }

  Future<void> loadFirstPage() async {
    state = state.copyWith(
      isLoading: true,
      movies: [],
      currentPage: 0,
      hasMore: true,
    );
    try {
      final movies = await _repo.discoverMovies(genreIds: [genreId]);
      state = state.copyWith(
        movies: movies,
        isLoading: false,
        currentPage: 1,
        hasMore: movies.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadNextPage() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      // TMDB discover doesn't support pagination in the legacy repo, stop after first page
      state = state.copyWith(isLoadingMore: false, hasMore: false);
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }
}

// ─── Screen ───────────────────────────────────────────────────────────────────

/// Displays a 2-column grid of movies for the given [genreId].
///
/// The [StateNotifierProvider] is created inline so each screen instance
/// gets its own independent notifier scoped to the genre.
class GenreBrowseScreen extends ConsumerStatefulWidget {
  final int genreId;
  final String genreName;

  const GenreBrowseScreen({
    super.key,
    required this.genreId,
    required this.genreName,
  });

  @override
  ConsumerState<GenreBrowseScreen> createState() => _GenreBrowseScreenState();
}

class _GenreBrowseScreenState extends ConsumerState<GenreBrowseScreen> {
  late final ScrollController _scrollController;
  late final StateNotifierProvider<_GenreBrowseNotifier, _GenreBrowseState>
  _provider;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _provider = StateNotifierProvider<_GenreBrowseNotifier, _GenreBrowseState>(
      (ref) => _GenreBrowseNotifier(
        genreId: widget.genreId,
        repo: ref.read(legacyTmdbRepositoryProvider),
      ),
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    if (_scrollController.offset >= max * 0.85) {
      ref.read(_provider.notifier).loadNextPage();
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(_provider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(widget.genreName),
        elevation: 0,
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(_GenreBrowseState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state.error != null && state.movies.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 12),
            Text(
              'Failed to load movies',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => ref.read(_provider.notifier).loadFirstPage(),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      );
    }

    if (state.movies.isEmpty) {
      return const Center(
        child: Text(
          'No movies found for this genre.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => ref.read(_provider.notifier).loadFirstPage(),
      child: GridView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.62,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: state.movies.length + (state.isLoadingMore ? 2 : 0),
        itemBuilder: (_, i) {
          if (i >= state.movies.length) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }
          final movie = state.movies[i];
          return _GenreMovieCard(movie: movie);
        },
      ),
    );
  }
}

class _GenreMovieCard extends StatelessWidget {
  final Movie movie;
  const _GenreMovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(mediaDetailsPath(movie)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: movie.posterUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: movie.posterUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (_, __) =>
                          Container(color: AppColors.surfaceLight),
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.surface,
                        child: const Icon(
                          Icons.movie,
                          color: AppColors.textTertiary,
                          size: 40,
                        ),
                      ),
                    )
                  : Container(
                      color: AppColors.surface,
                      child: const Icon(
                        Icons.movie,
                        color: AppColors.textTertiary,
                        size: 40,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            movie.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: AppColors.star, size: 12),
              const SizedBox(width: 3),
              Text(
                movie.voteAverage.toStringAsFixed(1),
                style: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
