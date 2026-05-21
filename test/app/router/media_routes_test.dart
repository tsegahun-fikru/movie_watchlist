import 'package:flutter_test/flutter_test.dart';
import 'package:movie_watchlist/app/router/media_routes.dart';
import 'package:movie_watchlist/core/domain/entities/media_item.dart';

void main() {
  test('builds detail paths from media items and ids', () {
    const item = _FakeMediaItem(type: 'tv', id: 42);

    expect(mediaDetailsPath(item), '/details/tv/42');
    expect(mediaDetailsPathById('movie', 7), '/details/movie/7');
  });

  test('rejects unsupported detail path objects', () {
    expect(() => mediaDetailsPathForObject(Object()), throwsArgumentError);
  });
}

class _FakeMediaItem implements MediaItem {
  const _FakeMediaItem({required this.type, required this.id});

  @override
  final String type;

  @override
  final int id;

  @override
  String get backdropPath => '';

  @override
  String get backdropUrl => '';

  @override
  List<int> get genreIds => const <int>[];

  @override
  String get overview => '';

  @override
  String get posterPath => '';

  @override
  String get posterUrl => '';

  @override
  double get rating => 0;

  @override
  String get releaseDate => '';

  @override
  String get title => '';
}
