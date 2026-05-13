// lib/core/result/result.dart
// VERSION 2 - Result type with helper methods.

import 'package:movie_watchlist/core/error/failures.dart';

/// Result type for error handling.
/// TODO v3: Add fold, map, flatMap methods
class Result<T> {
  final T? data;
  final Failure? failure;

  Result.success(this.data) : failure = null;
  Result.failure(this.failure) : data = null;

  bool get isSuccess => data != null;
  bool get isFailure => failure != null;

  /// Returns data or throws if failure.
  T getOrThrow() {
    if (isSuccess) return data!;
    throw Exception(failure!.message);
  }

  /// Returns data or default value.
  T getOrElse(T defaultValue) {
    return data ?? defaultValue;
  }

  /// Executes callback based on result.
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) {
    if (isSuccess) {
      return success(data!);
    } else {
      return failure(this.failure!);
    }
  }
}
