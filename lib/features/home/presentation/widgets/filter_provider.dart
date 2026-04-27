// lib/features/home/presentation/widgets/filter_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

class FilterState {
  final Set<int> selectedGenreIds;
  final int? selectedYear;

  const FilterState({this.selectedGenreIds = const {}, this.selectedYear});

  // ✅ FIX: REQUIRED
  FilterState copyWith({Set<int>? selectedGenreIds, int? selectedYear}) {
    return FilterState(
      selectedGenreIds: selectedGenreIds ?? this.selectedGenreIds,
      selectedYear: selectedYear ?? this.selectedYear,
    );
  }
}

class FilterNotifier extends StateNotifier<FilterState> {
  FilterNotifier() : super(const FilterState());

  void toggleGenre(int genreId) {
    final newSet = Set<int>.from(state.selectedGenreIds);

    if (newSet.contains(genreId)) {
      newSet.remove(genreId);
    } else {
      newSet.add(genreId);
    }

    state = state.copyWith(selectedGenreIds: newSet);
  }

  void setYear(int? year) {
    state = state.copyWith(
      selectedYear: year == state.selectedYear ? null : year,
    );
  }

  void clearAll() {
    state = const FilterState();
  }
}

final filterProvider = StateNotifierProvider<FilterNotifier, FilterState>(
  (ref) => FilterNotifier(),
);
