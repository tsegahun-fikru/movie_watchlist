// lib/core/widgets/tv_show_card.dart
// Backward-compatible TV card wrapper around the shared MediaCard.

import 'package:flutter/material.dart';
import 'package:movie_watchlist/core/widgets/media_card.dart';
import 'package:movie_watchlist/shared/models/tv_show.dart';

class TvShowCard extends StatelessWidget {
  const TvShowCard({super.key, required this.tvShow});

  final TvShow tvShow;

  @override
  Widget build(BuildContext context) {
    return MediaCard(item: tvShow);
  }
}
