import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:movie_watchlist/core/result/result.dart';
import 'package:movie_watchlist/features/movies/data/datasources/tmdb_remote_data_source.dart';
import 'package:movie_watchlist/features/movies/data/repositories/movie_repository_impl.dart';
import 'package:movie_watchlist/features/movies/domain/entities/movie_filters.dart';
import 'package:movie_watchlist/features/movies/domain/entities/movie_page.dart';

void main() {
  late CountingClient client;
  late MovieRepositoryImpl repository;

  setUp(() {
    client = CountingClient();
    repository = MovieRepositoryImpl(
      remoteDataSource: TmdbRemoteDataSource(client: client),
      maxMoviePageCacheEntries: 2,
    );
  });

  test('returns cached search pages without repeating network calls', () async {
    await repository.searchMovies('dune', const MovieFilters(), 1);
    final result = await repository.searchMovies(
      'dune',
      const MovieFilters(),
      1,
    );

    expect(result, isA<Success<MoviePage>>());
    expect(client.requestCount, 1);
  });

  test('evicts least recently used movie pages when cache is full', () async {
    await repository.searchMovies('first', const MovieFilters(), 1);
    await repository.searchMovies('second', const MovieFilters(), 1);
    await repository.searchMovies('third', const MovieFilters(), 1);
    await repository.searchMovies('first', const MovieFilters(), 1);

    expect(client.requestCount, 4);
  });
}

class CountingClient extends http.BaseClient {
  int requestCount = 0;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requestCount += 1;
    final body = jsonEncode(<String, Object?>{
      'page': int.tryParse(request.url.queryParameters['page'] ?? '') ?? 1,
      'total_pages': 1,
      'results': const <Object?>[],
    });

    return http.StreamedResponse(
      Stream<List<int>>.value(utf8.encode(body)),
      200,
      headers: const <String, String>{'content-type': 'application/json'},
    );
  }
}
