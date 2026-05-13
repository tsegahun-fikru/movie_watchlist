// lib/features/auth/presentation/providers/auth_providers.dart
// VERSION 2 - Riverpod providers + Firebase Auth. Basic error handling.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_watchlist/core/auth/auth_repository.dart';

/// Raw FirebaseAuth instance provider.
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Stream of the current User? from Firebase.
/// Used by the router to gate navigation.
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// The AuthRepository backed by Firebase.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return FirebaseAuthRepository(firebaseAuth: auth);
});

/// Stream of User? via the AuthRepository abstraction.
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authStateChanges;
});

// TODO v3: Add authChangeCounterProvider and currentUserIdProvider
