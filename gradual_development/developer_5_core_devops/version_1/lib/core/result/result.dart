// lib/core/result/result.dart
// VERSION 1 - Simple Result type.

import 'package:movie_watchlist/core/error/failures.dart';

/// Simple Result type for error handling.
/// TODO v2: Add more helper methods
class Result<T> {
  final T? data;
  final Failure? failure;

  Result.success(this.data) : failure = null;
  Result.failure(this.failure) : data = null;

  bool get isSuccess => data != null;
  bool get isFailure => failure != null;
}
