// lib/features/home/presentation/widgets/search_history_widget.dart
// VERSION 2 - Placeholder for search history.

import 'package:flutter/material.dart';

/// Simple search history service.
/// TODO v3: Implement persistent storage with SharedPreferences
class SearchHistoryService {
  static final List<String> _history = [];

  static void add(String query) {
    if (query.trim().isEmpty) return;
    _history.remove(query);
    _history.insert(0, query);
    if (_history.length > 10) {
      _history.removeLast();
    }
  }

  static List<String> getAll() => List.unmodifiable(_history);

  static void clear() => _history.clear();
}

/// Widget showing search history.
/// TODO v3: Add delete individual items, persist to storage
class SearchHistoryWidget extends StatelessWidget {
  final ValueChanged<String> onQuerySelected;

  const SearchHistoryWidget({
    super.key,
    required this.onQuerySelected,
  });

  @override
  Widget build(BuildContext context) {
    final history = SearchHistoryService.getAll();

    if (history.isEmpty) {
      return Center(
        child: Text(
          'No recent searches',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      itemCount: history.length,
      itemBuilder: (_, i) => ListTile(
        leading: const Icon(Icons.history, color: Colors.grey),
        title: Text(
          history[i],
          style: const TextStyle(color: Colors.white),
        ),
        onTap: () => onQuerySelected(history[i]),
      ),
    );
  }
}
