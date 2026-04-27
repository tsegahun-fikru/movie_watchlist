// lib/features/movie_details/presentation/screens/details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movie_watchlist/core/theme/app_colors.dart';
import 'package:movie_watchlist/shared/models/movie.dart';
import 'package:movie_watchlist/shared/models/tv_show.dart';
import 'package:movie_watchlist/shared/models/cast_members.dart';
import 'package:movie_watchlist/core/widgets/buttons/watchlist_button.dart';
import 'package:movie_watchlist/features/watched/presentation/widgets/watched_button.dart';
import 'package:movie_watchlist/features/movie_details/presentation/widgets/movie_trailer_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:movie_watchlist/features/movie_details/presentation/widgets/where_to_watch_section.dart';
import 'package:movie_watchlist/features/movies/presentation/providers/movie_providers.dart';
import 'package:movie_watchlist/core/providers/core_providers.dart';

class DetailScreen extends ConsumerStatefulWidget {
  final Object item; // Movie or TvShow (may lack full details)
  const DetailScreen({super.key, required this.item});

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  bool _isLoading = true;
  Object? _enrichedItem;
  bool _showTrailer = false;
  YoutubePlayerController? _trailerController;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    Object? item = widget.item;

    // Check if we need to fetch full details
    if (item is Movie) {
      if (item.genres.isEmpty || item.cast.isEmpty || item.trailerKey == null) {
        try {
          final json = await ref.read(legacyTmdbRepositoryProvider).getMovieDetails(item.id);
          item = Movie.fromJson(json);
        } catch (e) {
          // Fallback to original item if fetch fails
        }
      }
    } else if (item is TvShow) {
      if (item.genres.isEmpty || item.cast.isEmpty || item.trailerKey == null) {
        try {
          final json = await ref.read(legacyTmdbRepositoryProvider).getTvDetails(item.id);
          item = TvShow.fromJson(json);
        } catch (e) {
          // Fallback
        }
      }
    }

    if (mounted) {
      // Pre-initialize the trailer controller as soon as the key is available
      final trailerKey = item is Movie ? item.trailerKey : (item as TvShow).trailerKey;
      if (trailerKey != null && trailerKey.isNotEmpty) {
        _trailerController = YoutubePlayerController(
          initialVideoId: trailerKey,
          flags: const YoutubePlayerFlags(
            autoPlay: true,
            mute: false,
            disableDragSeek: true,
          ),
        );
      }

      setState(() {
        _enrichedItem = item;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _trailerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final region = ref.watch(currentRegionProvider);

    if (_isLoading || _enrichedItem == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final item = _enrichedItem!;
    final isMovie = item is Movie;
    final movie = item is Movie ? item : null;
    final tvShow = item is TvShow ? item : null;

    final String title;
    final String posterUrl;
    final String backdropUrl;
    final double rating;
    final String overview;
    final int id;
    final String year;
    final String language;
    final int runtime;
    final int numberOfSeasons;
    final List<String> genres;
    final String? trailerKey;
    final List<CastMember> cast;

    if (isMovie) {
      final m = movie!;
      title = m.title;
      posterUrl = m.posterUrl;
      backdropUrl = m.backdropUrl;
      rating = m.voteAverage;
      overview = m.overview;
      id = m.id;
      year = m.releaseDate.isNotEmpty ? m.releaseDate.substring(0, 4) : '---';
      language = m.originalLanguage.toUpperCase();
      runtime = m.runtime;
      genres = m.genres;
      trailerKey = m.trailerKey;
      cast = m.cast;
      numberOfSeasons = 0;
    } else {
      final tv = tvShow!;
      title = tv.name;
      posterUrl = tv.fullPosterUrl;
      backdropUrl = tv.fullBackdropUrl;
      rating = tv.voteAverage;
      overview = tv.overview;
      id = tv.id;
      year = tv.firstAirDate.isNotEmpty
          ? tv.firstAirDate.substring(0, 4)
          : '---';
      language = tv.originalLanguage.toUpperCase();
      runtime = tv.episodeRunTime.isNotEmpty ? tv.episodeRunTime.first : 0;
      genres = tv.genres;
      trailerKey = tv.trailerKey;
      cast = tv.cast;
      numberOfSeasons = tv.numberOfSeasons;
    }

    Future<void> toggleTrailer() async {
      if (_showTrailer) {
        setState(() => _showTrailer = false);
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
        _trailerController?.pause();
      } else {
        if (trailerKey == null || trailerKey.isEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('No trailer available')));
          return;
        }
        // Allow landscape only while the embedded trailer is open.
        setState(() => _showTrailer = true);
        _trailerController?.play();
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(title, overflow: TextOverflow.ellipsis),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- Poster / Trailer ----------
            _showTrailer && _trailerController != null
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: MovieTrailerPlayer(
                      controller: _trailerController!,
                      onClose: toggleTrailer,
                      thumbnailUrl: backdropUrl,
                    ),
                  )
                : Hero(
                    tag: isMovie ? 'movie-$id' : 'tv-$id',
                    child: GestureDetector(
                      onTap: toggleTrailer,
                      child: posterUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: posterUrl,
                              width: double.infinity,
                              height: 300,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                height: 300,
                                color: AppColors.background,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  _noImagePlaceholder(title),
                            )
                          : _noImagePlaceholder(title),
                    ),
                  ),
            if (!_showTrailer)
              Center(
                child: TextButton.icon(
                  onPressed: toggleTrailer,
                  icon: const Icon(Icons.play_circle_fill, color: AppColors.primary),
                  label: const Text(
                    'Watch Trailer',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ),
              ),

            // ---------- Action Bar ----------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      WatchlistButton(item: item),
                      const Text(
                        'Watchlist',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  WatchedButton(item: item),
                ],
              ),
            ),

            // ---------- Info Grid ----------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Info chips with TV-specific adjustments
                  Wrap(
                    spacing: 20,
                    runSpacing: 8,
                    children: [
                      _infoChip(Icons.star, rating.toStringAsFixed(1)),
                      if (isMovie) _infoChip(Icons.calendar_today, year),
                      if (tvShow != null)
                        _infoChip(Icons.calendar_today, tvShow.firstAirDate),
                      _infoChip(Icons.access_time, _formatDuration(runtime)),
                      if (language.isNotEmpty)
                        _infoChip(Icons.language, language),
                      if (!isMovie && numberOfSeasons > 0)
                        _infoChip(
                          Icons.tv,
                          '$numberOfSeasons Season${numberOfSeasons != 1 ? 's' : ''}',
                        ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  if (genres.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children: genres
                          .map(
                            (g) => Chip(
                              label: Text(
                                g,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 12,
                                ),
                              ),
                              backgroundColor: AppColors.primary.withOpacity(0.7),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          )
                          .toList(),
                    ),

                  // Season list (TV only)
                  if (!isMovie && numberOfSeasons > 0) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Seasons',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: numberOfSeasons,
                        itemBuilder: (_, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Chip(
                              label: Text('Season ${index + 1}'),
                              backgroundColor: AppColors.surfaceLight,
                              labelStyle: const TextStyle(color: AppColors.textPrimary),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                  const Text(
                    'Storyline',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    overview.isNotEmpty
                        ? overview
                        : 'No description available.',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // ---------- Streaming Providers ----------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: WhereToWatchSection(
                providersFuture: isMovie
                    ? ref.read(legacyTmdbRepositoryProvider).getMovieWatchProviders(id, region)
                    : ref.read(legacyTmdbRepositoryProvider).getTvWatchProviders(id, region),
              ),
            ),

            // ---------- Cast ----------
            if (cast.isNotEmpty) _buildCastSection(cast),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ---------- Helper Widgets ----------

  Widget _noImagePlaceholder(String title) {
    return Container(
      height: 300,
      color: AppColors.surface,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.broken_image, size: 64, color: AppColors.textTertiary),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textTertiary, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.textTertiary, size: 18),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
      ],
    );
  }

  String _formatDuration(int minutes) {
    if (minutes <= 0) return '—';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}h ${mins}m';
  }

  Widget _buildCastSection(List<CastMember> cast) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Cast',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: cast.length,
            itemBuilder: (_, i) {
              final actor = cast[i];
              return Container(
                width: 80,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: actor.profileUrl.isNotEmpty
                          ? CachedNetworkImageProvider(actor.profileUrl)
                          : null,
                      backgroundColor: AppColors.surfaceLight,
                      child: actor.profileUrl.isEmpty
                          ? const Icon(Icons.person, color: AppColors.textTertiary)
                          : null,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      actor.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
