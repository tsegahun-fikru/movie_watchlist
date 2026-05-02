// lib/core/di/clean_arch_providers.dart
// Central dependency-injection file for the clean-architecture layers.
// Wires data sources → repositories → use cases → notifiers using Riverpod
// Provider so that every layer can be swapped or mocked independently.

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
import 'package:movie_watchlist/features/movies/presentation/notifiers/tv_search_notifier.dart';
import 'package:movie_watchlist/features/movies/presentation/state/movie_search_state.dart';
import 'package:movie_watchlist/features/movies/presentation/state/tv_search_state.dart';
import 'package:movie_watchlist/features/movies/data/repositories/legacy_tmdb_repository.dart';
import 'package:movie_watchlist/features/watchlist/data/datasources/firestore_watchlist_data_source.dart';
import 'package:movie_watchlist/features/watchlist/data/repositories/watchlist_repository_impl.dart';
import 'package:movie_watchlist/features/watchlist/domain/repositories/watchlist_repository.dart';
import 'package:movie_watchlist/features/watchlist/domain/usecases/add_to_watchlist_use_case.dart';
import 'package:movie_watchlist/features/watchlist/domain/usecases/get_watchlist_use_case.dart';
import 'package:movie_watchlist/features/watchlist/domain/usecases/remove_from_watchlist_use_case.dart';

// ─── Infrastructure ───────────────────────────────────────────────────────────

/// Shared HTTP client; disposed automatically when the provider is destroyed.
final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

/// Singleton [FirebaseAuth] instance.
final firebaseAuthInstanceProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Singleton [FirebaseFirestore] instance.
final firestoreInstanceProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// ─── Data sources ─────────────────────────────────────────────────────────────

/// Remote data source that talks to the TMDB REST API.
final tmdbRemoteDataSourceProvider = Provider<TmdbRemoteDataSource>((ref) {
  return TmdbRemoteDataSource(client: ref.watch(httpClientProvider));
});

/// Firestore data source for the clean-arch watchlist feature.
final firestoreWatchlistDataSourceProvider =
    Provider<FirestoreWatchlistDataSource>((ref) {
      return FirestoreWatchlistDataSource(
        firestore: ref.watch(firestoreInstanceProvider),
      );
    });

// ─── Repositories ─────────────────────────────────────────────────────────────

/// Clean-arch movie repository backed by [TmdbRemoteDataSource].
final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  return MovieRepositoryImpl(
    remoteDataSource: ref.watch(tmdbRemoteDataSourceProvider),
  );
});

/// Clean-arch watchlist repository backed by Firestore.
final watchlistRepositoryProvider = Provider<WatchlistRepository>((ref) {
  return WatchlistRepositoryImpl(
    dataSource: ref.watch(firestoreWatchlistDataSourceProvider),
    firebaseAuth: ref.watch(firebaseAuthInstanceProvider),
  );
});

// ─── Use cases ────────────────────────────────────────────────────────────────

/// Use case for searching movies with optional filters and pagination.
final searchMoviesUseCaseProvider = Provider<SearchMoviesUseCase>((ref) {
  return SearchMoviesUseCase(ref.watch(movieRepositoryProvider));
});

/// Use case for fetching the daily trending movies list.
final getTrendingMoviesUseCaseProvider = Provider<GetTrendingMoviesUseCase>((
  ref,
) {
  return GetTrendingMoviesUseCase(ref.watch(movieRepositoryProvider));
});

/// Use case for fetching the list of TMDB movie genres.
final getMovieGenresUseCaseProvider = Provider<GetMovieGenresUseCase>((ref) {
  return GetMovieGenresUseCase(ref.watch(movieRepositoryProvider));
});

/// Use case for adding a movie to the user's watchlist.
final addToWatchlistUseCaseProvider = Provider<AddToWatchlistUseCase>((ref) {
  return AddToWatchlistUseCase(ref.watch(watchlistRepositoryProvider));
});

/// Use case for removing a movie from the user's watchlist.
final removeFromWatchlistUseCaseProvider = Provider<RemoveFromWatchlistUseCase>(
  (ref) {
    return RemoveFromWatchlistUseCase(ref.watch(watchlistRepositoryProvider));
  },
);

/// Use case for fetching the full watchlist for the current user.
final getWatchlistUseCaseProvider = Provider<GetWatchlistUseCase>((ref) {
  return GetWatchlistUseCase(ref.watch(watchlistRepositoryProvider));
});

// ─── Notifiers ────────────────────────────────────────────────────────────────

/// Auto-disposed notifier that drives the movie search screen.
/// Calls [MovieSearchNotifier.loadInitial] immediately on creation.
final movieSearchNotifierProvider =
    StateNotifierProvider.autoDispose<MovieSearchNotifier, MovieSearchState>((
      ref,
    ) {
      return MovieSearchNotifier(
        searchMoviesUseCase: ref.watch(searchMoviesUseCaseProvider),
        getTrendingMoviesUseCase: ref.watch(getTrendingMoviesUseCaseProvider),
      )..loadInitial();
    });

/// Cached list of TMDB movie genres (id → name).
final movieGenresProvider = FutureProvider<List<Genre>>((ref) async {
  final useCase = ref.watch(getMovieGenresUseCaseProvider);
  final result = await useCase();

  return result.when(
    success: (genres) => genres,
    failure: (failure) => throw Exception(failure.message),
  );
});

// ─── Legacy repository (used by TV search and some home providers) ────────────

/// [LegacyTmdbRepository] instance used specifically by the TV search notifier.
/// New features should prefer the clean-arch path above.
final legacyTmdbRepositoryForSearchProvider =
    Provider<LegacyTmdbRepository>((ref) {
  return LegacyTmdbRepository(client: ref.watch(httpClientProvider));
});

/// Auto-disposed notifier that drives the TV show search screen.
final tvSearchNotifierProvider =
    StateNotifierProvider.autoDispose<TvSearchNotifier, TvSearchState>((ref) {
  return TvSearchNotifier(
    repository: ref.watch(legacyTmdbRepositoryForSearchProvider),
  );
});

/// Cached map of TMDB TV genres (id → name).
final tvGenresProvider = FutureProvider<Map<int, String>>((ref) {
  return ref
      .watch(legacyTmdbRepositoryForSearchProvider)
      .fetchTvGenres();
});
