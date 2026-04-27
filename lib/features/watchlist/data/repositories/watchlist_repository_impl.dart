import 'package:firebase_auth/firebase_auth.dart';
import 'package:movie_watchlist/core/error/exceptions.dart';
import 'package:movie_watchlist/core/error/failures.dart';
import 'package:movie_watchlist/core/result/result.dart';
import 'package:movie_watchlist/features/movies/domain/entities/movie.dart';
import 'package:movie_watchlist/features/watchlist/data/datasources/firestore_watchlist_data_source.dart';
import 'package:movie_watchlist/features/watchlist/data/models/watchlist_item_model.dart';
import 'package:movie_watchlist/features/watchlist/domain/entities/watchlist_item.dart';
import 'package:movie_watchlist/features/watchlist/domain/repositories/watchlist_repository.dart';

class WatchlistRepositoryImpl implements WatchlistRepository {
  WatchlistRepositoryImpl({
    required FirestoreWatchlistDataSource dataSource,
    required FirebaseAuth firebaseAuth,
  }) : _dataSource = dataSource,
       _firebaseAuth = firebaseAuth;

  final FirestoreWatchlistDataSource _dataSource;
  final FirebaseAuth _firebaseAuth;
  final Map<String, List<WatchlistItem>> _watchlistCache =
      <String, List<WatchlistItem>>{};

  @override
  Future<Result<List<WatchlistItem>>> getWatchlist(String userId) async {
    final cachedItems = _watchlistCache[userId];
    if (cachedItems != null) {
      return Success<List<WatchlistItem>>(cachedItems);
    }

    try {
      final items = await _dataSource.fetchWatchlist(userId);
      final mappedItems = items.map((item) => item.toEntity()).toList();
      _watchlistCache[userId] = mappedItems;
      return Success<List<WatchlistItem>>(mappedItems);
    } on CacheException catch (error) {
      return Error<List<WatchlistItem>>(CacheFailure(error.message));
    } catch (error) {
      return Error<List<WatchlistItem>>(UnknownFailure('$error'));
    }
  }

  @override
  Future<Result<Unit>> addToWatchlist(Movie movie) async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) {
      return const Error<Unit>(
        AuthenticationFailure('You must be logged in to save a movie.'),
      );
    }

    final addedAt = DateTime.now();
    final item = WatchlistItem(movie: movie, userId: userId, addedAt: addedAt);
    final previousItems = List<WatchlistItem>.from(
      _watchlistCache[userId] ?? const <WatchlistItem>[],
    );

    _watchlistCache[userId] = <WatchlistItem>[item, ...previousItems];

    try {
      final model = WatchlistItemModel.fromMovie(
        userId: userId,
        movie: movie,
        addedAt: addedAt,
      );
      await _dataSource.addMovie(userId, model);
      return const Success<Unit>(Unit());
    } on CacheException catch (error) {
      _watchlistCache[userId] = previousItems;
      return Error<Unit>(CacheFailure(error.message));
    } catch (error) {
      _watchlistCache[userId] = previousItems;
      return Error<Unit>(UnknownFailure('$error'));
    }
  }

  @override
  Future<Result<Unit>> removeFromWatchlist(int movieId) async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) {
      return const Error<Unit>(
        AuthenticationFailure('You must be logged in to remove a movie.'),
      );
    }

    final previousItems = List<WatchlistItem>.from(
      _watchlistCache[userId] ?? const <WatchlistItem>[],
    );

    _watchlistCache[userId] = previousItems
        .where((item) => item.movie.id != movieId)
        .toList();

    try {
      await _dataSource.removeMovie(userId, movieId);
      return const Success<Unit>(Unit());
    } on CacheException catch (error) {
      _watchlistCache[userId] = previousItems;
      return Error<Unit>(CacheFailure(error.message));
    } catch (error) {
      _watchlistCache[userId] = previousItems;
      return Error<Unit>(UnknownFailure('$error'));
    }
  }
}
