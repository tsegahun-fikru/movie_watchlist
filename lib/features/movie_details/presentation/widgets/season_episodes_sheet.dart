// lib/features/movie_details/presentation/widgets/season_episodes_sheet.dart
// Bottom sheet that lists all episodes for a selected TV show season.

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movie_watchlist/core/theme/app_colors.dart';
import 'package:movie_watchlist/features/movies/data/repositories/legacy_tmdb_repository.dart';
import 'package:movie_watchlist/shared/models/tv_episode.dart';

/// Shows a draggable bottom sheet listing all episodes for a given season.
///
/// Fetches episodes via [LegacyTmdbRepository.getSeasonEpisodes] and renders
/// them as expandable tiles with still images, air dates, and overviews.
Future<void> showSeasonEpisodesSheet({
  required BuildContext context,
  required LegacyTmdbRepository repository,
  required int seriesId,
  required int seasonNumber,
  required String showName,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SeasonSheet(
      repository: repository,
      seriesId: seriesId,
      seasonNumber: seasonNumber,
      showName: showName,
    ),
  );
}

class _SeasonSheet extends StatefulWidget {
  final LegacyTmdbRepository repository;
  final int seriesId;
  final int seasonNumber;
  final String showName;

  const _SeasonSheet({
    required this.repository,
    required this.seriesId,
    required this.seasonNumber,
    required this.showName,
  });

  @override
  State<_SeasonSheet> createState() => _SeasonSheetState();
}

class _SeasonSheetState extends State<_SeasonSheet> {
  late Future<List<TvEpisode>> _episodesFuture;

  @override
  void initState() {
    super.initState();
    _episodesFuture = widget.repository.getSeasonEpisodes(
      widget.seriesId,
      widget.seasonNumber,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle bar
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header with show name, season number, and close button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.showName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'Season ${widget.seasonNumber}',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textSecondary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: Colors.white10),

              // Episode list
              Expanded(
                child: FutureBuilder<List<TvEpisode>>(
                  future: _episodesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'Could not load episodes.\n${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      );
                    }

                    final episodes = snapshot.data ?? [];
                    if (episodes.isEmpty) {
                      return const Center(
                        child: Text(
                          'No episodes available.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      );
                    }

                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      itemCount: episodes.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: Colors.white10),
                      itemBuilder: (_, i) => _EpisodeTile(episode: episodes[i]),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A single episode row with a still image, metadata, and an expandable overview.
class _EpisodeTile extends StatefulWidget {
  final TvEpisode episode;
  const _EpisodeTile({required this.episode});

  @override
  State<_EpisodeTile> createState() => _EpisodeTileState();
}

class _EpisodeTileState extends State<_EpisodeTile> {
  /// Whether the overview text is expanded.
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final ep = widget.episode;
    final hasStill = ep.stillUrl.isNotEmpty;
    final hasOverview = ep.overview.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: GestureDetector(
        // Tapping the tile toggles the overview expansion
        onTap: hasOverview ? () => setState(() => _expanded = !_expanded) : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Episode still image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 110,
                height: 65,
                child: hasStill
                    ? CachedNetworkImage(
                        imageUrl: ep.stillUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: AppColors.surfaceLight,
                        ),
                        errorWidget: (_, __, ___) => _stillPlaceholder(),
                      )
                    : _stillPlaceholder(),
              ),
            ),
            const SizedBox(width: 12),

            // Episode info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Episode number + title
                  Row(
                    children: [
                      Text(
                        'E${ep.episodeNumber}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          ep.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Meta row: air date, runtime, rating
                  Wrap(
                    spacing: 10,
                    children: [
                      if (ep.airDate.isNotEmpty)
                        _meta(Icons.calendar_today, ep.airDate),
                      if (ep.runtime > 0)
                        _meta(Icons.access_time, '${ep.runtime}m'),
                      if (ep.voteAverage > 0)
                        _meta(Icons.star, ep.voteAverage.toStringAsFixed(1)),
                    ],
                  ),

                  // Expandable overview with animated cross-fade
                  if (hasOverview) ...[
                    const SizedBox(height: 4),
                    AnimatedCrossFade(
                      firstChild: Text(
                        ep.overview,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                      secondChild: Text(
                        ep.overview,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                      crossFadeState: _expanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 200),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _expanded ? 'Show less' : 'Show more',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _meta(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: AppColors.textTertiary),
        const SizedBox(width: 3),
        Text(text,
            style: const TextStyle(
                color: AppColors.textTertiary, fontSize: 11)),
      ],
    );
  }

  Widget _stillPlaceholder() {
    return Container(
      color: AppColors.surfaceLight,
      child: const Center(
        child: Icon(Icons.tv, color: AppColors.textTertiary, size: 24),
      ),
    );
  }
}
