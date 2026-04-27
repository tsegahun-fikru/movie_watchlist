import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_watchlist/features/movies/domain/entities/movie.dart';
import 'package:movie_watchlist/features/movies/domain/entities/movie_filters.dart';
import 'package:movie_watchlist/features/movies/domain/entities/movie_page.dart';
import 'package:movie_watchlist/features/movies/domain/usecases/get_trending_movies_use_case.dart';
import 'package:movie_watchlist/features/movies/domain/usecases/search_movies_use_case.dart';
import 'package:movie_watchlist/features/movies/presentation/state/movie_search_state.dart';

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
  int _requestSequence = 0;

  Future<void> loadInitial() async {
    await _loadPage(reset: true);
  }

  void setQuery(String query) {
    state = state.copyWith(query: query);
    _scheduleRefresh();
  }

  void updateGenre(int? genreId) {
    state = state.copyWith(
      filters: state.filters.copyWith(
        genreId: genreId,
        clearGenre: genreId == null,
      ),
    );
    _scheduleRefresh();
  }

  void updateYear(int? year) {
    state = state.copyWith(
      filters: state.filters.copyWith(year: year, clearYear: year == null),
    );
    _scheduleRefresh();
  }

  void updateMinimumRating(double? minimumRating) {
    state = state.copyWith(
      filters: state.filters.copyWith(
        minimumRating: minimumRating,
        clearRating: minimumRating == null,
      ),
    );
    _scheduleRefresh();
  }

  Future<void> loadNextPage() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) {
      return;
    }

    await _loadPage(page: state.currentPage + 1);
  }

  Future<void> refresh() async {
    await _loadPage(reset: true);
  }

  void clearFilters() {
    state = state.copyWith(filters: const MovieFilters());
    _scheduleRefresh();
  }

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

  bool get _shouldUseTrending {
    return state.query.trim().isEmpty && state.filters.isEmpty;
  }

  void _handleSuccess(MoviePage page, bool reset) {
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
