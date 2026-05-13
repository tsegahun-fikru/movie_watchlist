// lib/core/error/failures.dart
// VERSION 2 - Failure classes for error handling.

/// Base failure class.
/// TODO v3: Add failure codes, localized messages
abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

/// Server failure.
class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode});
}

/// Cache failure.
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Network failure.
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Validation failure.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
