// lib/core/widgets/movie_card.dart
// Backward-compatible movie card wrapper around the shared MediaCard.

import 'package:flutter/material.dart';
import 'package:movie_watchlist/core/widgets/media_card.dart';
import 'package:movie_watchlist/shared/models/movie.dart';

class MovieCard extends StatelessWidget {
  const MovieCard({super.key, required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return MediaCard(item: movie);
  }
}
