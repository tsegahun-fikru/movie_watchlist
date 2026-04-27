import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_watchlist/core/auth/auth_repository.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return FirebaseAuthRepository(firebaseAuth: auth);
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authStateChanges;
});

final authChangeCounterProvider = StreamProvider<int>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authStateChanges.map(
    (_) => DateTime.now().millisecondsSinceEpoch,
  );
});

final currentUserIdProvider = Provider<String?>((ref) {
  final user = ref.watch(authStateChangesProvider).valueOrNull;
  return user?.uid;
});
