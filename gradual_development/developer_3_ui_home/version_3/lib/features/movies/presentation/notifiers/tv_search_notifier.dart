// lib/features/movies/presentation/notifiers/tv_search_notifier.dart
// StateNotifier that drives the TV show search screen. Uses [LegacyTmdbRepository]
// directly because the clean-arch movie repository only covers movies.

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_watchlist/features/movies/data/repositories/legacy_tmdb_repository.dart';
import 'package:movie_watchlist/features/movies/presentation/state/tv_search_state.dart';
import 'package:movie_watchlist/shared/models/tv_show.dart';

/// Manages TV show search state including query, filters, and pagination.
///
/// When the query is empty, [discoverTvShows] is used (server-side filters).
/// When a query is present, [searchTvShows] is used and rating filters are
/// applied client-side because TMDB's search endpoint doesn't support them.
class TvSearchNotifier extends StateNotifier<TvSearchState> {
  TvSearchNotifier({required LegacyTmdbRepository repository})
      : _repository = repository,
        super(TvSearchState.initial()) {
    _loadPage(reset: true);
  }

  final LegacyTmdbRepository _repository;
  Timer? _debounce;

  /// Monotonically increasing counter used to discard stale responses.
  int _requestSequence = 0;

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
  void updateMinimumRating(double? rating) {
    state = state.copyWith(
      filters: state.filters.copyWith(
        minimumRating: rating,
        clearRating: rating == null,
      ),
    );
    _scheduleRefresh();
  }

  /// Clears all active filters and schedules a debounced refresh.
  void clearFilters() {
    state = state.copyWith(filters: const TvFilters());
    _scheduleRefresh();
  }

  /// Appends the next page of results. No-ops if already loading or no more pages.
  Future<void> loadNextPage() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;
    await _loadPage(page: state.currentPage + 1);
  }

  /// Resets to page 1 and reloads.
  Future<void> refresh() => _loadPage(reset: true);

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
      results: reset ? <TvShow>[] : state.results,
    );

    try {
      final List<TvShow> fetched;
      final hasQuery = state.query.trim().isNotEmpty;

      if (hasQuery) {
        // Text search — TMDB /search/tv doesn't support genre/year/rating
        // filters directly, so we fetch and filter client-side for rating.
        final raw = await _repository.searchTvShows(
          state.query.trim(),
          page: targetPage,
        );
        fetched = _applyClientFilters(raw);
      } else {
        // Discover with server-side filters
        fetched = await _repository.discoverTvShows(
          page: targetPage,
          genreId: state.filters.genreId,
          year: state.filters.year,
          minimumRating: state.filters.minimumRating,
        );
      }

      if (requestId != _requestSequence) return;

      final merged = reset
          ? fetched
          : <TvShow>[...state.results, ...fetched];

      state = state.copyWith(
        results: merged,
        isLoading: false,
        isLoadingMore: false,
        currentPage: targetPage,
        // Assume no more pages when fewer than 20 results are returned
        hasMore: fetched.length >= 20,
        clearError: true,
      );
    } catch (e) {
      if (requestId != _requestSequence) return;
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  /// Applies the minimum rating filter client-side when using text search,
  /// since TMDB's /search/tv endpoint doesn't support vote_average filtering.
  List<TvShow> _applyClientFilters(List<TvShow> shows) {
    var result = shows;
    if (state.filters.minimumRating != null) {
      result = result
          .where((s) => s.voteAverage >= state.filters.minimumRating!)
          .toList();
    }
    return result;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
