// lib/core/firestore/firestore_service.dart
// Shared Firestore helper that scopes collection references to the currently
// authenticated user. Used by features that need direct Firestore access
// outside the clean-arch watchlist path.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Provides access to Firestore collections,
/// automatically scoped to the currently authenticated user.
class FirestoreService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  /// Returns the user-scoped watchlist collection reference.
  /// Returns `null` if no user is signed in.
  CollectionReference? getWatchlistCollection() {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _firestore.collection('users').doc(user.uid).collection('watchlist');
  }

  /// Convenience method to add a document to the user's watchlist.
  /// Throws if the user is not signed in.
  Future<void> addToWatchlist(int movieId, Map<String, dynamic> data) async {
    final collection = getWatchlistCollection();
    if (collection == null) throw Exception('User not signed in');
    await collection.doc(movieId.toString()).set(data);
  }

  /// Convenience method to remove a movie from watchlist.
  /// Throws if the user is not signed in.
  Future<void> removeFromWatchlist(int movieId) async {
    final collection = getWatchlistCollection();
    if (collection == null) throw Exception('User not signed in');
    await collection.doc(movieId.toString()).delete();
  }
}
