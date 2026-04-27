import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movie_watchlist/core/error/exceptions.dart';
import 'package:movie_watchlist/features/watchlist/data/models/watchlist_item_model.dart';

class FirestoreWatchlistDataSource {
  FirestoreWatchlistDataSource({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

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

  Future<void> addMovie(String userId, WatchlistItemModel item) async {
    try {
      await _collection(userId).doc('${item.movie.id}').set(item.toFirestore());
    } on FirebaseException catch (error) {
      throw CacheException(error.message ?? 'Failed to add watchlist item.');
    }
  }

  Future<void> removeMovie(String userId, int movieId) async {
    try {
      await _collection(userId).doc('$movieId').delete();
    } on FirebaseException catch (error) {
      throw CacheException(error.message ?? 'Failed to remove watchlist item.');
    }
  }

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore.collection('users').doc(userId).collection('watchlist');
  }
}
