import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movie_watchlist/core/theme/app_colors.dart';

class WhereToWatchSection extends StatelessWidget {
  final Future<List<Map<String, dynamic>>> providersFuture;

  const WhereToWatchSection({super.key, required this.providersFuture});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: providersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        final providers = snapshot.data ?? [];
        if (providers.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'No streaming information available for your region.',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 14),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Where to Watch',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: providers.map((p) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Tooltip(
                      message: p['name'] as String,
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: p['logo'] as String,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            width: 40,
                            height: 40,
                            color: AppColors.surfaceLight,
                            child: const Icon(
                              Icons.live_tv,
                              color: AppColors.textTertiary,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}
