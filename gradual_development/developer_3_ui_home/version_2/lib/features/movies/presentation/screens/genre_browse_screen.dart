// lib/features/movies/presentation/screens/genre_browse_screen.dart
// VERSION 2 - Placeholder for genre browsing screen.

import 'package:flutter/material.dart';

/// Screen for browsing movies by genre.
/// TODO v3: Implement genre-based movie discovery with infinite scroll
class GenreBrowseScreen extends StatelessWidget {
  final int genreId;
  final String genreName;

  const GenreBrowseScreen({
    super.key,
    required this.genreId,
    required this.genreName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(genreName),
      ),
      body: Center(
        child: Text(
          'Genre browse coming in v3',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ),
    );
  }
}
