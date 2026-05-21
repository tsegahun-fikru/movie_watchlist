// lib/core/auth/auth_repository.dart
// Defines the authentication contract and its Firebase implementation.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:movie_watchlist/core/error/exceptions.dart';

/// Abstract contract for authentication operations.
///
/// Decouples the rest of the app from Firebase Auth, making it easy to
/// swap implementations or mock in tests.
abstract class AuthRepository {
  /// Stream that emits the current [User] whenever auth state changes.
  Stream<User?> get authStateChanges;

  Future<User?> signInWithEmailAndPassword(String email, String password);
  Future<User?> signUpWithEmailAndPassword(String email, String password);
  Future<void> updateDisplayName(String? displayName);
  Future<void> reauthenticateWithPassword(String email, String password);
  Future<void> deleteCurrentUser();
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
  Future<void> updateDisplayName(String? displayName) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const AuthenticationException('No signed-in user found.');
    }

    try {
      await user.updateDisplayName(displayName);
      await user.reload();
    } on FirebaseAuthException catch (error) {
      throw AuthenticationException(
        error.message ?? 'Failed to update profile.',
      );
    }
  }

  @override
  Future<void> reauthenticateWithPassword(String email, String password) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const AuthenticationException('No signed-in user found.');
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (error) {
      throw AuthenticationException(
        error.message ?? 'Failed to confirm your identity.',
      );
    }
  }

  @override
  Future<void> deleteCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const AuthenticationException('No signed-in user found.');
    }

    try {
      await user.delete();
    } on FirebaseAuthException catch (error) {
      throw AuthenticationException(
        error.message ?? 'Failed to delete account.',
      );
    }
  }

  @override
  Future<void> signOut() => _firebaseAuth.signOut();
}
