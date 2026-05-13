// lib/features/movies/presentation/state/movie_search_state.dart
// Immutable state class for the movie search notifier.

import 'package:movie_watchlist/features/movies/domain/entities/movie.dart';
import 'package:movie_watchlist/features/movies/domain/entities/movie_filters.dart';

/// Holds the complete state of the movie search screen.
///
/// [results] accumulates across pages for infinite scroll.
/// [isLoading] is true during the initial/reset load.
/// [isLoadingMore] is true when appending the next page.
/// [hasMore] becomes false when TMDB reports no further pages.
class MovieSearchState {
  const MovieSearchState({
    required this.query,
    required this.filters,
    required this.results,
    required this.isLoading,
    required this.isLoadingMore,
    required this.error,
    required this.currentPage,
    required this.hasMore,
  });

  factory MovieSearchState.initial() {
    return const MovieSearchState(
      query: '',
      filters: MovieFilters(),
      results: <Movie>[],
      isLoading: false,
      isLoadingMore: false,
      error: null,
      currentPage: 1,
      hasMore: true,
    );
  }

  final String query;
  final MovieFilters filters;
  final List<Movie> results;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final bool hasMore;

  /// Returns a copy of this state with the provided fields overridden.
  /// [clearError] can be set to `true` to explicitly null out [error].
  MovieSearchState copyWith({
    String? query,
    MovieFilters? filters,
    List<Movie>? results,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool clearError = false,
    int? currentPage,
    bool? hasMore,
  }) {
    return MovieSearchState(
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
