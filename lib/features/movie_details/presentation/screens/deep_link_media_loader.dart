import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_watchlist/core/theme/app_colors.dart';
import 'package:movie_watchlist/features/movie_details/presentation/providers/media_detail_providers.dart';
import 'package:movie_watchlist/features/movie_details/presentation/screens/details_screen.dart';

class DeepLinkMediaLoader extends ConsumerWidget {
  const DeepLinkMediaLoader({super.key, required this.type, required this.id});

  final String type;
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(
      mediaDetailProvider(MediaDetailRequest(type: type, id: id)),
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
            'Unable to load ${type == 'tv' ? 'TV show' : 'movie'}',
            style: const TextStyle(color: AppColors.textTertiary),
          ),
        ),
      ),
    );
  }
}
