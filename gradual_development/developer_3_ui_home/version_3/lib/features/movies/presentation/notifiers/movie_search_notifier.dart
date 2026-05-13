// lib/features/movies/presentation/notifiers/movie_search_notifier.dart
// StateNotifier that drives the movie search screen. Handles debounced query
// changes, filter updates, pagination, and the trending fallback.

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_watchlist/features/movies/domain/entities/movie.dart';
import 'package:movie_watchlist/features/movies/domain/entities/movie_filters.dart';
import 'package:movie_watchlist/features/movies/domain/entities/movie_page.dart';
import 'package:movie_watchlist/features/movies/domain/usecases/get_trending_movies_use_case.dart';
import 'package:movie_watchlist/features/movies/domain/usecases/search_movies_use_case.dart';
import 'package:movie_watchlist/features/movies/presentation/state/movie_search_state.dart';

/// Manages the movie search state including query, filters, and pagination.
///
/// When the query is empty and no filters are active, trending movies are
/// shown instead of search results. A 400 ms debounce prevents excessive
/// API calls while the user is typing.
class MovieSearchNotifier extends StateNotifier<MovieSearchState> {
  MovieSearchNotifier({
    required SearchMoviesUseCase searchMoviesUseCase,
    required GetTrendingMoviesUseCase getTrendingMoviesUseCase,
  }) : _searchMoviesUseCase = searchMoviesUseCase,
       _getTrendingMoviesUseCase = getTrendingMoviesUseCase,
       super(MovieSearchState.initial());

  final SearchMoviesUseCase _searchMoviesUseCase;
  final GetTrendingMoviesUseCase _getTrendingMoviesUseCase;

  Timer? _debounce;

  /// Monotonically increasing counter used to discard stale responses when
  /// a new request is issued before the previous one completes.
  int _requestSequence = 0;

  /// Loads the first page (trending or search results) on initial mount.
  Future<void> loadInitial() async {
    await _loadPage(reset: true);
  }

  /// Updates the search query and schedules a debounced refresh.
  void setQuery(String query) {
    state = state.copyWith(query: query);
    _scheduleRefresh();
  }

  /// Updates the genre filter and schedules a debounced refresh.
  void updateGenre(int? genreId) {
    state = state.copyWith(
      filters: state.filters.copyWith(
        genreId: genreId,
        clearGenre: genreId == null,
      ),
    );
    _scheduleRefresh();
  }

  /// Updates the release year filter and schedules a debounced refresh.
  void updateYear(int? year) {
    state = state.copyWith(
      filters: state.filters.copyWith(year: year, clearYear: year == null),
    );
    _scheduleRefresh();
  }

  /// Updates the minimum rating filter and schedules a debounced refresh.
  void updateMinimumRating(double? minimumRating) {
    state = state.copyWith(
      filters: state.filters.copyWith(
        minimumRating: minimumRating,
        clearRating: minimumRating == null,
      ),
    );
    _scheduleRefresh();
  }

  /// Appends the next page of results. No-ops if already loading or no more pages.
  Future<void> loadNextPage() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) {
      return;
    }

    await _loadPage(page: state.currentPage + 1);
  }

  /// Resets to page 1 and reloads.
  Future<void> refresh() async {
    await _loadPage(reset: true);
  }

  /// Clears all active filters and schedules a debounced refresh.
  void clearFilters() {
    state = state.copyWith(filters: const MovieFilters());
    _scheduleRefresh();
  }

  /// Cancels any pending debounce timer and starts a new 400 ms one.
  void _scheduleRefresh() {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 400),
      () => _loadPage(reset: true),
    );
  }

  Future<void> _loadPage({int? page, bool reset = false}) async {
    final requestId = ++_requestSequence;
    final targetPage = reset ? 1 : (page ?? state.currentPage);

    state = state.copyWith(
      isLoading: reset,
      isLoadingMore: !reset,
      currentPage: targetPage,
      clearError: true,
      hasMore: reset ? true : state.hasMore,
      results: reset ? <Movie>[] : state.results,
    );

    // Use trending when there is no query and no filters
    final result = _shouldUseTrending
        ? await _getTrendingMoviesUseCase(targetPage)
        : await _searchMoviesUseCase(
            SearchMoviesParams(
              query: state.query,
              filters: state.filters,
              page: targetPage,
            ),
          );

    result.when(
      success: (moviePage) {
        // Discard if a newer request has already been issued
        if (requestId != _requestSequence) {
          return;
        }
        _handleSuccess(moviePage, reset);
      },
      failure: (failure) {
        if (requestId != _requestSequence) {
          return;
        }
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          error: failure.message,
        );
      },
    );
  }

  /// Returns `true` when the trending endpoint should be used instead of search.
  bool get _shouldUseTrending {
    return state.query.trim().isEmpty && state.filters.isEmpty;
  }

  void _handleSuccess(MoviePage page, bool reset) {
    // On reset, replace results; on pagination, append to existing list
    final mergedResults = reset
        ? page.movies
        : <Movie>[...state.results, ...page.movies];

    state = state.copyWith(
      results: mergedResults,
      isLoading: false,
      isLoadingMore: false,
      currentPage: page.page,
      hasMore: page.hasMore,
      clearError: true,
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
