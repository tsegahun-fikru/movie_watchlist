// lib/core/error/failures.dart
// VERSION 1 - Basic failure classes.

/// Base failure class.
/// TODO v2: Add more specific failure types
abstract class Failure {
  final String message;
  const Failure(this.message);
}

/// Server failure.
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Cache failure.
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}
