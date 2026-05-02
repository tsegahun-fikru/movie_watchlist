// lib/features/auth/presentation/providers/auth_providers.dart
// Riverpod providers that expose Firebase Auth state and the [AuthRepository]
// to the rest of the auth feature and the router.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_watchlist/core/auth/auth_repository.dart';

/// Raw [FirebaseAuth] singleton — used when direct access is needed
/// (e.g. re-authentication before account deletion).
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Stream of the current [User?] directly from [FirebaseAuth].
/// Used by the GoRouter redirect to gate navigation.
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// The [AuthRepository] implementation backed by [FirebaseAuthRepository].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return FirebaseAuthRepository(firebaseAuth: auth);
});

/// Stream of [User?] via the [AuthRepository] abstraction.
/// Prefer this over [authStateProvider] in feature code so the repository
/// can be swapped in tests.
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authStateChanges;
});

/// Emits a new integer timestamp whenever the auth state changes.
/// Useful for invalidating providers that depend on the current user
/// without exposing the [User] object directly.
final authChangeCounterProvider = StreamProvider<int>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authStateChanges.map(
    (_) => DateTime.now().millisecondsSinceEpoch,
  );
});

/// Convenience provider that exposes only the current user's UID.
/// Returns `null` when the user is signed out.
final currentUserIdProvider = Provider<String?>((ref) {
  final user = ref.watch(authStateChangesProvider).valueOrNull;
  return user?.uid;
});
