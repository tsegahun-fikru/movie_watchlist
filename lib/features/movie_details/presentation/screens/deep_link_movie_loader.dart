// lib/features/movie_details/presentation/screens/deep_link_movie_loader.dart
// Compatibility loader for the legacy `/movie/:id` deep-link route.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_watchlist/core/theme/app_colors.dart';
import 'package:movie_watchlist/features/movie_details/presentation/providers/media_detail_providers.dart';
import 'package:movie_watchlist/features/movie_details/presentation/screens/details_screen.dart';

class DeepLinkMovieLoader extends ConsumerWidget {
  const DeepLinkMovieLoader({super.key, required this.movieId});

  final int movieId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(
      mediaDetailProvider(MediaDetailRequest(type: 'movie', id: movieId)),
    );

    return detailAsync.when(
      data: (item) => DetailScreen(item: item),
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text(
            'Movie not found',
            style: const TextStyle(color: AppColors.textTertiary),
          ),
        ),
      ),
    );
  }
}
