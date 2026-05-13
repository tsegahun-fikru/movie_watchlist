// lib/features/watchlist/presentation/providers/watchlist_providers.dart
// VERSION 2 - Riverpod providers with Firestore integration.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:movie_watchlist/features/watchlist/data/models/watchlist_item.dart';
import 'package:movie_watchlist/features/watchlist/data/services/watchlist_service.dart';

/// Provides FirebaseFirestore instance.
/// TODO v3: Move to core providers
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provides FirebaseAuth instance.
/// TODO v3: Move to core providers
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Provides current user ID.
/// TODO v3: Move to auth providers
final currentUserIdProvider = Provider<String?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.currentUser?.uid;
});

/// Provides WatchlistService scoped to current user.
final watchlistServiceProvider = Provider<WatchlistService?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;
  
  final firestore = ref.watch(firestoreProvider);
  return WatchlistService(firestore: firestore, userId: userId);
});

/// Real-time stream of watchlist items from Firestore.
/// TODO v3: Add error handling and retry logic
final watchlistStreamProvider = StreamProvider<List<WatchlistItem>>((ref) {
  final service = ref.watch(watchlistServiceProvider);
  if (service == null) return Stream.value([]);
  
  return service.getWatchlistStream();
});
