import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:movie_watchlist/features/movies/data/datasources/tmdb_remote_data_source.dart';
import 'package:movie_watchlist/features/movies/data/repositories/movie_repository_impl.dart';
import 'package:movie_watchlist/features/movies/domain/entities/genre.dart';
import 'package:movie_watchlist/features/movies/domain/repositories/movie_repository.dart';
import 'package:movie_watchlist/features/movies/domain/usecases/get_movie_genres_use_case.dart';
import 'package:movie_watchlist/features/movies/domain/usecases/get_trending_movies_use_case.dart';
import 'package:movie_watchlist/features/movies/domain/usecases/search_movies_use_case.dart';
import 'package:movie_watchlist/features/movies/presentation/notifiers/movie_search_notifier.dart';
import 'package:movie_watchlist/features/movies/presentation/state/movie_search_state.dart';
import 'package:movie_watchlist/features/watchlist/data/datasources/firestore_watchlist_data_source.dart';
import 'package:movie_watchlist/features/watchlist/data/repositories/watchlist_repository_impl.dart';
import 'package:movie_watchlist/features/watchlist/domain/repositories/watchlist_repository.dart';
import 'package:movie_watchlist/features/watchlist/domain/usecases/add_to_watchlist_use_case.dart';
import 'package:movie_watchlist/features/watchlist/domain/usecases/get_watchlist_use_case.dart';
import 'package:movie_watchlist/features/watchlist/domain/usecases/remove_from_watchlist_use_case.dart';

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final firebaseAuthInstanceProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreInstanceProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final tmdbRemoteDataSourceProvider = Provider<TmdbRemoteDataSource>((ref) {
  return TmdbRemoteDataSource(client: ref.watch(httpClientProvider));
});

final firestoreWatchlistDataSourceProvider =
    Provider<FirestoreWatchlistDataSource>((ref) {
      return FirestoreWatchlistDataSource(
        firestore: ref.watch(firestoreInstanceProvider),
      );
    });

final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  return MovieRepositoryImpl(
    remoteDataSource: ref.watch(tmdbRemoteDataSourceProvider),
  );
});

final watchlistRepositoryProvider = Provider<WatchlistRepository>((ref) {
  return WatchlistRepositoryImpl(
    dataSource: ref.watch(firestoreWatchlistDataSourceProvider),
    firebaseAuth: ref.watch(firebaseAuthInstanceProvider),
  );
});

final searchMoviesUseCaseProvider = Provider<SearchMoviesUseCase>((ref) {
  return SearchMoviesUseCase(ref.watch(movieRepositoryProvider));
});

final getTrendingMoviesUseCaseProvider = Provider<GetTrendingMoviesUseCase>((
  ref,
) {
  return GetTrendingMoviesUseCase(ref.watch(movieRepositoryProvider));
});

final getMovieGenresUseCaseProvider = Provider<GetMovieGenresUseCase>((ref) {
  return GetMovieGenresUseCase(ref.watch(movieRepositoryProvider));
});

final addToWatchlistUseCaseProvider = Provider<AddToWatchlistUseCase>((ref) {
  return AddToWatchlistUseCase(ref.watch(watchlistRepositoryProvider));
});

final removeFromWatchlistUseCaseProvider = Provider<RemoveFromWatchlistUseCase>(
  (ref) {
    return RemoveFromWatchlistUseCase(ref.watch(watchlistRepositoryProvider));
  },
);

final getWatchlistUseCaseProvider = Provider<GetWatchlistUseCase>((ref) {
  return GetWatchlistUseCase(ref.watch(watchlistRepositoryProvider));
});

final movieSearchNotifierProvider =
    StateNotifierProvider.autoDispose<MovieSearchNotifier, MovieSearchState>((
      ref,
    ) {
      return MovieSearchNotifier(
        searchMoviesUseCase: ref.watch(searchMoviesUseCaseProvider),
        getTrendingMoviesUseCase: ref.watch(getTrendingMoviesUseCaseProvider),
      )..loadInitial();
    });

final movieGenresProvider = FutureProvider<List<Genre>>((ref) async {
  final useCase = ref.watch(getMovieGenresUseCaseProvider);
  final result = await useCase();

  return result.when(
    success: (genres) => genres,
    failure: (failure) => throw Exception(failure.message),
  );
});
