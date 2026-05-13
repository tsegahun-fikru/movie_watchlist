// lib/core/error/exceptions.dart
// VERSION 2 - Exception classes with details.

/// Server exception with status code.
/// TODO v3: Add more exception types (timeout, parse, etc.)
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException(this.message, {this.statusCode});

  @override
  String toString() => 'ServerException: $message (status: $statusCode)';
}

/// Cache exception.
class CacheException implements Exception {
  final String message;

  CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}

/// Network exception.
class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}
