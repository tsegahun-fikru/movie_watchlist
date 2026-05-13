// lib/features/movies/presentation/state/movie_search_state.dart
// VERSION 2 - Basic search state without pagination.

import 'package:movie_watchlist/shared/models/movie.dart';

/// State for movie search.
/// TODO v3: Add pagination fields (page, hasMore, isLoadingMore)
class MovieSearchState {
  final String query;
  final List<Movie> results;
  final Map<String, dynamic> filters;
  final bool isLoading;
  final String? error;

  const MovieSearchState({
    this.query = '',
    this.results = const [],
    this.filters = const {},
    this.isLoading = false,
    this.error,
  });

  MovieSearchState copyWith({
    String? query,
    List<Movie>? results,
    Map<String, dynamic>? filters,
    bool? isLoading,
    String? error,
  }) {
    return MovieSearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      filters: filters ?? this.filters,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  bool get isEmpty => results.isEmpty;
}
