// lib/core/error/exceptions.dart
// Exception types thrown by data-layer classes (data sources, services).
// These are caught by repository implementations and converted to [Failure]
// objects before being returned to the domain/presentation layers.

/// Thrown when a remote API call fails (non-2xx status or network error).
class ServerException implements Exception {
  const ServerException(this.message);

  final String message;
}

/// Thrown when a local cache or Firestore operation fails.
class CacheException implements Exception {
  const CacheException(this.message);

  final String message;
}

/// Thrown when a Firebase Auth operation fails (wrong password, etc.).
class AuthenticationException implements Exception {
  const AuthenticationException(this.message);

  final String message;
}
