// lib/features/movie_details/presentation/screens/details_screen.dart
// Full detail view for a Movie or TvShow. Fetches enriched data (genres,
// cast, trailer) from TMDB if not already present, then renders the backdrop
// banner, action bar, info grid, cast section, streaming providers, user
// rating, and similar content.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_watchlist/core/theme/app_colors.dart';
import 'package:movie_watchlist/shared/models/movie.dart';
import 'package:movie_watchlist/shared/models/tv_show.dart';
import 'package:movie_watchlist/shared/models/cast_members.dart';
import 'package:movie_watchlist/core/widgets/buttons/watchlist_button.dart';
import 'package:movie_watchlist/features/watched/presentation/widgets/watched_button.dart';
import 'package:movie_watchlist/features/watched/presentation/widgets/user_rating_bar.dart';
import 'package:movie_watchlist/features/movie_details/presentation/widgets/movie_trailer_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:movie_watchlist/features/movie_details/presentation/widgets/where_to_watch_section.dart';
import 'package:movie_watchlist/features/movie_details/presentation/widgets/season_episodes_sheet.dart';
import 'package:movie_watchlist/features/movie_details/presentation/widgets/cast_movies_sheet.dart';
import 'package:movie_watchlist/features/movies/presentation/providers/movie_providers.dart';
import 'package:movie_watchlist/features/movies/data/repositories/legacy_tmdb_repository.dart';
import 'package:movie_watchlist/core/providers/core_providers.dart';
import 'package:share_plus/share_plus.dart' show Share;

/// Full detail screen for a [Movie] or [TvShow].
///
/// [item] may be a lightweight list-endpoint object (no genres/cast/trailer).
/// [_loadDetails] fetches the enriched detail-endpoint response and replaces
/// [_enrichedItem] before the UI renders.
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

  /// Fetches full details (genres, cast, trailer) if the item is missing them.
  /// Falls back to the original item if the network request fails.
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
            autoPlay: false, // don't autoplay — user taps "Watch Trailer"
            mute: false,
            disableDragSeek: false,
            useHybridComposition: true, // better performance on Android
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
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share',
            onPressed: () {
              final deepLink = isMovie
                  ? 'https://moviewatchlist.app/movie/$id'
                  : 'https://moviewatchlist.app/tv/$id';
              Share.share(
                'Check out "$title" on Movie Watchlist!\n$deepLink',
                subject: title,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- Backdrop banner + poster card ----------
            _showTrailer && _trailerController != null
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: MovieTrailerPlayer(
                      controller: _trailerController!,
                      onClose: toggleTrailer,
                      thumbnailUrl: backdropUrl,
                    ),
                  )
                : _DetailHeroBanner(
                    id: id,
                    isMovie: isMovie,
                    posterUrl: posterUrl,
                    backdropUrl: backdropUrl,
                    title: title,
                    onTap: toggleTrailer,
                  ),
            if (!_showTrailer)
              Padding(
                padding: const EdgeInsets.only(left: 148, right: 16, top: 8),
                child: TextButton.icon(
                  onPressed: toggleTrailer,
                  icon: const Icon(Icons.play_circle_fill,
                      color: AppColors.primary, size: 18),
                  label: const Text(
                    'Watch Trailer',
                    style: TextStyle(
                        color: AppColors.textPrimary, fontSize: 13),
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
                      _TmdbRatingWidget(
                        rating: rating,
                        voteCount: isMovie ? movie!.voteCount : tvShow!.voteCount,
                      ),
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
                              backgroundColor: AppColors.primary.withValues(alpha: 0.7),
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
                          final seasonNumber = index + 1;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ActionChip(
                              label: Text('Season $seasonNumber'),
                              backgroundColor: AppColors.surfaceLight,
                              labelStyle: const TextStyle(
                                  color: AppColors.textPrimary),
                              side: BorderSide.none,
                              onPressed: () => showSeasonEpisodesSheet(
                                context: context,
                                repository: ref
                                    .read(legacyTmdbRepositoryProvider),
                                seriesId: id,
                                seasonNumber: seasonNumber,
                                showName: title,
                              ),
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

            // ---------- User Rating ----------
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: UserRatingBar(
                item: item,
                docId: isMovie ? 'movie_$id' : 'tv_$id',
              ),
            ),

            // ---------- Similar ----------
            _SimilarSection(
              isMovie: isMovie,
              id: id,
              repository: ref.read(legacyTmdbRepositoryProvider),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ---------- Helper Widgets ----------

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

  /// Formats [minutes] as `'Xh Ym'`. Returns `'—'` for zero or negative values.
  String _formatDuration(int minutes) {
    if (minutes <= 0) return '—';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}h ${mins}m';
  }

  Widget _buildCastSection(List<CastMember> cast) {
    final displayCast = cast.take(10).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text(
                'Cast',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (cast.length > 10)
                TextButton(
                  onPressed: () => _showAllCastSheet(cast),
                  child: const Text(
                    'See all',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: displayCast.length,
            itemBuilder: (_, i) {
              final actor = displayCast[i];
              return GestureDetector(
                onTap: () => showCastMoviesSheet(
                  context,
                  ref.read(legacyTmdbRepositoryProvider),
                  actor.name,
                ),
                child: Container(
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
                            ? const Icon(Icons.person,
                                color: AppColors.textTertiary)
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAllCastSheet(List<CastMember> cast) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Full Cast',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const Divider(height: 1, color: Colors.white10),
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: cast.length,
                  itemBuilder: (_, i) {
                    final actor = cast[i];
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        showCastMoviesSheet(
                          context,
                          ref.read(legacyTmdbRepositoryProvider),
                          actor.name,
                        );
                      },
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundImage: actor.profileUrl.isNotEmpty
                                ? CachedNetworkImageProvider(actor.profileUrl)
                                : null,
                            backgroundColor: AppColors.surfaceLight,
                            child: actor.profileUrl.isEmpty
                                ? const Icon(Icons.person,
                                    color: AppColors.textTertiary, size: 28)
                                : null,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            actor.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (actor.character.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              actor.character,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── TMDB Rating Widget ───────────────────────────────────────────────────────

/// Displays the TMDB rating with a star icon, score, vote count, and a
/// small "TMDB" source badge.
class _TmdbRatingWidget extends StatelessWidget {
  final double rating;
  final int voteCount;

  const _TmdbRatingWidget({required this.rating, required this.voteCount});

  String _formatVoteCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, color: AppColors.star, size: 22),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            color: AppColors.star,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          '/10',
          style: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '(${_formatVoteCount(voteCount)})',
          style: const TextStyle(
            color: AppColors.textTertiary,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
          child: const Text(
            'TMDB',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Detail hero banner: 16:9 backdrop + overlapping poster card ─────────────

/// Renders a 16:9 backdrop image with a poster card overlapping the bottom edge.
///
/// The poster card uses a [Hero] animation so it transitions smoothly from
/// the list card. Tapping the backdrop calls [onTap] to toggle the trailer.
class _DetailHeroBanner extends StatelessWidget {
  final int id;
  final bool isMovie;
  final String posterUrl;
  final String backdropUrl;
  final String title;
  final VoidCallback onTap;

  const _DetailHeroBanner({
    required this.id,
    required this.isMovie,
    required this.posterUrl,
    required this.backdropUrl,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Backdrop height = 16:9 of screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final backdropHeight = screenWidth * 9 / 16;
    // Poster card: 2:3 ratio, 100px wide, overlaps 40px below backdrop
    const posterW = 100.0;
    const posterH = posterW * 3 / 2; // 150px
    const overlap = 40.0;

    return SizedBox(
      height: backdropHeight + overlap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Backdrop (16:9) ──
          GestureDetector(
            onTap: onTap,
            child: SizedBox(
              width: double.infinity,
              height: backdropHeight,
              child: backdropUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: backdropUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: AppColors.surface,
                        child: const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary),
                        ),
                      ),
                      errorWidget: (_, __, ___) =>
                          Container(color: AppColors.surface),
                    )
                  : Container(color: AppColors.surface),
            ),
          ),
          // Bottom gradient on backdrop
          Positioned(
            bottom: overlap,
            left: 0,
            right: 0,
            height: backdropHeight * 0.5,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.background.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
          ),
          // ── Poster card overlapping below backdrop ──
          Positioned(
            bottom: 0,
            left: 16,
            child: Hero(
              tag: isMovie ? 'movie-$id' : 'tv-$id',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: posterW,
                  height: posterH,
                  child: posterUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: posterUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: AppColors.surfaceLight),
                          errorWidget: (_, __, ___) =>
                              Container(color: AppColors.surfaceLight),
                        )
                      : Container(color: AppColors.surfaceLight),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Similar movies / TV section ─────────────────────────────────────────────

/// Fetches and displays a horizontal row of similar movies or TV shows.
/// Silently hidden when the list is empty or the request fails (with a retry).
class _SimilarSection extends StatefulWidget {
  final bool isMovie;
  final int id;
  final LegacyTmdbRepository repository;

  const _SimilarSection({
    required this.isMovie,
    required this.id,
    required this.repository,
  });

  @override
  State<_SimilarSection> createState() => _SimilarSectionState();
}

class _SimilarSectionState extends State<_SimilarSection> {
  late Future<List<Object>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.isMovie
        ? widget.repository
            .getSimilarMovies(widget.id)
            .then((list) => list.cast<Object>())
        : widget.repository
            .getSimilarTvShows(widget.id)
            .then((list) => list.cast<Object>());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Object>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text(
                  'You Might Also Like',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _future = widget.isMovie
                          ? widget.repository
                              .getSimilarMovies(widget.id)
                              .then((list) => list.cast<Object>())
                          : widget.repository
                              .getSimilarTvShows(widget.id)
                              .then((list) => list.cast<Object>());
                    });
                  },
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        if (!snapshot.hasData) return const SizedBox.shrink();
        final items = snapshot.data!
            .where((item) {
              if (item is Movie) return item.posterPath.isNotEmpty;
              if (item is TvShow) return item.posterPath.isNotEmpty;
              return false;
            })
            .take(15)
            .toList();
        if (items.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'You Might Also Like',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final item = items[i];
                  final posterUrl = item is Movie
                      ? item.posterUrl
                      : (item as TvShow).fullPosterUrl;
                  final title =
                      item is Movie ? item.title : (item as TvShow).name;

                  return GestureDetector(
                    onTap: () => context.push('/details', extra: item),
                    child: Container(
                      width: 120,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                imageUrl: posterUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                placeholder: (_, __) => Container(
                                    color: AppColors.surfaceLight),
                                errorWidget: (_, __, ___) => Container(
                                  color: AppColors.surfaceLight,
                                  child: const Icon(Icons.broken_image,
                                      color: AppColors.textTertiary),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
