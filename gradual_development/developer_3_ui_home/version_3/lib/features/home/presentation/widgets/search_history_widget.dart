// lib/features/home/presentation/widgets/search_history_widget.dart
// Persists and displays the user's recent search queries using SharedPreferences.
// Shown in the search screen when the query field is empty.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movie_watchlist/core/theme/app_colors.dart';

const _kSearchHistoryKey = 'search_history';

/// Maximum number of recent searches to retain.
const _kMaxHistory = 10;

/// Static helper class for reading and writing the search history list
/// stored in [SharedPreferences].
class SearchHistoryService {
  /// Returns the stored list of recent queries (most recent first).
  static Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_kSearchHistoryKey) ?? [];
  }

  /// Prepends [query] to the history, removing any existing duplicate,
  /// and trims the list to [_kMaxHistory] entries.
  static Future<void> add(String query) async {
    if (query.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_kSearchHistoryKey) ?? [];
    history.remove(query); // remove duplicate before re-inserting at top
    history.insert(0, query);
    if (history.length > _kMaxHistory) history.removeLast();
    await prefs.setStringList(_kSearchHistoryKey, history);
  }

  /// Removes a single [query] from the history.
  static Future<void> remove(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_kSearchHistoryKey) ?? [];
    history.remove(query);
    await prefs.setStringList(_kSearchHistoryKey, history);
  }

  /// Clears the entire search history.
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSearchHistoryKey);
  }
}

/// Displays recent search queries as deletable [InputChip]s.
///
/// Tapping a chip calls [onQuerySelected] so the parent can populate the
/// search field. Individual chips can be deleted, or the whole history can
/// be cleared via the "Clear history" button.
class SearchHistoryWidget extends StatefulWidget {
  final ValueChanged<String> onQuerySelected;

  const SearchHistoryWidget({super.key, required this.onQuerySelected});

  @override
  State<SearchHistoryWidget> createState() => _SearchHistoryWidgetState();
}

class _SearchHistoryWidgetState extends State<SearchHistoryWidget> {
  List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await SearchHistoryService.load();
    if (mounted) setState(() => _history = history);
  }

  Future<void> _removeItem(String query) async {
    await SearchHistoryService.remove(query);
    await _loadHistory();
  }

  Future<void> _clearAll() async {
    await SearchHistoryService.clear();
    if (mounted) setState(() => _history = []);
  }

  @override
  Widget build(BuildContext context) {
    if (_history.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history, size: 16, color: AppColors.textTertiary),
              const SizedBox(width: 6),
              const Text(
                'Recent Searches',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _clearAll,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Clear history',
                  style: TextStyle(color: AppColors.primary, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _history.map((query) {
              return InputChip(
                label: Text(
                  query,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
                backgroundColor: AppColors.surface,
                deleteIconColor: AppColors.textTertiary,
                side: BorderSide.none,
                onPressed: () => widget.onQuerySelected(query),
                onDeleted: () => _removeItem(query),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
