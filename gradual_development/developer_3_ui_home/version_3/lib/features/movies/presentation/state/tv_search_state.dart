// lib/features/movies/presentation/state/tv_search_state.dart
// Immutable state and filter classes for the TV show search notifier.

import 'package:movie_watchlist/shared/models/tv_show.dart';

/// Filter parameters for TV show search/discovery.
class TvFilters {
  final int? genreId;
  final int? year;
  final double? minimumRating;

  const TvFilters({this.genreId, this.year, this.minimumRating});

  /// Returns `true` when no filters are active.
  bool get isEmpty => genreId == null && year == null && minimumRating == null;

  /// Returns a copy with the provided fields overridden.
  /// Use the `clear*` flags to explicitly set a field to null.
  TvFilters copyWith({
    int? genreId,
    bool clearGenre = false,
    int? year,
    bool clearYear = false,
    double? minimumRating,
    bool clearRating = false,
  }) {
    return TvFilters(
      genreId: clearGenre ? null : genreId ?? this.genreId,
      year: clearYear ? null : year ?? this.year,
      minimumRating:
          clearRating ? null : minimumRating ?? this.minimumRating,
    );
  }
}

/// Holds the complete state of the TV show search screen.
///
/// Mirrors [MovieSearchState] but uses [TvFilters] and [TvShow] results.
class TvSearchState {
  const TvSearchState({
    required this.query,
    required this.filters,
    required this.results,
    required this.isLoading,
    required this.isLoadingMore,
    required this.error,
    required this.currentPage,
    required this.hasMore,
  });

  factory TvSearchState.initial() => const TvSearchState(
        query: '',
        filters: TvFilters(),
        results: [],
        isLoading: false,
        isLoadingMore: false,
        error: null,
        currentPage: 1,
        hasMore: true,
      );

  final String query;
  final TvFilters filters;
  final List<TvShow> results;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final bool hasMore;

  /// Returns a copy with the provided fields overridden.
  /// [clearError] can be set to `true` to explicitly null out [error].
  TvSearchState copyWith({
    String? query,
    TvFilters? filters,
    List<TvShow>? results,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool clearError = false,
    int? currentPage,
    bool? hasMore,
  }) {
    return TvSearchState(
      query: query ?? this.query,
      filters: filters ?? this.filters,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
