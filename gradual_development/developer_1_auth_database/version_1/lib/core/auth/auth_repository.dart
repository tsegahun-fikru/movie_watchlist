// lib/core/auth/auth_repository.dart
// VERSION 1 - No Firebase. Uses hardcoded mock data.

/// Abstract contract for authentication operations.
abstract class AuthRepository {
  Future<bool> signInWithEmailAndPassword(String email, String password);
  Future<bool> signUpWithEmailAndPassword(String email, String password);
  Future<void> signOut();
}

/// Mock implementation - always succeeds, no real auth.
class MockAuthRepository implements AuthRepository {
  @override
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    // TODO v2: Replace with Firebase Auth
    await Future.delayed(const Duration(milliseconds: 500)); // simulate network
    return true; // always succeeds in v1
  }

  @override
  Future<bool> signUpWithEmailAndPassword(String email, String password) async {
    // TODO v2: Replace with Firebase Auth
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  @override
  Future<void> signOut() async {
    // TODO v2: Replace with Firebase Auth signOut
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
