// Version 1: Basic Structure - Interface Only
// No Firebase implementation yet

/// Abstract contract for authentication operations.
abstract class AuthRepository {
  /// Stream that emits the current User whenever auth state changes.
  /// Returns null for now (no Firebase yet)
  Stream<dynamic> get authStateChanges;

  Future<dynamic> signInWithEmailAndPassword(String email, String password);
  Future<dynamic> signUpWithEmailAndPassword(String email, String password);
  Future<void> signOut();
}

/// Mock implementation for Version 1
/// This will be replaced with Firebase in Version 2
class MockAuthRepository implements AuthRepository {
  @override
  Stream<dynamic> get authStateChanges => Stream.value(null);

  @override
  Future<dynamic> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    print('Mock sign in: $email');
    return {'email': email, 'uid': 'mock-uid-123'};
  }

  @override
  Future<dynamic> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    await Future.delayed(const Duration(seconds: 1));
    print('Mock sign up: $email');
    return {'email': email, 'uid': 'mock-uid-456'};
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    print('Mock sign out');
  }
}
