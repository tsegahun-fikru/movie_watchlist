// lib/features/movies/presentation/notifiers/movie_search_notifier.dart
// VERSION 2 - Basic search notifier without filters or pagination.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_watchlist/features/movies/presentation/state/movie_search_state.dart';

/// Simple movie search notifier.
/// TODO v3: Add filters, pagination, debouncing
class MovieSearchNotifier extends StateNotifier<MovieSearchState> {
  MovieSearchNotifier() : super(const MovieSearchState());

  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  void clearFilters() {
    state = state.copyWith(filters: {});
  }

  void loadNextPage() {
    // TODO v3: Implement pagination
  }
}
