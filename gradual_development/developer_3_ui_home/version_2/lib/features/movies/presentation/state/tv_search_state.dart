// lib/features/movies/presentation/state/tv_search_state.dart
// VERSION 2 - Basic TV search state without pagination.

import 'package:movie_watchlist/shared/models/tv_show.dart';

/// State for TV show search.
/// TODO v3: Add pagination fields (page, hasMore, isLoadingMore)
class TvSearchState {
  final String query;
  final List<TvShow> results;
  final Map<String, dynamic> filters;
  final bool isLoading;
  final String? error;

  const TvSearchState({
    this.query = '',
    this.results = const [],
    this.filters = const {},
    this.isLoading = false,
    this.error,
  });

  TvSearchState copyWith({
    String? query,
    List<TvShow>? results,
    Map<String, dynamic>? filters,
    bool? isLoading,
    String? error,
  }) {
    return TvSearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      filters: filters ?? this.filters,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  bool get isEmpty => results.isEmpty;
}
