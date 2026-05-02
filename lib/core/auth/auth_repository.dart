// lib/core/auth/auth_repository.dart
// Defines the authentication contract and its Firebase implementation.

import 'package:firebase_auth/firebase_auth.dart';

/// Abstract contract for authentication operations.
///
/// Decouples the rest of the app from Firebase Auth, making it easy to
/// swap implementations or mock in tests.
abstract class AuthRepository {
  /// Stream that emits the current [User] whenever auth state changes.
  Stream<User?> get authStateChanges;

  Future<User?> signInWithEmailAndPassword(String email, String password);
  Future<User?> signUpWithEmailAndPassword(String email, String password);
  Future<void> signOut();
}

/// Concrete implementation using Firebase Authentication.
class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;

  /// Accepts an optional [firebaseAuth] instance to make testing easy —
  /// inject a mock instance if needed.
  FirebaseAuthRepository({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  @override
  Future<User?> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  @override
  Future<void> signOut() => _firebaseAuth.signOut();
}
