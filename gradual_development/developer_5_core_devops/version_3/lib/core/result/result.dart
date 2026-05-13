// lib/core/result/result.dart
// Functional Result type used as the return type of all repository methods.
// Avoids throwing exceptions across layer boundaries and makes error handling
// explicit at the call site.

import 'package:movie_watchlist/core/error/failures.dart';

/// A sealed union of [Success] and [Error] that wraps a repository result.
///
/// Use [when] to handle both cases:
/// ```dart
/// final result = await repo.getWatchlist(userId);
/// result.when(
///   success: (items) => ...,
///   failure: (failure) => ...,
/// );
/// ```
sealed class Result<T> {
  const Result();

  /// Pattern-matches on the result, calling [success] or [failure] accordingly.
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) {
    final value = this;
    if (value is Success<T>) {
      return success(value.data);
    }

    return failure((value as Error<T>).failure);
  }
}

/// Placeholder type for use cases that return no meaningful value on success
/// (equivalent to `void` but compatible with `Result<Unit>`).
class Unit {
  const Unit();
}

/// The happy-path variant of [Result], carrying the successful [data].
class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;
}

/// The failure variant of [Result], carrying a [Failure] describing what went wrong.
class Error<T> extends Result<T> {
  const Error(this.failure);

  final Failure failure;
}
