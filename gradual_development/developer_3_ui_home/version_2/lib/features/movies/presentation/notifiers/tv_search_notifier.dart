// lib/features/movies/presentation/notifiers/tv_search_notifier.dart
// VERSION 2 - Basic TV search notifier without filters or pagination.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_watchlist/features/movies/presentation/state/tv_search_state.dart';

/// Simple TV search notifier.
/// TODO v3: Add filters, pagination, debouncing
class TvSearchNotifier extends StateNotifier<TvSearchState> {
  TvSearchNotifier() : super(const TvSearchState());

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
