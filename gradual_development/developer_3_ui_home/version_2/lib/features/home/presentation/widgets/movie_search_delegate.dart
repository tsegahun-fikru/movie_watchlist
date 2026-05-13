// lib/features/home/presentation/widgets/movie_search_delegate.dart
// VERSION 2 - Basic search screen with movie/TV toggle. No filters yet.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_watchlist/shared/models/movie.dart';
import 'package:movie_watchlist/shared/models/tv_show.dart';

enum _SearchTab { movies, tv }

/// Tracks which search tab is active.
final _searchTabProvider = StateProvider<_SearchTab>((_) => _SearchTab.movies);

/// Simple search screen with Movies/TV toggle.
/// TODO v3: Add filters, infinite scroll, search history
class MovieSearchScreen extends ConsumerStatefulWidget {
  const MovieSearchScreen({super.key});

  @override
  ConsumerState<MovieSearchScreen> createState() => _MovieSearchScreenState();
}

class _MovieSearchScreenState extends ConsumerState<MovieSearchScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tab = ref.watch(_searchTabProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: TextField(
            controller: _controller,
            autofocus: false,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: tab == _SearchTab.movies
                  ? 'Search movies…'
                  : 'Search TV shows…',
              hintStyle: TextStyle(color: Colors.grey[600]),
              filled: true,
              fillColor: Colors.grey[900],
              prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
              suffixIcon: _controller.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () => _controller.clear(),
                      icon: Icon(Icons.close, color: Colors.grey[400]),
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Movies / TV toggle
            _SearchToggle(
              current: tab,
              onChanged: (t) {
                ref.read(_searchTabProvider.notifier).state = t;
              },
            ),
            const SizedBox(height: 16),

            // Results placeholder
            Expanded(
              child: Center(
                child: Text(
                  'Search results will appear here',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Toggle widget for Movies/TV tabs.
class _SearchToggle extends StatelessWidget {
  final _SearchTab current;
  final ValueChanged<_SearchTab> onChanged;

  const _SearchToggle({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _ToggleOption(
            label: 'Movies',
            icon: Icons.movie_outlined,
            selected: current == _SearchTab.movies,
            onTap: () => onChanged(_SearchTab.movies),
          ),
          _ToggleOption(
            label: 'TV Shows',
            icon: Icons.tv_outlined,
            selected: current == _SearchTab.tv,
            onTap: () => onChanged(_SearchTab.tv),
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: selected ? Colors.red : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? Colors.white : Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  color: selected ? Colors.white : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
