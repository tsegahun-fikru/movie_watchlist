// lib/features/movies/presentation/widgets/movie_search_result_list.dart
// VERSION 2 - Placeholder for movie search results list.

import 'package:flutter/material.dart';

/// List widget for movie search results.
/// TODO v3: Implement actual search results with infinite scroll
class MovieSearchResultList extends StatelessWidget {
  final ScrollController scrollController;

  const MovieSearchResultList({
    super.key,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Search results coming in v3',
        style: TextStyle(color: Colors.grey[600]),
      ),
    );
  }
}
