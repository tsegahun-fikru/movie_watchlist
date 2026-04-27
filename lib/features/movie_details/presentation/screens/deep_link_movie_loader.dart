// lib/features/movie_details/presentation/screens/deep_link_movie_loader.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_watchlist/core/theme/app_colors.dart';
import 'package:movie_watchlist/shared/models/movie.dart';
import 'package:movie_watchlist/features/movies/presentation/providers/movie_providers.dart';
import 'package:movie_watchlist/features/movie_details/presentation/screens/details_screen.dart';

class DeepLinkMovieLoader extends ConsumerWidget {
  final int movieId;
  const DeepLinkMovieLoader({super.key, required this.movieId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Movie>(
      future: ref.read(legacyTmdbRepositoryProvider).getMovieById(movieId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }
        if (snapshot.hasError || snapshot.data == null) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Text(
                'Movie not found',
                style: TextStyle(color: AppColors.textTertiary),
              ),
            ),
          );
        }
        return DetailScreen(item: snapshot.data!);
      },
    );
  }
}
