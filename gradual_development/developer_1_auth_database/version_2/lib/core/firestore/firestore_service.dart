// lib/core/firestore/firestore_service.dart
// VERSION 2 - Real Firestore. Basic operations, minimal error handling.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  /// Returns the user-scoped watchlist collection.
  /// Returns null if no user is signed in.
  CollectionReference? getWatchlistCollection() {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _firestore.collection('users').doc(user.uid).collection('watchlist');
  }

  /// Adds a movie to the user's Firestore watchlist.
  Future<void> addToWatchlist(int movieId, Map<String, dynamic> data) async {
    final collection = getWatchlistCollection();
    if (collection == null) throw Exception('User not signed in');
    // TODO v3: Add retry logic and better error handling
    await collection.doc(movieId.toString()).set(data);
  }

  /// Removes a movie from the user's Firestore watchlist.
  Future<void> removeFromWatchlist(int movieId) async {
    final collection = getWatchlistCollection();
    if (collection == null) throw Exception('User not signed in');
    // TODO v3: Add retry logic and better error handling
    await collection.doc(movieId.toString()).delete();
  }
}
