// lib/core/error/exceptions.dart
// VERSION 1 - Basic exception classes.

/// Simple server exception.
/// TODO v2: Add more specific exception types
class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

/// Simple cache exception.
class CacheException implements Exception {
  final String message;
  CacheException(this.message);
}
