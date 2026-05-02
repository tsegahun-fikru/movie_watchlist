// lib/core/error/failures.dart
// Failure types returned by repository methods via [Result.Error].
// Using sealed-class-style inheritance lets callers pattern-match on the
// specific failure kind without depending on exception types.

/// Base class for all domain-level failures.
abstract class Failure {
  const Failure(this.message);

  final String message;
}

/// A remote API call returned an error or the network was unavailable.
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// A local cache or Firestore read/write failed.
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// The user is not authenticated or credentials are invalid.
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message);
}

/// Input data did not pass validation rules.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// An unexpected error that doesn't fit any other category.
class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}
