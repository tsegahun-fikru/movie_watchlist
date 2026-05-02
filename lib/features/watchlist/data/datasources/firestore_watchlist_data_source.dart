// lib/features/watchlist/data/datasources/firestore_watchlist_data_source.dart
// Clean-arch Firestore data source for the watchlist feature.
// Reads and writes to the `users/{uid}/watchlist` Firestore collection.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movie_watchlist/core/error/exceptions.dart';
import 'package:movie_watchlist/features/watchlist/data/models/watchlist_item_model.dart';

/// Handles all Firestore operations for the user's watchlist.
///
/// All methods throw [CacheException] on Firestore errors so the repository
/// layer can convert them to [CacheFailure] objects.
class FirestoreWatchlistDataSource {
  FirestoreWatchlistDataSource({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  /// Fetches all watchlist items for [userId], sorted newest-first.
  Future<List<WatchlistItemModel>> fetchWatchlist(String userId) async {
    try {
      final snapshot = await _collection(userId).get();

      return snapshot.docs
          .map((doc) => WatchlistItemModel.fromFirestore(userId, doc.data()))
          .toList()
        ..sort((left, right) => right.addedAt.compareTo(left.addedAt));
    } on FirebaseException catch (error) {
      throw CacheException(error.message ?? 'Failed to fetch watchlist.');
    }
  }

  /// Adds or overwrites a watchlist item document for [userId].
  Future<void> addMovie(String userId, WatchlistItemModel item) async {
    try {
      await _collection(userId).doc('${item.movie.id}').set(item.toFirestore());
    } on FirebaseException catch (error) {
      throw CacheException(error.message ?? 'Failed to add watchlist item.');
    }
  }

  /// Deletes the watchlist document for [movieId] under [userId].
  Future<void> removeMovie(String userId, int movieId) async {
    try {
      await _collection(userId).doc('$movieId').delete();
    } on FirebaseException catch (error) {
      throw CacheException(error.message ?? 'Failed to remove watchlist item.');
    }
  }

  /// Returns the Firestore collection reference for [userId]'s watchlist.
  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore.collection('users').doc(userId).collection('watchlist');
  }
}
