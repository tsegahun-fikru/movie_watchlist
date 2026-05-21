import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_watchlist/features/movies/presentation/providers/movie_providers.dart';
import 'package:movie_watchlist/shared/models/movie.dart';
import 'package:movie_watchlist/shared/models/tv_show.dart';

class MediaDetailRequest {
  const MediaDetailRequest({required this.type, required this.id});

  final String type;
  final int id;

  @override
  bool operator ==(Object other) {
    return other is MediaDetailRequest && other.type == type && other.id == id;
  }

  @override
  int get hashCode => Object.hash(type, id);
}

final mediaDetailProvider = FutureProvider.family<Object, MediaDetailRequest>((
  ref,
  request,
) async {
  final repository = ref.watch(legacyTmdbRepositoryProvider);

  return switch (request.type) {
    'movie' => Movie.fromJson(await repository.getMovieDetails(request.id)),
    'tv' => TvShow.fromJson(await repository.getTvDetails(request.id)),
    _ => throw ArgumentError('Unsupported media type: ${request.type}'),
  };
});
